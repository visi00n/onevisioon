import SwiftUI
import UIKit

private enum MainTab: String, CaseIterable, Identifiable, Hashable {
    case home
    case glorify
    case bible
    case lessons
    case chat

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home:
            return "Home"
        case .glorify:
            return "Glorify"
        case .bible:
            return "Bible"
        case .lessons:
            return "Lessons"
        case .chat:
            return "Chat"
        }
    }

    var tutorialSlides: [HubTutorialSlide] {
        [
            HubTutorialSlide(imageName: "\(rawValue)1tut", fallbackTitle: "\(title) tutorial"),
            HubTutorialSlide(imageName: "\(rawValue)2tut", fallbackTitle: "\(title) tools"),
            HubTutorialSlide(imageName: "\(rawValue)3tut", fallbackTitle: "\(title) next step")
        ]
    }
}

private struct HubTutorialSlide: Identifiable, Hashable {
    let imageName: String
    let fallbackTitle: String

    var id: String { imageName }
}

private enum HubTutorialDefaults {
    private static let maxDeclines = 3

    static func shouldPrompt(for tab: MainTab) -> Bool {
        !UserDefaults.standard.bool(forKey: completedKey(for: tab))
            && UserDefaults.standard.integer(forKey: declinedKey(for: tab)) < maxDeclines
    }

    static func markCompleted(_ tab: MainTab) {
        UserDefaults.standard.set(true, forKey: completedKey(for: tab))
    }

    static func recordDecline(_ tab: MainTab) {
        let key = declinedKey(for: tab)
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: key) + 1, forKey: key)
    }

    private static func completedKey(for tab: MainTab) -> String {
        "ov_tutorial_completed_\(tab.rawValue)"
    }

    private static func declinedKey(for tab: MainTab) -> String {
        "ov_tutorial_declined_count_\(tab.rawValue)"
    }
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
            await syncCloudDataRespectingAccess()
            await GlorifyReminderService.refreshMorningQuotesIfNeeded(using: store.glorifyReminderSettings)
            syncPreviewAccess()
            trackTodayIfUnlocked()
        }
        .task(id: authManager.currentSession?.id) {
            await syncCloudDataRespectingAccess()
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
            await syncCloudDataRespectingAccess()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            Task {
                await accessManager.refreshAccessState()
                await authManager.refreshCredentialStateIfNeeded()
                await syncCloudDataRespectingAccess()
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

    private func syncCloudDataRespectingAccess() async {
        await authManager.syncCloudDataIfPossible(
            store: store,
            allowsRemoteOnboardingCompletion: store.onboardingCompleted
                || accessManager.hasAccess
                || accessManager.isPreviewModeActive
        )
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
    @State private var tutorialPromptTab: MainTab?
    @State private var activeTutorialTab: MainTab?

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
                    },
                    openProfile: {
                        showAccountSetupProfile = true
                    }
                )
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(MainTab.home)

                GlorifyView(store: store, jumpTarget: $glorifyRoute)
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

            if let tutorialPromptTab, !showsAccountSetupLock {
                HubTutorialPromptBanner(
                    tab: tutorialPromptTab,
                    onStart: {
                        startTutorial(for: tutorialPromptTab)
                    },
                    onDecline: {
                        declineTutorial(for: tutorialPromptTab)
                    }
                )
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .frame(maxHeight: .infinity, alignment: .top)
                .transition(.move(edge: .top).combined(with: .opacity))
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
        .fullScreenCover(item: $activeTutorialTab) { tab in
            HubTutorialSlideshowView(tab: tab) {
                completeTutorial(for: tab)
            }
        }
        .onAppear {
            consumePendingDeepLinkIfNeeded()
            presentTutorialPromptIfNeeded(for: selectedTab, delay: 0.55)
        }
        .onChange(of: pendingDeepLink) { _, _ in
            consumePendingDeepLinkIfNeeded()
        }
        .onChange(of: selectedTab) { _, newTab in
            tutorialPromptTab = nil
            presentTutorialPromptIfNeeded(for: newTab, delay: 0.35)
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

    private func presentTutorialPromptIfNeeded(for tab: MainTab, delay: TimeInterval = 0) {
        guard activeTutorialTab == nil,
              !showsAccountSetupLock,
              HubTutorialDefaults.shouldPrompt(for: tab) else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard selectedTab == tab,
                  activeTutorialTab == nil,
                  !showsAccountSetupLock,
                  HubTutorialDefaults.shouldPrompt(for: tab) else { return }

            withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
                tutorialPromptTab = tab
            }
        }
    }

    private func startTutorial(for tab: MainTab) {
        withAnimation(.easeOut(duration: 0.2)) {
            tutorialPromptTab = nil
        }
        activeTutorialTab = tab
    }

    private func declineTutorial(for tab: MainTab) {
        HubTutorialDefaults.recordDecline(tab)
        withAnimation(.easeOut(duration: 0.2)) {
            tutorialPromptTab = nil
        }
    }

    private func completeTutorial(for tab: MainTab) {
        HubTutorialDefaults.markCompleted(tab)
        activeTutorialTab = nil
    }
}

private struct HubTutorialPromptBanner: View {
    let tab: MainTab
    let onStart: () -> Void
    let onDecline: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(OVTheme.midnight)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text("Take the \(tab.title) tutorial?")
                    .font(OVTheme.heading(16))
                    .foregroundStyle(OVTheme.ink)

                Text("A quick visual walkthrough for this hub.")
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.muted)
            }

            Spacer(minLength: 8)

            HStack(spacing: 8) {
                Button("No", action: onDecline)
                    .font(OVTheme.heading(13))
                    .foregroundStyle(OVTheme.muted)

                Button("Yes", action: onStart)
                    .font(OVTheme.heading(13))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(OVTheme.midnight)
                    .clipShape(Capsule())
            }
        }
        .padding(14)
        .background(OVTheme.elevatedCard)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 18, x: 0, y: 10)
    }
}

private struct HubTutorialSlideshowView: View {
    let tab: MainTab
    let onComplete: () -> Void

    @State private var index = 0

    private var slides: [HubTutorialSlide] {
        tab.tutorialSlides
    }

    private var currentSlide: HubTutorialSlide {
        slides[min(index, max(0, slides.count - 1))]
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let image = UIImage(named: currentSlide.imageName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                tutorialPlaceholder
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()

                Button(action: next) {
                    HStack(spacing: 7) {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                    .font(OVTheme.heading(16))
                    .foregroundStyle(OVTheme.midnight)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 13)
                    .background(Color.white)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 14)
        }
    }

    private var tutorialPlaceholder: some View {
        VStack(spacing: 14) {
            Text(currentSlide.fallbackTitle)
                .font(OVTheme.display(34))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(currentSlide.imageName + ".png")
                .font(OVTheme.body(15))
                .foregroundStyle(Color.white.opacity(0.72))
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OVTheme.midnight)
    }

    private func next() {
        if index + 1 >= slides.count {
            onComplete()
        } else {
            withAnimation(.easeInOut(duration: 0.22)) {
                index += 1
            }
        }
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
