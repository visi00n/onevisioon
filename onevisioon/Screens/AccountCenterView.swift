import AuthenticationServices
import SwiftUI

struct AccountCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var authManager: AuthSessionManager
    @EnvironmentObject private var store: SoulJourneyStore
    @State private var showsDeleteConfirmation = false

    private var syncSnapshot: UserProgressSyncSnapshot {
        store.exportSyncSnapshot()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    accountHero
                    liveStatusCard
                    snapshotCard
                    progressSnapshotCard
                    legalAndSafetyCard
                }
                .padding(20)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(OVTheme.body(15))
                }
            }
            .task {
                await authManager.refreshCredentialStateIfNeeded()
            }
        }
    }

    private var accountHero: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sign in with Apple")
                .font(OVTheme.heading(28))
                .foregroundStyle(OVTheme.midnight)

            Text(authManager.isCloudConfigured
                ? "Sign in with Apple connects your One Visioon account to Supabase so your profile and study progress can sync securely."
                : "Apple sign-in now saves your One Visioon account on this device. Add Supabase config when you are ready for cloud sync.")
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.74))
                .lineSpacing(3)
        }
        .padding(20)
        .background(OVTheme.elevatedCard)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var liveStatusCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Live now")
                    .font(OVTheme.heading(20))
                    .foregroundStyle(OVTheme.ink)

                Spacer()

                statusPill(
                    authManager.isSignedIn
                        ? (authManager.isAuthenticating ? "Connecting" : "Signed in")
                        : (authManager.isCloudConfigured ? "Cloud ready" : "Apple ready"),
                    tint: authManager.isSignedIn ? OVTheme.mint : (authManager.isCloudConfigured ? OVTheme.sky : OVTheme.gold.opacity(0.78))
                )
            }

            Text(authManager.backendStatus.title)
                .font(OVTheme.heading(15))
                .foregroundStyle(OVTheme.midnight)

            Text(authManager.backendStatus.detail)
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.72))

            if let session = authManager.currentSession {
                VStack(alignment: .leading, spacing: 8) {
                    accountMetric("Provider", session.providerTitle)
                    accountMetric("Name", session.displayTitle)

                    if !session.email.trimmed.isEmpty {
                        accountMetric("Email", session.email)
                    }

                    accountMetric("Sync status", authManager.syncStatusLine)
                }

                if !authManager.errorMessage.isEmpty {
                    helperMessage(authManager.errorMessage, tint: OVTheme.coral)
                }

                Button(role: .destructive) {
                    authManager.signOut()
                } label: {
                    Text("Sign out")
                        .font(OVTheme.heading(15))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(OVTheme.coral)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            } else {
                Text(authManager.isCloudConfigured
                    ? "Use Apple to open a secure account session and back up your study progress to the cloud."
                    : "Use Apple to save this account on your device. Cloud backup will appear once Supabase is configured.")
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.72))

                if authManager.canStartAppleSignIn {
                    SignInWithAppleButton(.continue) { request in
                        authManager.configureAppleRequest(request)
                    } onCompletion: { result in
                        Task {
                            await authManager.handleAppleSignIn(result: result, store: store)
                        }
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 52)
                    .clipShape(Capsule())
                    .disabled(authManager.isAuthenticating)
                    .opacity(authManager.isAuthenticating ? 0.7 : 1)
                }

            }
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var snapshotCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cloud sync")
                .font(OVTheme.heading(20))
                .foregroundStyle(OVTheme.ink)

            Text("When you are signed in, One Visioon can sync your key study data with Supabase and keep a local copy on this device too.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))

            VStack(alignment: .leading, spacing: 8) {
                backendBullet("Lesson progress and completed chapters")
                backendBullet("Reflections, notes, and verse highlights")
                backendBullet("Streaks, active days, and last read chapter")
                backendBullet(authManager.isCloudConfigured ? "Supabase-backed Apple account session" : "Local Apple account session until Supabase is configured")
            }

            HStack(spacing: 8) {
                statusPill("Supabase auth", tint: OVTheme.mint.opacity(0.78))
                statusPill("Progress sync", tint: OVTheme.sky.opacity(0.72))
            }
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var progressSnapshotCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current totals")
                .font(OVTheme.heading(20))
                .foregroundStyle(OVTheme.ink)

            Text("A quick look at the study data currently saved inside the app.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))

            VStack(alignment: .leading, spacing: 8) {
                accountMetric("Completed lessons", "\(syncSnapshot.lessonProgressMap.values.filter(\.lessonCompleted).count)")
                accountMetric("Reflections", "\(syncSnapshot.chapterReflections.count)")
                accountMetric("Bible notes", "\(syncSnapshot.bibleVerseNotes.count)")
                accountMetric("Highlights", "\(syncSnapshot.bibleVerseHighlights.count)")
                accountMetric("Active days", "\(syncSnapshot.activityDayKeys.count)")
            }
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var legalAndSafetyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Legal & data safety")
                .font(OVTheme.heading(20))
                .foregroundStyle(OVTheme.ink)

            Text("You can review One Visioon's public policies and start an account/data deletion request anytime.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))

            Link("Privacy Policy", destination: URL(string: "https://unovisioon.com/privacy-policy")!)
                .font(OVTheme.heading(14))
                .foregroundStyle(OVTheme.midnight)

            Link("Support", destination: URL(string: "https://unovisioon.com/support")!)
                .font(OVTheme.heading(14))
                .foregroundStyle(OVTheme.midnight)

            Link("Terms of Use", destination: URL(string: "https://unovisioon.com/terms")!)
                .font(OVTheme.heading(14))
                .foregroundStyle(OVTheme.midnight)

            Button(role: .destructive) {
                showsDeleteConfirmation = true
            } label: {
                Text("Delete account and local data")
                    .font(OVTheme.heading(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(OVTheme.coral)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .confirmationDialog(
            "Delete account and local data?",
            isPresented: $showsDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete local data and email support", role: .destructive) {
                requestAccountDeletion()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This signs you out, clears saved app data on this device, and opens an email so support can delete any cloud account records.")
        }
    }

    private func requestAccountDeletion() {
        let email = authManager.currentSession?.email.trimmed ?? store.onboardingProfile.email.trimmed
        authManager.signOut()
        store.deleteLocalUserData()

        var components = URLComponents()
        components.scheme = "mailto"
        components.path = "uvisioon@gmail.com"
        components.queryItems = [
            URLQueryItem(name: "subject", value: "One Visioon account deletion request"),
            URLQueryItem(
                name: "body",
                value: "Please delete my One Visioon account and associated cloud data.\n\nAccount email or Apple relay email: \(email)\n\nI understand local data on this device has been cleared."
            )
        ]

        if let url = components.url {
            openURL(url)
        }
    }

    private func statusPill(_ title: String, tint: Color) -> some View {
        Text(title)
            .font(OVTheme.body(11))
            .foregroundStyle(OVTheme.midnight)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint)
            .clipShape(Capsule())
    }

    private func accountMetric(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.68))

            Spacer()

            Text(value)
                .font(OVTheme.heading(13))
                .foregroundStyle(OVTheme.midnight)
        }
    }

    private func backendBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(OVTheme.gold)
                .frame(width: 6, height: 6)
                .padding(.top, 6)

            Text(text)
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.74))
        }
    }

    private func helperMessage(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(OVTheme.body(12))
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(tint.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
