import SwiftUI

private enum MainTab: Hashable {
    case home
    case glorify
    case lessons
    case quests
    case bible
}

struct ContentView: View {
    @StateObject private var store = SoulJourneyStore()
    @StateObject private var accessManager = SubscriptionAccessManager()
    @StateObject private var authManager = AuthSessionManager()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if !store.onboardingCompleted {
                OnboardingView(store: store, accessManager: accessManager)
            } else {
                MainTabView(store: store, accessManager: accessManager)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .environmentObject(store)
        .environmentObject(authManager)
        .animation(.spring(response: 0.46, dampingFraction: 0.86), value: store.onboardingCompleted)
        .task {
            await accessManager.refreshAccessState()
            await authManager.refreshCredentialStateIfNeeded()
            syncPreviewAccess()
            trackTodayIfUnlocked()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            Task {
                await accessManager.refreshAccessState()
                await authManager.refreshCredentialStateIfNeeded()
                syncPreviewAccess()
                trackTodayIfUnlocked()
            }
        }
        .onChange(of: store.onboardingCompleted) { _, _ in
            syncPreviewAccess()
            trackTodayIfUnlocked()
        }
        .onChange(of: store.onboardingProfile.selectedVersion) { _, _ in
            syncPreviewAccess()
        }
    }

    private func trackTodayIfUnlocked() {
        guard store.onboardingCompleted else { return }
        store.markActiveToday()
    }

    private func syncPreviewAccess() {
        accessManager.setPreviewSelection(store.onboardingProfile.selectedVersion)
    }
}

private struct MainTabView: View {
    @ObservedObject var store: SoulJourneyStore
    @ObservedObject var accessManager: SubscriptionAccessManager

    @State private var selectedTab: MainTab = .home
    @State private var glorifyRoute: GlorifyRoute?

    var body: some View {
        TabView(selection: $selectedTab) {
            ScriptureHomeView(
                store: store,
                accessManager: accessManager,
                openGlorifyGifts: {
                    selectedTab = .glorify
                    glorifyRoute = .discoverGifts
                }
            )
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(MainTab.home)

            GlorifyView(store: store, accessManager: accessManager, jumpTarget: $glorifyRoute)
                .tabItem {
                    Label("Glorify", systemImage: "sparkles")
                }
                .tag(MainTab.glorify)

            LessonLibraryView(store: store, accessManager: accessManager)
                .tabItem {
                    Label("Lessons", systemImage: "bookmark.fill")
                }
                .tag(MainTab.lessons)

            QuestCenterView(store: store, accessManager: accessManager)
                .tabItem {
                    Label("Quests", systemImage: "checklist.checked")
                }
                .tag(MainTab.quests)

            FullBibleView(store: store)
                .tabItem {
                    Label("Bible", systemImage: "book.closed")
                }
                .tag(MainTab.bible)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .tint(OVTheme.midnight)
        .toolbarBackground(OVTheme.tabBarBackground, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.light, for: .tabBar)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
