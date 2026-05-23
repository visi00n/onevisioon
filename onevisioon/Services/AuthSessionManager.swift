import AuthenticationServices
import Combine
import CryptoKit
import Foundation
import Security
import UIKit

@MainActor
final class AuthSessionManager: ObservableObject {
    @Published private(set) var currentSession: AuthUserSession?
    @Published private(set) var backendStatus: AuthBackendStatus
    @Published var isRefreshingCredentialState = false
    @Published var isAuthenticating = false
    @Published var isSyncingCloud = false
    @Published private(set) var lastCloudSyncAt: Date?
    @Published var errorMessage = ""

    private let appleProvider = ASAuthorizationAppleIDProvider()
    private let sessionKeychainAccount = "auth_user_session"
    private let configurationMessage: String
    private let supabaseClient: SupabaseAuthClient?
    private var currentAppleNonce: String?
    private var activeWebAuthenticationSession: ASWebAuthenticationSession?
    private let authenticationPresentationContextProvider = AuthenticationPresentationContextProvider()

    init() {
        do {
            let configuration = try SupabaseProjectConfiguration.load()
            supabaseClient = SupabaseAuthClient(configuration: configuration)
            backendStatus = .supabaseReady
            configurationMessage = ""
        } catch {
            supabaseClient = nil
            backendStatus = .configurationRequired
            configurationMessage = (error as? LocalizedError)?.errorDescription ?? SupabaseProjectConfiguration.setupMessage
        }

        loadPersistedSession()
    }

    deinit {
        activeWebAuthenticationSession?.cancel()
    }

    var isSignedIn: Bool {
        currentSession != nil
    }

    var isCloudConfigured: Bool {
        supabaseClient != nil
    }

    var canStartAppleSignIn: Bool {
        true
    }

    var canStartGoogleSignIn: Bool {
        isCloudConfigured
    }

    var googleOAuthRedirectURL: URL {
        Self.makeOAuthRedirectURL()
    }

    var syncStatusLine: String {
        if currentSession == nil {
            return isCloudConfigured
                ? "Ready for secure cloud sign-in with Apple or Google"
                : "Apple sign-in is available on this device. Add Supabase config to enable cloud sync."
        }

        if currentSession?.isCloudBacked != true {
            return "Signed in with Apple on this device. Supabase setup is needed for cloud sync."
        }

        if isSyncingCloud {
            return "Syncing your profile and progress..."
        }

        if lastCloudSyncAt != nil {
            return "Cloud sync is active"
        }

        return "Signed in and ready to sync your study data"
    }

