import SwiftUI

private enum MainTab: Hashable {
    case home
    case glorify
    case bible
    case lessons
    case chat
}

private enum AppDeepLinkDestination: Hashable {
    case bible(BibleReferenceTarget)

    init?(url: URL) {
        let allowedScheme = "vsn.onevisioon"
        guard url.scheme?.lowercased() == allowedScheme else { return nil }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let host = (components?.host ?? "").lowercased()
        let referenceValue = components?.queryItems?.first(where: { $0.name == "ref" })?.value

        switch host {
        case "bible", "daily-verse":
            if let referenceValue,
               let target = BibleDataProvider.resolveReference(from: referenceValue) {
                self = .bible(target)
                return
            }

            if let dailyVerse = BibleDataProvider.dailyVerse() {
                self = .bible(
                    BibleReferenceTarget(
                        location: dailyVerse.location,
                        verse: dailyVerse.verse.verse
                    )
                )
                return
            }

            return nil
        default:
            return nil
        }
    }
}

struct ContentView: View {
    @StateObject private var store = SoulJourneyStore()
    @StateObject private var accessManager = SubscriptionAccessManager()
    @StateObject private var authManager = AuthSessionManager()
    @Environment(\.scenePhase) private var scenePhase
    @State private var pendingDeepLink: AppDeepLinkDestination?

    var body: some View {
        Group {
            if !store.onboardingCompleted {
                OnboardingView(store: store, accessManager: accessManager)
            } else {
                MainTabView(
                    store: store,
                    accessManager: accessManager,
                    pendingDeepLink: $pendingDeepLink
                )
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .environmentObject(store)
        .environmentObject(authManager)
        .animation(.spring(response: 0.46, dampingFraction: 0.86), value: store.onboardingCompleted)
        .task {
            await accessManager.refreshAccessState()
            await authManager.refreshCredentialStateIfNeeded()
            await authManager.syncCloudDataIfPossible(store: store)
            await GlorifyReminderService.refreshMorningQuotesIfNeeded(using: store.glorifyReminderSettings)
            syncPreviewAccess()
            trackTodayIfUnlocked()
        }
        .task(id: authManager.currentSession?.id) {
            await authManager.syncCloudDataIfPossible(store: store)
        }
        .onChange(of: authManager.lastCloudSyncAt) { _, newValue in
            guard newValue != nil else { return }
            guard store.requiresPostPurchaseAccountLink else { return }
            guard authManager.isSignedIn else { return }
            store.completePostPurchaseAccountLink()
        }
        .task(id: store.cloudSyncRevision) {
            guard authManager.isSignedIn else { return }
            try? await Task.sleep(nanoseconds: 900_000_000)
            await authManager.syncCloudDataIfPossible(store: store)
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            Task {
                await accessManager.refreshAccessState()
                await authManager.refreshCredentialStateIfNeeded()
                await authManager.syncCloudDataIfPossible(store: store)
                await GlorifyReminderService.refreshMorningQuotesIfNeeded(using: store.glorifyReminderSettings)
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
        .onOpenURL { url in
            guard let destination = AppDeepLinkDestination(url: url) else { return }
            pendingDeepLink = destination
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
    @Binding var pendingDeepLink: AppDeepLinkDestination?
    @EnvironmentObject private var authManager: AuthSessionManager

    @State private var selectedTab: MainTab = .home
    @State private var glorifyRoute: GlorifyRoute?
    @State private var bibleDeepLinkTarget: BibleReferenceTarget?
    @State private var showAccountSetupProfile = false

    private var showsAccountSetupLock: Bool {
        store.requiresPostPurchaseAccountLink && !authManager.isSignedIn
    }

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                ScriptureHomeView(
                    store: store,
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

                FullBibleView(store: store, externalTarget: $bibleDeepLinkTarget)
                    .tabItem {
                        Label("Bible", systemImage: "book.closed.fill")
                    }
                    .tag(MainTab.bible)

                LessonLibraryView(store: store)
                    .tabItem {
                        Label("Lessons", systemImage: "bookmark.fill")
                    }
                    .tag(MainTab.lessons)

                PrayerFeedView(store: store)
                    .tabItem {
                        Label("Chat", systemImage: "bubble.left.and.bubble.right.fill")
                    }
                    .tag(MainTab.chat)
            }
            .blur(radius: showsAccountSetupLock ? 3.5 : 0)
            .allowsHitTesting(!showsAccountSetupLock)

            if showsAccountSetupLock {
                PremiumAccountSetupLockView {
                    showAccountSetupProfile = true
                }
                .transition(.opacity.combined(with: .scale(scale: 1.02)))
            }
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .tint(OVTheme.midnight)
        .toolbarBackground(OVTheme.tabBarBackground, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.light, for: .tabBar)
        .sheet(isPresented: $showAccountSetupProfile) {
            NavigationStack {
                ProfileView(store: store, showsInfoButton: false, showsDismissButton: true)
            }
            .environmentObject(authManager)
            .environmentObject(store)
        }
        .onAppear {
            consumePendingDeepLinkIfNeeded()
        }
        .onChange(of: pendingDeepLink) { _, _ in
            consumePendingDeepLinkIfNeeded()
        }
    }

    private func consumePendingDeepLinkIfNeeded() {
        guard let pendingDeepLink else { return }

        switch pendingDeepLink {
        case .bible(let target):
            selectedTab = .bible
            bibleDeepLinkTarget = target
        }

        self.pendingDeepLink = nil
    }
}

private struct PremiumAccountSetupLockView: View {
    let openProfile: () -> Void
    @State private var isPulsing = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.opacity(0.46)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer()

                VStack(spacing: 14) {
                    Text("Finish setting up your account")
                        .font(OVTheme.display(30))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("Your purchase is ready. Link Apple or Google now so your membership and progress save under your account.")
                        .font(OVTheme.body(15))
                        .foregroundStyle(Color.white.opacity(0.86))
                        .multilineTextAlignment(.center)

                    Text("You only need to do this once.")
                        .font(OVTheme.body(13))
                        .foregroundStyle(OVTheme.gold)

                    Button(action: openProfile) {
                        Text("Open Profile")
                            .font(OVTheme.heading(16))
                            .foregroundStyle(OVTheme.midnight)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(24)
                .premiumSurfaceCard(cornerRadius: 28, fill: Color(hex: "171B24").opacity(0.98), shadowOpacity: 0.16)

                Spacer()
            }
            .padding(.horizontal, OVTheme.screenHorizontalPadding)
            .padding(.bottom, 72)

            Button(action: openProfile) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.16))
                        .frame(width: 68, height: 68)
                        .scaleEffect(isPulsing ? 1.14 : 0.92)

                    LogoMark(size: 38, cornerRadius: 10)
                        .shadow(color: OVTheme.gold.opacity(0.45), radius: isPulsing ? 18 : 8)
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 18)
            .padding(.trailing, 18)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.15).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
