import AuthenticationServices
import SwiftUI
import UIKit

private enum AppExperience {
    static let showsOnboarding = true
    static let showsHubTutorials = true
}

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
        (1...tutorialSlideCount).map { slideNumber in
            HubTutorialSlide(
                imageName: "\(tutorialAssetPrefix)\(slideNumber)tut",
                fallbackTitle: slideNumber == 1 ? "\(title) tutorial" : "\(title) next step"
            )
        }
    }

    private var tutorialAssetPrefix: String {
        switch self {
        case .lessons:
            return "lesson"
        default:
            return rawValue
        }
    }

    private var tutorialSlideCount: Int {
        switch self {
        case .glorify, .lessons, .chat:
            return 2
        case .home, .bible:
            return 3
        }
    }
}

private struct HubTutorialSlide: Identifiable, Hashable {
    let imageName: String
    let fallbackTitle: String

    var id: String { imageName }
}

private enum HubTutorialDefaults {
    private static let maxDeclines = 2

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
            if AppExperience.showsOnboarding && !store.onboardingCompleted {
                AppleSignupGateView(store: store, accessManager: accessManager)
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
        .environmentObject(accessManager)
        .animation(.spring(response: 0.46, dampingFraction: 0.86), value: store.onboardingCompleted)
        .task {
            await accessManager.refreshAccessState()
            enforcePremiumBibleVersion()
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
                enforcePremiumBibleVersion()
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
        store.markActiveToday()
    }

    private func syncPreviewAccess() {
        accessManager.setPreviewSelection(store.onboardingProfile.selectedVersion)
    }

    private func enforcePremiumBibleVersion() {
        if !accessManager.hasAccess && store.selectedBibleVersion.isOriginalLanguage {
            store.setBibleVersion(.esv)
        }
    }

    private func syncCloudDataRespectingAccess() async {
        await authManager.syncCloudDataIfPossible(
            store: store,
            allowsRemoteOnboardingCompletion: true
        )
    }
}

private struct AppleSignupGateView: View {
    @ObservedObject var store: SoulJourneyStore
    @ObservedObject var accessManager: SubscriptionAccessManager
    @EnvironmentObject private var authManager: AuthSessionManager

    private let privacyURL = URL(string: "https://unovisioon.com/privacy-policy")!
    private let termsURL = URL(string: "https://unovisioon.com/terms")!

    var body: some View {
        ZStack {
            OVTheme.mainBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {
                    Spacer(minLength: 34)

                    signupHero
                    signupButton
                    legalDisclosure

                    if !authManager.errorMessage.isEmpty {
                        Text(authManager.errorMessage)
                            .font(OVTheme.body(13))
                            .foregroundStyle(OVTheme.coral)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 18)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 28)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
        }
        .task {
            await accessManager.loadProducts()
            if authManager.isSignedIn {
                completeSignup()
            }
        }
    }