    func configureAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]

        guard isCloudConfigured else {
            currentAppleNonce = nil
            errorMessage = ""
            return
        }

        let nonce = Self.randomNonceString()
        currentAppleNonce = nonce
        request.nonce = Self.sha256(nonce)
        errorMessage = ""
    }

    func handleAppleSignIn(result: Result<ASAuthorization, Error>, store: SoulJourneyStore) async {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                errorMessage = "Apple sign-in returned an unexpected credential."
                return
            }

            isAuthenticating = true
            defer {
                isAuthenticating = false
                currentAppleNonce = nil
            }

            let formattedName = Self.formattedName(from: credential.fullName)
            let previous = currentSession

            guard let supabaseClient else {
                let session = Self.makeLocalAppleSession(
                    credential: credential,
                    previousSession: previous,
                    displayNameHint: formattedName,
                    fallbackName: store.onboardingProfile.fullName.trimmed,
                    fallbackEmail: store.onboardingProfile.email.trimmed
                )

                currentSession = session
                persistSession(session)
                store.applyAuthenticatedIdentity(displayName: session.displayName, email: session.email)
                errorMessage = ""
                return
            }

            guard let rawNonce = currentAppleNonce else {
                errorMessage = SupabaseAuthError.requestStateMismatch.errorDescription ?? "Please try signing in again."
                return
            }

            guard let identityTokenData = credential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8),
                  !identityToken.trimmed.isEmpty else {
                errorMessage = SupabaseAuthError.identityTokenMissing.errorDescription ?? "Please try signing in again."
                return
            }

            do {
                let authPayload = try await supabaseClient.signInWithApple(idToken: identityToken, rawNonce: rawNonce)
                var remoteUser = authPayload.user

                if !formattedName.isEmpty {
                    var metadata: [String: String] = ["full_name": formattedName]

                    if let givenName = credential.fullName?.givenName?.trimmed, !givenName.isEmpty {
                        metadata["given_name"] = givenName
                    }

                    if let familyName = credential.fullName?.familyName?.trimmed, !familyName.isEmpty {
                        metadata["family_name"] = familyName
                    }

                    if let updatedUser = try? await supabaseClient.updateUserMetadata(
                        accessToken: authPayload.accessToken,
                        metadata: metadata
                    ) {
                        remoteUser = updatedUser
                    }
                }

                let session = Self.makeSession(
                    provider: .apple,
                    providerUserID: credential.user,
                    accessToken: authPayload.accessToken,
                    refreshToken: authPayload.refreshToken,
                    accessTokenExpiresAt: authPayload.accessTokenExpiresAt,
                    tokenType: authPayload.tokenType,
                    remoteUser: remoteUser,
                    previousSession: previous,
                    displayNameHint: formattedName,
                    providerEmail: credential.email,
                    fallbackName: store.onboardingProfile.fullName.trimmed,
                    fallbackEmail: store.onboardingProfile.email.trimmed
                )

                currentSession = session
                persistSession(session)
                store.applyAuthenticatedIdentity(displayName: session.displayName, email: session.email)
                await syncCloudDataIfPossible(store: store)
                errorMessage = ""
            } catch {
                errorMessage = (error as? LocalizedError)?.errorDescription ?? "Could not sign in with Supabase."
            }
        case .failure(let error):
            currentAppleNonce = nil

            if let authError = error as? ASAuthorizationError, authError.code == .canceled {
                return
            }

            errorMessage = error.localizedDescription
        }
    }

    func handleGoogleSignIn(store: SoulJourneyStore) async {
        guard let supabaseClient else {
            errorMessage = configurationMessage
            return
        }

        isAuthenticating = true
        defer {
            isAuthenticating = false
            activeWebAuthenticationSession = nil
        }

        let previous = currentSession

        do {
            let authorizeURL = try supabaseClient.makeOAuthAuthorizeURL(
                provider: "google",
                redirectTo: googleOAuthRedirectURL,
                queryParams: [
                    "access_type": "offline",
                    "prompt": "consent"
                ]
            )

            let callbackURL = try await beginOAuthSession(
                authorizeURL: authorizeURL,
                callbackScheme: googleOAuthRedirectURL.scheme ?? "onevisioon"
            )

            let tokens = try supabaseClient.sessionTokens(fromOAuthCallback: callbackURL)
            let remoteUser = try await supabaseClient.fetchUser(accessToken: tokens.accessToken)

            let session = Self.makeSession(
                provider: .google,
                providerUserID: remoteUser.metadataString(for: "sub") ?? remoteUser.id,
                accessToken: tokens.accessToken,
                refreshToken: tokens.refreshToken,
                accessTokenExpiresAt: tokens.accessTokenExpiresAt,
                tokenType: tokens.tokenType,
                remoteUser: remoteUser,
                previousSession: previous,
                displayNameHint: remoteUser.bestDisplayName,
                providerEmail: remoteUser.email,
                fallbackName: store.onboardingProfile.fullName.trimmed,
                fallbackEmail: store.onboardingProfile.email.trimmed
            )

            currentSession = session
            persistSession(session)
            store.applyAuthenticatedIdentity(displayName: session.displayName, email: session.email)
            await syncCloudDataIfPossible(store: store)
            errorMessage = ""
        } catch {
            if let authError = error as? ASWebAuthenticationSessionError, authError.code == .canceledLogin {
                return
            }

            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Could not sign in with Google."
        }
    }

    func refreshCredentialStateIfNeeded() async {
        guard var currentSession else { return }
        isRefreshingCredentialState = true
        defer { isRefreshingCredentialState = false }

        if currentSession.provider == .apple {
            let state = await credentialState(for: currentSession.providerUserID)

            switch state {
            case .authorized:
                break
            case .revoked, .notFound, .transferred:
                clearPersistedSession()
                errorMessage = "Your Apple sign-in needs to be refreshed."
                return
            default:
                break
            }
        }

        guard let supabaseClient, currentSession.isCloudBacked, currentSession.shouldRefreshSoon else {
            errorMessage = ""
            return
        }

        do {
            let refreshedPayload = try await supabaseClient.refreshSession(refreshToken: currentSession.refreshToken)
            var remoteUser = refreshedPayload.user

            if currentSession.displayName.trimmed.isEmpty || currentSession.email.trimmed.isEmpty {
                remoteUser = (try? await supabaseClient.fetchUser(accessToken: refreshedPayload.accessToken)) ?? remoteUser
            }

            let refreshedSession = Self.makeSession(
                provider: currentSession.provider,
                providerUserID: currentSession.providerUserID,
                accessToken: refreshedPayload.accessToken,
                refreshToken: refreshedPayload.refreshToken,
                accessTokenExpiresAt: refreshedPayload.accessTokenExpiresAt,
                tokenType: refreshedPayload.tokenType,
                remoteUser: remoteUser,
                previousSession: currentSession,
                displayNameHint: "",
                providerEmail: nil,
                fallbackName: "",
                fallbackEmail: ""
            )

            currentSession = refreshedSession
            self.currentSession = refreshedSession
            persistSession(refreshedSession)
            errorMessage = ""
        } catch {
            if let authError = error as? SupabaseAuthError, authError.shouldForceSignOut {
                clearPersistedSession()
                errorMessage = "Your cloud session expired. Please sign in again."
                return
            }

            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Could not refresh your cloud session right now."
        }
    }

    func signOut() {
        let session = currentSession
        clearPersistedSession()

        guard let session, session.isCloudBacked, let supabaseClient else {
            return
        }

        Task {
            try? await supabaseClient.signOut(accessToken: session.accessToken)
        }
    }

    private func loadPersistedSession() {
        guard let rawValue = try? KeychainStore.read(account: sessionKeychainAccount),
              let data = rawValue.data(using: .utf8) else {
            return
        }

        guard let session = try? JSONDecoder().decode(AuthUserSession.self, from: data) else {
            try? KeychainStore.delete(account: sessionKeychainAccount)
            return
        }

        currentSession = session
        lastCloudSyncAt = nil
    }

    private func persistSession(_ session: AuthUserSession) {
        guard let data = try? JSONEncoder().encode(session),
              let rawValue = String(data: data, encoding: .utf8) else {
            errorMessage = "The signed-in account could not be saved on this device."
            return
        }

        do {
            try KeychainStore.save(rawValue, account: sessionKeychainAccount)
        } catch {
            errorMessage = "The signed-in account could not be saved on this device."
        }
    }

    private func clearPersistedSession() {
        currentSession = nil
        currentAppleNonce = nil
        lastCloudSyncAt = nil
        errorMessage = ""

        do {
            try KeychainStore.delete(account: sessionKeychainAccount)
        } catch {
            errorMessage = "Signed out, but the saved session could not be fully cleared."
        }
    }

    private func credentialState(for userID: String) async -> ASAuthorizationAppleIDProvider.CredentialState {
        await withCheckedContinuation { continuation in
            appleProvider.getCredentialState(forUserID: userID) { state, _ in
                continuation.resume(returning: state)
            }
        }
    }

    func syncCloudDataIfPossible(store: SoulJourneyStore) async {
        guard let currentSession, let supabaseClient else { return }
        guard currentSession.isCloudBacked else { return }
        guard !isSyncingCloud else { return }

        isSyncingCloud = true
        defer { isSyncingCloud = false }

        do {
            let localSnapshot = store.exportSyncSnapshot()
            let remoteSnapshotRecord = try await supabaseClient.fetchUserSyncSnapshot(
                userID: currentSession.supabaseUserID,
                accessToken: currentSession.accessToken
            )

            if let remoteSnapshotRecord,
               shouldRestoreRemoteSnapshot(remoteSnapshotRecord.snapshot, over: localSnapshot) {
                store.applySyncSnapshot(remoteSnapshotRecord.snapshot)
            }

            let syncedProfile = try await supabaseClient.upsertProfile(
                accessToken: currentSession.accessToken,
                payload: makeProfilePayload(from: store, session: currentSession)
            )

            let snapshotToUpload = store.exportSyncSnapshot()
            _ = try await supabaseClient.upsertUserSyncSnapshot(
                accessToken: currentSession.accessToken,
                payload: SupabaseUserSyncSnapshotUpsertPayload(
                    userID: currentSession.supabaseUserID,
                    schemaVersion: snapshotToUpload.schemaVersion,
                    snapshot: snapshotToUpload
                )
            )

            var refreshedSession = currentSession
            let refreshedDisplayName = syncedProfile.displayName?.trimmed ?? ""
            let refreshedEmail = syncedProfile.email?.trimmed ?? ""

            if !refreshedDisplayName.isEmpty {
                refreshedSession.displayName = refreshedDisplayName
            }

            if !refreshedEmail.isEmpty {
                refreshedSession.email = refreshedEmail
            }

            self.currentSession = refreshedSession
            persistSession(refreshedSession)
            store.applyAuthenticatedIdentity(displayName: refreshedSession.displayName, email: refreshedSession.email)
            lastCloudSyncAt = .now
            errorMessage = ""
        } catch {
            if let authError = error as? SupabaseAuthError, authError.shouldForceSignOut {
                clearPersistedSession()
                errorMessage = "Your cloud session expired. Please sign in again."
                return
            }

            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Cloud sync could not finish right now."
        }
    }

    private func beginOAuthSession(authorizeURL: URL, callbackScheme: String) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            activeWebAuthenticationSession?.cancel()
            activeWebAuthenticationSession = nil

            let session = ASWebAuthenticationSession(
                url: authorizeURL,
                callbackURLScheme: callbackScheme
            ) { [weak self] callbackURL, error in
                Task { @MainActor in
                    self?.activeWebAuthenticationSession = nil

                    if let callbackURL {
                        continuation.resume(returning: callbackURL)
                        return
                    }

                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }

                    continuation.resume(throwing: SupabaseAuthError.invalidResponse)
                }
            }

            session.presentationContextProvider = authenticationPresentationContextProvider
            session.prefersEphemeralWebBrowserSession = false

            activeWebAuthenticationSession = session

            guard session.start() else {
                activeWebAuthenticationSession = nil
                continuation.resume(throwing: SupabaseAuthError.invalidResponse)
                return
            }
        }
    }

    private static func formattedName(from components: PersonNameComponents?) -> String {
        guard let components else { return "" }
        return PersonNameComponentsFormatter().string(from: components).trimmed
    }

    private func makeProfilePayload(from store: SoulJourneyStore, session: AuthUserSession) -> SupabaseProfileUpsertPayload {
        let profile = store.onboardingProfile
        let displayName = profile.fullName.trimmed.isEmpty ? session.displayName.trimmed : profile.fullName.trimmed
        let email = profile.email.trimmed.isEmpty ? session.email.trimmed : profile.email.trimmed
        let selectedVersion = profile.selectedVersion.trimmed.isEmpty ? nil : profile.selectedVersion.trimmed

        return SupabaseProfileUpsertPayload(
            id: session.supabaseUserID,
            email: email.isEmpty ? nil : email,
            displayName: displayName.isEmpty ? nil : displayName,
            handle: store.usernameHandle,
            bio: store.publicProfileSettings.testimonial.trimmed.isEmpty ? nil : store.publicProfileSettings.testimonial.trimmed,
            instagram: store.publicProfileSettings.instagram.trimmed.isEmpty ? nil : store.publicProfileSettings.instagram.trimmed,
            xHandle: store.publicProfileSettings.xHandle.trimmed.isEmpty ? nil : store.publicProfileSettings.xHandle.trimmed,
            youtube: store.publicProfileSettings.youtube.trimmed.isEmpty ? nil : store.publicProfileSettings.youtube.trimmed,
            country: profile.country.trimmed.isEmpty ? nil : profile.country.trimmed,
            usaAreaCode: profile.usaAreaCode.trimmed.isEmpty ? nil : profile.usaAreaCode.trimmed,
            smallGroupKey: store.preferredSmallGroupKey,
            avatarURL: nil,
            isPublic: store.publicProfileSettings.isPublic,
            selectedVersion: selectedVersion
        )
    }

    private func shouldRestoreRemoteSnapshot(_ remote: UserProgressSyncSnapshot, over local: UserProgressSyncSnapshot) -> Bool {
        guard snapshotHasMeaningfulContent(remote) else { return false }
        return !snapshotHasMeaningfulContent(local)
    }

    private func snapshotHasMeaningfulContent(_ snapshot: UserProgressSyncSnapshot) -> Bool {
        snapshot.onboardingCompleted
            || !snapshot.onboardingProfile.fullName.trimmed.isEmpty
            || !snapshot.onboardingProfile.email.trimmed.isEmpty
            || !snapshot.lessonProgressMap.isEmpty
            || !snapshot.chapterReflections.isEmpty
            || !snapshot.bibleVerseHighlights.isEmpty
            || !snapshot.bibleVerseNotes.isEmpty
            || !snapshot.activityDayKeys.isEmpty
            || snapshot.giftDiscoveryProfile != nil
            || !(snapshot.resetChallengeProgress?.completedDays.isEmpty ?? true)
            || snapshot.lastReadBibleLocation != nil
    }

    private static func resolveDisplayName(
        displayNameHint: String,
        remoteUser: SupabaseRemoteUser,
        previousSession: AuthUserSession?,
        fallbackName: String
    ) -> String {
        let candidates = [
            displayNameHint,
            remoteUser.bestDisplayName,
            previousSession?.displayName ?? "",
            fallbackName
        ]

        return candidates.first(where: { !$0.trimmed.isEmpty })?.trimmed ?? "One Visioon user"
    }

    private static func resolveEmail(
        providerEmail: String?,
        remoteUser: SupabaseRemoteUser,
        previousSession: AuthUserSession?,
        fallbackEmail: String
    ) -> String {
        let candidates = [
            providerEmail?.trimmed ?? "",
            remoteUser.email?.trimmed ?? "",
            previousSession?.email ?? "",
            fallbackEmail
        ]

        return candidates.first(where: { !$0.trimmed.isEmpty })?.trimmed ?? ""
    }

    private static func makeSession(
        provider: AuthProvider,
        providerUserID: String,
        accessToken: String,
        refreshToken: String,
        accessTokenExpiresAt: Date,
        tokenType: String,
        remoteUser: SupabaseRemoteUser,
        previousSession: AuthUserSession?,
        displayNameHint: String,
        providerEmail: String?,
        fallbackName: String,
        fallbackEmail: String
    ) -> AuthUserSession {
        let displayName = resolveDisplayName(
            displayNameHint: displayNameHint,
            remoteUser: remoteUser,
            previousSession: previousSession,
            fallbackName: fallbackName
        )

        let email = resolveEmail(
            providerEmail: providerEmail,
            remoteUser: remoteUser,
            previousSession: previousSession,
            fallbackEmail: fallbackEmail
        )

        return AuthUserSession(
            provider: provider,
            providerUserID: providerUserID,
            supabaseUserID: remoteUser.id,
            displayName: displayName,
            email: email,
            createdAt: previousSession?.createdAt ?? .now,
            lastSignInAt: .now,
            accessToken: accessToken,
            refreshToken: refreshToken,
            accessTokenExpiresAt: accessTokenExpiresAt,
            tokenType: tokenType
        )
    }

    private static func makeLocalAppleSession(
        credential: ASAuthorizationAppleIDCredential,
        previousSession: AuthUserSession?,
        displayNameHint: String,
        fallbackName: String,
        fallbackEmail: String
    ) -> AuthUserSession {
        let displayName = [
            displayNameHint,
            previousSession?.displayName ?? "",
            fallbackName
        ]
            .map(\.trimmed)
            .first(where: { !$0.isEmpty }) ?? ""

        let email = [
            credential.email?.trimmed ?? "",
            previousSession?.email ?? "",
            fallbackEmail
        ]
            .map(\.trimmed)
            .first(where: { !$0.isEmpty }) ?? ""

        return AuthUserSession(
            provider: .apple,
            providerUserID: credential.user,
            supabaseUserID: "local.apple.\(credential.user)",
            displayName: displayName,
            email: email,
            createdAt: previousSession?.createdAt ?? .now,
            lastSignInAt: .now,
            accessToken: "",
            refreshToken: "",
            accessTokenExpiresAt: .distantFuture,
            tokenType: "apple-local"
        )
    }

    private static func makeOAuthRedirectURL() -> URL {
        let scheme = Bundle.main.bundleIdentifier?.trimmed.isEmpty == false
            ? Bundle.main.bundleIdentifier!.trimmed
            : "onevisioon"

        return URL(string: "\(scheme)://auth")!
    }

    private static func randomNonceString(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            var randomBytes = [UInt8](repeating: 0, count: 16)
            let status = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)

            guard status == errSecSuccess else {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with status \(status).")
            }

            randomBytes.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private static func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hashedData = SHA256.hash(data: data)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }
}

private final class AuthenticationPresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }

        if let window = scenes
            .flatMap(\.windows)
            .first(where: \.isKeyWindow) {
            return window
        }

        if let scene = scenes.first {
            return ASPresentationAnchor(windowScene: scene)
        }

        preconditionFailure("A window scene is required to present authentication.")
    }
}
