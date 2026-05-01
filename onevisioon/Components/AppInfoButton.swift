import SwiftUI

struct AppInfoButton: View {
    @State private var showAbout = false

    var body: some View {
        Button {
            showAbout = true
        } label: {
            LogoMark(size: 30, cornerRadius: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("About One Visioon")
        .sheet(isPresented: $showAbout) {
            OneVisioonAboutSheet()
        }
    }
}

private struct OneVisioonAboutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authManager: AuthSessionManager
    @EnvironmentObject private var store: SoulJourneyStore
    @State private var showPrivacyPolicy = false
    @State private var showAccount = false

    private let instagramURL = URL(string: "https://www.instagram.com/one.visioon/")!
    private let discordURL = URL(string: "https://discord.gg/W7M4zGPtqV")!

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("One Visioon")
                            .font(OVTheme.heading(28))
                            .foregroundStyle(OVTheme.ink)

                        Text("Understand Scripture. Grow with Christ.")
                            .font(OVTheme.body(16))
                            .foregroundStyle(OVTheme.ink.opacity(0.78))
                    }
                    .frame(maxWidth: .infinity, minHeight: 124, alignment: .topLeading)
                    .padding(20)
                    .background(OVTheme.elevatedCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(OVTheme.line, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                    VStack(alignment: .leading, spacing: 8) {
                        infoLine("Mission", "Help people understand God's Word one chapter at a time, reflect deeply, and grow with Christ in real community.")
                        infoLine("Coming next", "Life-situation study guides, Bible in a Year depth, and stronger Bible School paths.")
                    }
                    .frame(maxWidth: .infinity, minHeight: 124, alignment: .topLeading)
                    .padding(16)
                    .background(OVTheme.elevatedCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(OVTheme.line, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                    VStack(spacing: 10) {
                        Button {
                            showAccount = true
                        } label: {
                            actionButtonLabel(
                                title: "Account",
                                subtitle: authManager.isSignedIn ? "Signed in with Apple" : "Sign in with Apple"
                            )
                        }
                        .buttonStyle(.plain)

                        Button {
                            showPrivacyPolicy = true
                        } label: {
                            actionButtonLabel(title: "Privacy Policy", subtitle: "Read the in-app policy")
                        }
                        .buttonStyle(.plain)

                        Link(destination: instagramURL) {
                            actionButtonLabel(title: "Instagram", subtitle: "@one.visioon")
                        }
                        .buttonStyle(.plain)

                        Link(destination: discordURL) {
                            actionButtonLabel(title: "Discord", subtitle: "Join the community")
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(OVTheme.body(15))
                }
            }
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            OneVisioonPrivacyPolicySheet()
        }
        .sheet(isPresented: $showAccount) {
            AccountCenterView()
                .environmentObject(authManager)
                .environmentObject(store)
        }
    }

    private func infoLine(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(OVTheme.body(11))
                .foregroundStyle(OVTheme.muted)
            Text(value)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink)
        }
    }

    private func actionButtonLabel(title: String, subtitle: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(OVTheme.heading(15))
                    .foregroundStyle(OVTheme.midnight)
                Text(subtitle)
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.muted)
            }
            Spacer()
            Image(systemName: "arrow.up.right")
                .foregroundStyle(OVTheme.midnight)
        }
        .frame(maxWidth: .infinity, minHeight: 62, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(OVTheme.elevatedCard)
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct OneVisioonPrivacyPolicySheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    policySection(
                        title: "What One Visioon Stores",
                        body: "One Visioon stores your reading progress, streaks, highlights, notes, reflections, onboarding answers, and version choice on your device so the app can remember your place and your study history."
                    )

                    policySection(
                        title: "Account Sign-In",
                        body: "This version can sign you in with Apple. If you use that button, One Visioon stores your Apple user identifier and any name or email Apple shares on your device so the app can remember your account here."
                    )

                    policySection(
                        title: "Progress Storage",
                        body: "Your progress, notes, highlights, reflections, and streaks currently stay on this device. Cross-device sync is not live in this build yet."
                    )

                    policySection(
                        title: "External Links",
                        body: "If you tap Instagram or Discord, you leave the app and continue under those services and their privacy policies."
                    )
                }
                .padding(20)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(OVTheme.body(15))
                }
            }
        }
    }

    private func policySection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(OVTheme.heading(18))
                .foregroundStyle(OVTheme.midnight)

            Text(body)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.8))
        }
        .padding(18)
        .background(OVTheme.elevatedCard)
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