    private var signupHero: some View {
        VStack(spacing: 14) {
            LogoMark(size: 76, cornerRadius: 18)

            Text("One Visioon")
                .font(OVTheme.display(42))
                .foregroundStyle(OVTheme.midnight)
                .multilineTextAlignment(.center)

            Text("Read Scripture, save your progress, and unlock deeper Bible study when you choose Premium.")
                .font(OVTheme.body(16))
                .foregroundStyle(OVTheme.ink.opacity(0.76))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(26)
        .frame(maxWidth: .infinity)
        .premiumSurfaceCard(cornerRadius: 28, fill: OVTheme.elevatedCard)
    }

    private var signupButton: some View {
        SignInWithAppleButton(.signUp) { request in
            authManager.configureAppleRequest(request)
        } onCompletion: { result in
            Task {
                await authManager.handleAppleSignIn(result: result, store: store)
                if authManager.isSignedIn {
                    completeSignup()
                }
            }
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 54)
        .clipShape(Capsule())
        .disabled(authManager.isAuthenticating)
        .opacity(authManager.isAuthenticating ? 0.7 : 1)
        .accessibilityLabel("Sign up with Apple ID")
    }

    private var legalDisclosure: some View {
        VStack(spacing: 10) {
            Text("By signing up, you agree to the One Visioon Terms of Use and Privacy Policy. One Visioon includes an optional auto-renewable Premium subscription shown as $3/month, billed yearly through your Apple Account. Payment, renewal, cancellation, and subscription management are handled by Apple.")
                .font(OVTheme.body(12))
                .foregroundStyle(OVTheme.ink.opacity(0.68))
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            HStack(spacing: 18) {
                Link("Terms of Use", destination: termsURL)
                Link("Privacy Policy", destination: privacyURL)
            }
            .font(OVTheme.heading(13))
            .foregroundStyle(OVTheme.midnight)
        }
        .padding(.horizontal, 8)
    }

    private func completeSignup() {
        var profile = store.onboardingProfile
        if profile.selectedVersion.trimmed.isEmpty {
            profile.selectedVersion = "study"
        }
        if profile.selectedPremiumPlan.trimmed.isEmpty {
            profile.selectedPremiumPlan = "yearly"
        }
        store.completeOnboarding(profile: profile)
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

    @State private var premiumFeature: PremiumFeature?
    @State private var pendingPremiumTab: MainTab?

    private var tabSelection: Binding<MainTab> {
        Binding(
            get: { selectedTab },
            set: { requestTab($0) }
        )
    }

    var body: some View {
        ZStack {
            TabView(selection: tabSelection) {
                ScriptureHomeView(
                    store: store,
                    openGlorifyGifts: {
                        if accessManager.hasAccess {
                            selectedTab = .glorify
                            glorifyRoute = .discoverGifts
                        } else {
                            pendingPremiumTab = .glorify
                            premiumFeature = .glorify
                        }
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
        .sheet(item: $premiumFeature) { feature in
            SubscriptionGateView(accessManager: accessManager, feature: feature)
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
        .onChange(of: accessManager.hasAccess) { _, hasAccess in
            guard hasAccess, let pendingPremiumTab else { return }
            selectedTab = pendingPremiumTab
            self.pendingPremiumTab = nil
            premiumFeature = nil
        }
    }

    private func requestTab(_ tab: MainTab) {
        guard !requiresPremium(tab) || accessManager.hasAccess else {
            pendingPremiumTab = tab
            premiumFeature = tab == .glorify ? .glorify : .lessons
            return
        }

        selectedTab = tab
    }

    private func requiresPremium(_ tab: MainTab) -> Bool {
        tab == .glorify || tab == .lessons
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
        guard AppExperience.showsHubTutorials,
              activeTutorialTab == nil,
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
        VStack(spacing: 0) {
            ZStack {
                Color.white

                if let image = UIImage(named: currentSlide.imageName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal, 10)
                        .padding(.top, 10)
                        .padding(.bottom, 12)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    tutorialPlaceholder
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            tutorialControlBar
        }
        .background(Color.white.ignoresSafeArea())
    }

    private var tutorialControlBar: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                ForEach(slides.indices, id: \.self) { slideIndex in
                    Circle()
                        .fill(slideIndex == index ? OVTheme.midnight : OVTheme.line)
                        .frame(width: 8, height: 8)
                }
            }

            HStack {
                Button(action: previous) {
                    HStack(spacing: 7) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(OVTheme.heading(15))
                    .foregroundStyle(index == 0 ? OVTheme.muted.opacity(0.45) : OVTheme.midnight)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(OVTheme.paper)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(index == 0)

                Spacer(minLength: 14)

                Button(action: next) {
                    HStack(spacing: 7) {
                        Text(index + 1 >= slides.count ? "Done" : "Next")
                        Image(systemName: index + 1 >= slides.count ? "checkmark" : "chevron.right")
                    }
                    .font(OVTheme.heading(16))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 13)
                    .background(OVTheme.midnight)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 18)
        .background(.white)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(OVTheme.line)
                .frame(height: 1)
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

    private func previous() {
        guard index > 0 else { return }
        withAnimation(.easeInOut(duration: 0.22)) {
            index -= 1
        }
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

                    Text("Your purchase is ready. Sign in with Apple now so your membership and progress save under your account.")
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
