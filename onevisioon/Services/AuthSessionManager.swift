import AuthenticationServices
import Combine
import Foundation

@MainActor
final class AuthSessionManager: ObservableObject {
    @Published private(set) var currentSession: AuthUserSession?
    @Published private(set) var backendStatus: AuthBackendStatus = .localAppleReady
    @Published var isRefreshingCredentialState = false
    @Published var errorMessage = ""

    private let appleProvider = ASAuthorizationAppleIDProvider()
    private let sessionKeychainAccount = "auth_user_session"

    init() {
        loadPersistedSession()
    }

    var isSignedIn: Bool {
        currentSession != nil
    }

    var syncStatusLine: String {
        currentSession == nil ? "Local progress only for now" : "Account remembered on this device"
    }

    func configureAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }

    func handleAppleSignIn(result: Result<ASAuthorization, Error>, store: SoulJourneyStore) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                errorMessage = "Apple sign-in returned an unexpected credential."
                return
            }

            let formattedName = Self.formattedName(from: credential.fullName)
            let previous = currentSession
            let displayName = formattedName.isEmpty
                ? previous?.displayName ?? store.onboardingProfile.fullName.trimmed
                : formattedName
            let email = credential.email ?? previous?.email ?? store.onboardingProfile.email.trimmed

            let session = AuthUserSession(
                provider: .apple,
                providerUserID: credential.user,
                displayName: displayName,
                email: email,
                createdAt: previous?.createdAt ?? .now,
                lastSignInAt: .now
            )

            currentSession = session
            persistSession(session)
            store.applyAuthenticatedIdentity(displayName: displayName, email: email)
            errorMessage = ""
        case .failure(let error):
            if let authError = error as? ASAuthorizationError, authError.code == .canceled {
                return
            }

            errorMessage = error.localizedDescription
        }
    }

    func refreshCredentialStateIfNeeded() async {
        guard let currentSession, currentSession.provider == .apple else { return }
        isRefreshingCredentialState = true
        defer { isRefreshingCredentialState = false }

        let state = await credentialState(for: currentSession.providerUserID)

        switch state {
        case .authorized:
            errorMessage = ""
        case .revoked, .notFound, .transferred:
            signOut()
            errorMessage = "Your Apple sign-in needs to be refreshed."
        default:
            break
        }
    }

    func signOut() {
        currentSession = nil
        errorMessage = ""

        do {
            try KeychainStore.delete(account: sessionKeychainAccount)
        } catch {
            errorMessage = "Signed out, but the saved session could not be fully cleared."
        }
    }

    private func loadPersistedSession() {
        guard let rawValue = try? KeychainStore.read(account: sessionKeychainAccount),
              let data = rawValue.data(using: .utf8),
              let session = try? JSONDecoder().decode(AuthUserSession.self, from: data) else {
            return
        }

        currentSession = session
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

    private func credentialState(for userID: String) async -> ASAuthorizationAppleIDProvider.CredentialState {
        await withCheckedContinuation { continuation in
            appleProvider.getCredentialState(forUserID: userID) { state, _ in
                continuation.resume(returning: state)
            }
        }
    }

    private static func formattedName(from components: PersonNameComponents?) -> String {
        guard let components else { return "" }
        return PersonNameComponentsFormatter().string(from: components).trimmed
    }
}
