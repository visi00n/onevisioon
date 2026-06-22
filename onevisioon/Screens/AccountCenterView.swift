import AuthenticationServices
import SwiftUI

struct AccountCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authManager: AuthSessionManager
    @EnvironmentObject private var store: SoulJourneyStore

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
            Text(authManager.isCloudConfigured ? "Sign in with Apple or Google" : "Sign in with Apple")
                .font(OVTheme.heading(28))
                .foregroundStyle(OVTheme.midnight)

            Text(authManager.isCloudConfigured
                ? "Apple and Google sign-in connect your One Visioon account to Supabase so your profile and study progress can sync securely."
                : "Apple sign-in now saves your One Visioon account on this device. Add Supabase config when you are ready for Google sign-in and cloud sync.")
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
                    ? "Use Apple or Google to open a secure account session and back up your study progress to the cloud."
                    : "Use Apple to save this account on your device. Google and cloud backup will appear once Supabase is configured.")
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

                if authManager.canStartGoogleSignIn {
                    GoogleAuthButton(
                        title: "Continue with Google",
                        isLoading: authManager.isAuthenticating
                    ) {
                        Task {
                            await authManager.handleGoogleSignIn(store: store)
                        }
                    }
                    .disabled(authManager.isAuthenticating)
                    .opacity(authManager.isAuthenticating ? 0.7 : 1)
                } else {
                    helperMessage("Google sign-in and cloud backup unlock after Supabase config is added.", tint: OVTheme.gold)
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
                backendBullet(authManager.isCloudConfigured ? "Supabase-backed Apple or Google account session" : "Local Apple account session until Supabase is configured")
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
