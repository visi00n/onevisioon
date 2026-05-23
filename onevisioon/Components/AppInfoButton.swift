import SwiftUI

struct AppInfoButton: View {
    @EnvironmentObject private var authManager: AuthSessionManager
    @EnvironmentObject private var store: SoulJourneyStore
    @State private var showProfile = false
    @State private var isHighlighting = false

    private var shouldHighlight: Bool {
        store.requiresPostPurchaseAccountLink && !authManager.isSignedIn
    }

    var body: some View {
        Button {
            showProfile = true
        } label: {
            LogoMark(size: 30, cornerRadius: 8)
                .overlay {
                    if shouldHighlight {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(OVTheme.gold.opacity(0.95), lineWidth: 1.5)
                            .padding(-4)
                            .shadow(color: OVTheme.gold.opacity(isHighlighting ? 0.55 : 0.2), radius: isHighlighting ? 18 : 6)
                            .scaleEffect(isHighlighting ? 1.08 : 0.96)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Profile")
        .sheet(isPresented: $showProfile) {
            if shouldHighlight {
                NavigationStack {
                    ProfileView(store: store, showsInfoButton: false, showsDismissButton: true)
                }
                .environmentObject(authManager)
                .environmentObject(store)
            } else {
                OneVisioonHubView(store: store)
                    .environmentObject(authManager)
                    .environmentObject(store)
            }
        }
        .onAppear {
            guard shouldHighlight else { return }
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                isHighlighting = true
            }
        }
        .onChange(of: shouldHighlight) { _, newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                    isHighlighting = true
                }
            } else {
                isHighlighting = false
            }
        }
    }
}
