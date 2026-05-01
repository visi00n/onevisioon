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
            Text("Sign in with Apple")
                .font(OVTheme.heading(28))
                .foregroundStyle(OVTheme.midnight)

            Text("Apple sign-in is live now. It gives you a clean, secure account identity inside the app while your study progress keeps saving on this device.")
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
                    authManager.isSignedIn ? "Signed in" : "Not signed in",
                    tint: authManager.isSignedIn ? OVTheme.mint : OVTheme.sand
                )
            }

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
                Text("Use Apple's secure button first. It saves your account on this device and fills in your name or email when Apple shares it.")
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.72))

                SignInWithAppleButton(.continue) { request in
                    authManager.configureAppleRequest(request)
                } onCompletion: { result in
                    authManager.handleAppleSignIn(result: result, store: store)
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 52)
                .clipShape(Capsule())
            }
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var snapshotCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Saved on this device")
                .font(OVTheme.heading(20))
                .foregroundStyle(OVTheme.ink)

            Text("This is the progress One Visioon is already keeping locally while Apple sign-in handles your account identity.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))

            VStack(alignment: .leading, spacing: 8) {
                backendBullet("Lesson progress and completed chapters")
                backendBullet("Reflections, notes, and verse highlights")
                backendBullet("Streaks, active days, and last read chapter")
                backendBullet("Apple account identity remembered securely on this device")
            }

            HStack(spacing: 8) {
                statusPill("Apple live", tint: OVTheme.mint.opacity(0.78))
                statusPill("Local progress", tint: OVTheme.sky.opacity(0.72))
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
