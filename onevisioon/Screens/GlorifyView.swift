import SwiftUI
import PhotosUI
import UIKit

enum GlorifyRoute: Hashable {
    case discoverGifts
}

private enum GlorifyScrollAnchor: Hashable {
    case discoverGifts
}

private struct WeeklyGiftDay: Identifiable {
    let id = UUID()
    let date: Date
    let checkIn: GiftTrainingCheckIn
}

private struct CreationComposerImage: Identifiable {
    let id = UUID()
    let image: UIImage
    let data: Data
}

struct GlorifyView: View {
    @ObservedObject var store: SoulJourneyStore
    @ObservedObject var accessManager: SubscriptionAccessManager
    @Binding var jumpTarget: GlorifyRoute?

    @State private var scriptureTarget: BibleReferenceTarget?
    @State private var showSchoolPreview = false
    @State private var isTakingGiftQuiz = false
    @State private var isShowingGiftQuizIntro = false
    @State private var showGiftQuizResults = false
    @State private var currentGiftQuestionIndex = 0
    @State private var giftQuizAnswers: [String: String] = [:]
    @State private var expandedGiftResultSections: Set<String> = []
    @State private var expandedGiftPathSections: Set<String> = []
    @State private var giftReflectionDraft = ""
    @State private var isEnablingMorningReminders = false
    @State private var morningReminderStatus: String?
    @FocusState private var giftReflectionFocused: Bool

    private var isBibleSchoolCreatorSpaceUnlocked: Bool {
        store.onboardingProfile.selectedVersion == "premium" || accessManager.hasActiveSubscription
    }

    private var todayGiftCheckIn: GiftTrainingCheckIn {
        store.giftTrainingCheckIn()
    }

    private var weeklyGiftDays: [WeeklyGiftDay] {
        let calendar = Calendar.current
        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -(6 - offset), to: .now) else {
                return nil
            }
            return WeeklyGiftDay(date: date, checkIn: store.giftTrainingCheckIn(for: date))
        }
    }

    private var hasGiftProfile: Bool {
        store.giftDiscoveryProfile != nil
    }

    private var discoveredGifts: [SpiritualGiftKind] {
        let top = store.discoveredGiftKinds
        return top.isEmpty ? Array(SpiritualGiftKind.allCases.prefix(2)) : top
    }

    private var currentGiftQuestion: GiftDiscoveryQuestion {
        GiftDiscoveryCatalog.questions[currentGiftQuestionIndex]
    }

    private var todayMorningQuote: GlorifyMorningQuote {
        GiftDiscoveryCatalog.morningQuote()
    }

    private var dailyGiftFocus: GiftDailyFocus? {
        guard let profile = store.giftDiscoveryProfile else { return nil }
        return GiftDiscoveryCatalog.todayFocus(
            for: profile,
            progressDays: store.giftTrainingCompletedDayCount
        )
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: OVTheme.cardSpacing) {
                        Color.clear
                            .frame(height: 0)
                            .id(GlorifyScrollAnchor.discoverGifts)

                        if hasGiftProfile && !isTakingGiftQuiz {
                            if showGiftQuizResults {
                                giftQuizResultsHeroCard
                                giftResultAccordionSection(
                                    id: "guided-plan",
                                    title: "Guided plan",
                                    subtitle: "Daily focus, habits, Scripture, and reflection.",
                                    systemImage: "map.fill"
                                ) {
                                    giftQuizResultsPlanCard
                                }
                                giftResultAccordionSection(
                                    id: "morning-truth",
                                    title: "Morning truth",
                                    subtitle: "Optional reminders to start the day with God.",
                                    systemImage: "bell.badge.fill"
                                ) {
                                    giftQuizReminderCard
                                }
                                giftQuizResultsContinueCard
                            } else {
                                giftGrowthHeroCard
                                if let dailyGiftFocus {
                                    giftPathAccordionSection(
                                        id: "today-focus",
                                        title: "Today's focus",
                                        subtitle: "Open today's action, prayer, and Scripture.",
                                        systemImage: "target"
                                    ) {
                                        todayGiftFocusCard(dailyGiftFocus)
                                    }
                                }
                                giftPathAccordionSection(
                                    id: "daily-training",
                                    title: "Daily gift training",
                                    subtitle: "Clock in and check off the habits that matter today.",
                                    systemImage: "checkmark.circle.fill"
                                ) {
                                    giftTrackerSection
                                }
                                giftPathAccordionSection(
                                    id: "gift-profile",
                                    title: "Gift profile",
                                    subtitle: "See your strongest lanes and growth edge.",
                                    systemImage: "sparkles.rectangle.stack.fill"
                                ) {
                                    giftProfileSection
                                }
                                giftPathAccordionSection(
                                    id: "gift-reflection",
                                    title: "Gift reflection",
                                    subtitle: "Write what you practiced and where God stretched you.",
                                    systemImage: "square.and.pencil"
                                ) {
                                    giftReflectionSection
                                }
                                if discoveredGifts.contains(.creativity) {
                                    giftPathAccordionSection(
                                        id: "creator-feed",
                                        title: "Creator space",
                                        subtitle: "Open the creative sharing space when you need it.",
                                        systemImage: "photo.stack.fill"
                                    ) {
                                        creatorFeedSection
                                    }
                                }
                            }
                        } else if isTakingGiftQuiz {
                            giftQuizHeroCard
                            if isShowingGiftQuizIntro {
                                giftQuizIntroSlideCard
                            } else {
                                giftQuizQuestionCard
                            }
                        } else {
                            giftDiscoveryHeroCard
                            giftDiscoveryValueCard
                            giftDiscoveryStartCard
                        }
                    }
                    .padding(.horizontal, OVTheme.screenHorizontalPadding)
                    .padding(.vertical, OVTheme.screenVerticalPadding)
                }
                .background(OVTheme.mainBackground.ignoresSafeArea())
                .navigationTitle("Glorify")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(item: $scriptureTarget) { target in
                    BibleChapterReaderView(store: store, target: target)
                }
                .sheet(isPresented: $showSchoolPreview) {
                    GlorifySchoolPreviewView()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        AppInfoButton()
                    }
                }
                .onAppear {
                    giftReflectionDraft = store.giftTrainingCheckIn().reflection
                    handleJumpRequest(with: proxy)
                }
                .task(id: store.glorifyReminderSettings) {
                    await GlorifyReminderService.refreshMorningQuotesIfNeeded(using: store.glorifyReminderSettings)
                }
                .onChange(of: jumpTarget) { _, _ in
                    handleJumpRequest(with: proxy)
                }
                .onChange(of: currentGiftQuestionIndex) { _, _ in
                    guard isTakingGiftQuiz else { return }
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
                        proxy.scrollTo(GlorifyScrollAnchor.discoverGifts, anchor: .top)
                    }
                }
            }
        }
    }

    private var giftDiscoveryHeroCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(OVTheme.lemon.opacity(0.52))
                        .frame(width: 58, height: 58)

                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(OVTheme.midnight)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Gift discovery")
                        .font(OVTheme.body(11))
                        .foregroundStyle(OVTheme.gold)

                    Text("Glorify God with the way He wired you")
                        .font(OVTheme.display(30))
                        .foregroundStyle(OVTheme.midnight)
                }
            }

            Text("Take the quiz once, then let One Visioon guide you with daily habits, Scripture, and clear next steps for how your gifts grow.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.76))

            HStack(spacing: 8) {
                topChip("\(GiftDiscoveryCatalog.questions.count)-question profile")
                topChip("Daily training")
                topChip("Real habits")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(OVTheme.cardPadding)
        .background(
            LinearGradient(
                colors: [OVTheme.lemon.opacity(0.32), .white, OVTheme.mist.opacity(0.54)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .glorifyCard()
    }

    private var giftDiscoveryValueCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("What this gives you")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            VStack(alignment: .leading, spacing: 10) {
                previewBullet("A likely primary gift and support gift based on your answers")
                previewBullet("A daily focus that helps you use those gifts in real life")
                previewBullet("A habit tracker built around how each gift actually grows")
                previewBullet("Simple reflection so growth becomes visible over time")
            }
        }
        .padding(OVTheme.cardPadding)
        .glorifyCard()
    }

    private var giftDiscoveryStartCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Start gift discovery")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text("Answer honestly. The goal is to see how God may already be shaping you, then train that gift day by day.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))

            Button {
                startGiftQuiz()
            } label: {
                Text("Take the quiz")
                    .font(OVTheme.heading(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(OVTheme.midnight)
                    .clipShape(Capsule())
                    .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("glorify.takeQuizButton")
        }
        .padding(OVTheme.cardPadding)
        .glorifyCard()
    }

    private var giftQuizHeroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Gift quiz")
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.midnight)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(OVTheme.smoke)
                    .clipShape(Capsule())

                Spacer()

                Text(isShowingGiftQuizIntro ? "Before question 1" : "Question \(currentGiftQuestionIndex + 1) of \(GiftDiscoveryCatalog.questions.count)")
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.ink.opacity(0.7))
            }

            Text(isShowingGiftQuizIntro ? "Know what this will do" : "Discover how God may have wired you")
                .font(OVTheme.display(30))
                .foregroundStyle(OVTheme.midnight)

            Text(isShowingGiftQuizIntro ? "A quick summary first, then the questions start." : "Pick the answer that feels most like you most of the time. There is no perfect answer here.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))

            ProgressView(
                value: isShowingGiftQuizIntro ? 0 : Double(currentGiftQuestionIndex + 1),
                total: Double(GiftDiscoveryCatalog.questions.count)
            )
                .tint(OVTheme.gold)
        }
        .padding(OVTheme.cardPadding)
        .glorifyCard()
    }

    private var giftQuizIntroSlideCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Before you answer")
                .font(OVTheme.heading(24))
                .foregroundStyle(OVTheme.midnight)

            Text("This discovery will turn your answers into a simple gift path: your likely primary gift, your support gift, the growth edge to watch, and a daily training rhythm you can actually follow.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.74))

            VStack(alignment: .leading, spacing: 10) {
                previewBullet("You answer \(GiftDiscoveryCatalog.questions.count) short questions")
                previewBullet("One Visioon summarizes the gifts that show up strongest")
                previewBullet("After the quiz, the next sections stay collapsed until you open them")
            }

            detailBox(
                title: "How to answer",
                text: "Choose what is true most often, not what sounds most spiritual. Honest answers make the path more useful.",
                tint: OVTheme.lemon.opacity(0.18)
            )

            Button {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
                    isShowingGiftQuizIntro = false
                }
            } label: {
                Text("Start the questions")
                    .font(OVTheme.heading(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(OVTheme.midnight)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("glorify.startGiftQuestionsButton")
        }
        .padding(OVTheme.cardPadding)
        .glorifyCard()
    }

    private var giftQuizQuestionCard: some View {
        VStack {
            VStack(alignment: .leading, spacing: 16) {
                Text(currentGiftQuestion.prompt)
                    .font(OVTheme.heading(24))
                    .foregroundStyle(OVTheme.midnight)

                Text(currentGiftQuestion.detail)
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.72))

                VStack(spacing: 10) {
                    ForEach(currentGiftQuestion.options) { option in
                        giftQuizOptionRow(option)
                    }
                }

                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                        if currentGiftQuestionIndex == 0 {
                            isShowingGiftQuizIntro = true
                        } else {
                            currentGiftQuestionIndex -= 1
                        }
                    }
                } label: {
                    Text(currentGiftQuestionIndex == 0 ? "Back to summary" : "Back")
                        .font(OVTheme.heading(14))
                        .foregroundStyle(OVTheme.midnight)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(OVTheme.paper)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .id(currentGiftQuestion.id)
        }
        .padding(OVTheme.cardPadding)
        .glorifyCard()
    }

    private var giftQuizResultsHeroCard: some View {
        let profile = store.giftDiscoveryProfile
        let primary = profile?.primaryGift
        let secondary = profile?.secondaryGift
        let need = profile?.primaryNeed

        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(primary.map { giftAccent($0) } ?? OVTheme.lemon.opacity(0.34))
                        .frame(width: 58, height: 58)

                    Image(systemName: primary?.symbol ?? "sparkles")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(OVTheme.midnight)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Glorify result")
                        .font(OVTheme.body(11))
                        .foregroundStyle(OVTheme.gold)

                    Text(profile?.resultHeadline ?? "Your gift path")
                        .font(OVTheme.display(30))
                        .foregroundStyle(OVTheme.midnight)

                    Text(profile?.resultSummary ?? "One Visioon will now guide you with a daily path.")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.ink.opacity(0.76))
                }
            }

            HStack(spacing: 8) {
                if let primary {
                    topChip("Primary: \(primary.title)")
                }
                if let secondary {
                    topChip("Support: \(secondary.title)")
                }
                if let need {
                    topChip("Growth edge: \(need.title)")
                }
            }

            HStack(spacing: 10) {
                heroMetricTile("Questions", "\(GiftDiscoveryCatalog.questions.count)")
                heroMetricTile("Confidence", profile?.confidenceLabel ?? "Fit")
                heroMetricTile("Next", "Daily training")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(OVTheme.cardPadding)
        .background(
            LinearGradient(
                colors: [OVTheme.lemon.opacity(0.32), .white, OVTheme.mist.opacity(0.54)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .glorifyCard()
    }

    private var giftQuizResultsPlanCard: some View {
        let profile = store.giftDiscoveryProfile
        let primary = profile?.primaryGift
        let need = profile?.primaryNeed

        return VStack(alignment: .leading, spacing: 14) {
            Text("How One Visioon will guide you")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text(profile?.trainingSummary ?? "The app will now guide you with a daily path built around your answers.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.74))

            VStack(alignment: .leading, spacing: 10) {
                previewBullet("A daily focus built around \(primary?.title.lowercased() ?? "your strongest gift")")
                previewBullet("A simple clock-in rhythm so you keep showing up")
                previewBullet("Habit check-offs based on how this gift actually grows")
                previewBullet(need?.shortSummary ?? "Reflection so your growth becomes visible over time")
            }

            if let need {
                detailBox(
                    title: "Main growth edge",
                    text: need.shortSummary,
                    tint: OVTheme.sky.opacity(0.2)
                )
            }
        }
        .padding(OVTheme.cardPadding)
        .glorifyCard()
    }

    private var giftQuizReminderCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Wake up with truth")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text("If you allow it, One Visioon will send one morning inspiration each day so you remember to open the app, clock in, and walk with God on purpose.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.74))

            detailBox(
                title: "Morning example",
                text: "\(todayMorningQuote.text) • \(todayMorningQuote.reference)",
                tint: OVTheme.lemon.opacity(0.18)
            )

            if store.glorifyReminderSettings?.isEnabled == true {
                HStack(spacing: 10) {
                    Image(systemName: "bell.badge.fill")
                        .foregroundStyle(OVTheme.gold)
                    Text("Morning inspiration is on.")
                        .font(OVTheme.heading(14))
                        .foregroundStyle(OVTheme.midnight)
                }
            } else {
                Button {
                    enableMorningReminders()
                } label: {
                    HStack {
                        if isEnablingMorningReminders {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Turn on morning reminders")
                                .font(OVTheme.heading(15))
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(OVTheme.midnight)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(isEnablingMorningReminders)
            }

            if let morningReminderStatus {
                Text(morningReminderStatus)
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.ink.opacity(0.7))
            }
        }
        .padding(OVTheme.cardPadding)
        .glorifyCard()
    }

    private var giftQuizResultsContinueCard: some View {
        VStack(spacing: 10) {
            Button {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
                    showGiftQuizResults = false
                    expandedGiftPathSections = []
                }
            } label: {
                Text("Start my daily path")
                    .font(OVTheme.heading(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(OVTheme.midnight)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Button {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
                    showGiftQuizResults = false
                    expandedGiftPathSections = []
                }
            } label: {
                Text("Skip for now")
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.ink.opacity(0.68))
            }
            .buttonStyle(.plain)
        }
        .padding(OVTheme.cardPadding)
        .glorifyCard()
    }

    private func giftQuizOptionRow(_ option: GiftDiscoveryOption) -> some View {
        Button {
            selectGiftQuizOption(option.id)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(option.title)
                    .font(OVTheme.heading(16))
                    .foregroundStyle(OVTheme.ink)
                    .multilineTextAlignment(.leading)

                Text(option.detail)
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.ink.opacity(0.68))
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .glorifyCard(cornerRadius: 20, fill: OVTheme.elevatedCard)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var giftGrowthHeroCard: some View {
        let primaryGift = discoveredGifts.first
        let secondaryGift = discoveredGifts.dropFirst().first

        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                if let primaryGift {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(giftAccent(primaryGift))
                            .frame(width: 58, height: 58)

                        Image(systemName: primaryGift.symbol)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(OVTheme.midnight)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Your gift path")
                        .font(OVTheme.body(11))
                        .foregroundStyle(OVTheme.gold)

                    if let primaryGift {
                        Text(primaryGift.title)
                            .font(OVTheme.display(30))
                            .foregroundStyle(OVTheme.midnight)

                        Text(primaryGift.shortSummary)
                            .font(OVTheme.body(14))
                            .foregroundStyle(OVTheme.ink.opacity(0.76))
                    }
                }
            }

            HStack(spacing: 8) {
                if let primaryGift {
                    topChip("Primary: \(primaryGift.title)")
                }
                if let secondaryGift {
                    topChip("Support: \(secondaryGift.title)")
                }
                topChip("\(store.giftTrainingStreak) day streak")
            }

            HStack(spacing: 10) {
                heroMetricTile("Days trained", "\(store.giftTrainingCompletedDayCount)")
                heroMetricTile("Habits today", "\(todayGiftCheckIn.completedCount)")
                heroMetricTile("Clocked in", store.hasGiftClockedInToday ? "Yes" : "Not yet")
            }

            detailBox(
                title: "Morning inspiration",
                text: "\(todayMorningQuote.text) • \(todayMorningQuote.reference)",
                tint: OVTheme.sky.opacity(0.2)
            )

            if store.glorifyReminderSettings?.isEnabled != true {
                Button {
                    enableMorningReminders()
                } label: {
                    HStack {
                        Text("Turn on morning inspiration")
                            .font(OVTheme.heading(14))
                            .foregroundStyle(.white)
                        Spacer()
                        Image(systemName: "bell.fill")
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    .background(OVTheme.midnight)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(isEnablingMorningReminders)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(OVTheme.cardPadding)
        .background(
            LinearGradient(
                colors: [OVTheme.lemon.opacity(0.32), .white, OVTheme.mist.opacity(0.54)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .glorifyCard()
    }

    private func todayGiftFocusCard(_ focus: GiftDailyFocus) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(giftAccent(focus.gift))
                        .frame(width: 50, height: 50)

                    Image(systemName: focus.gift.symbol)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(OVTheme.midnight)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's focus")
                        .font(OVTheme.heading(20))
                        .foregroundStyle(OVTheme.ink)
                    Text("\(focus.gift.title) • Step \(focus.dayNumber) of \(focus.totalSteps)")
                        .font(OVTheme.body(12))
                        .foregroundStyle(OVTheme.gold)
                }

                Spacer()

                Button {
                    scriptureTarget = BibleDataProvider.resolveReference(from: focus.reference)
                } label: {
                    HStack(spacing: 6) {
                        Text(focus.reference)
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.midnight)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(giftAccent(focus.gift))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            ProgressView(value: Double(focus.dayNumber), total: Double(max(focus.totalSteps, focus.dayNumber)))
                .tint(OVTheme.gold)

            if store.hasGiftClockedInToday {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(OVTheme.gold)
                    Text("You already clocked in today.")
                        .font(OVTheme.heading(14))
                        .foregroundStyle(OVTheme.midnight)
                }
            } else {
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                        store.clockInToGiftTraining()
                    }
                } label: {
                    HStack {
                        Text("Clock in for today")
                            .font(OVTheme.heading(15))
                        Spacer()
                        Image(systemName: "checkmark.circle")
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    .background(OVTheme.midnight)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(focus.title)
                    .font(OVTheme.heading(18))
                    .foregroundStyle(OVTheme.midnight)

                Text(focus.detail)
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.74))

                detailBox(
                    title: "Why this matters",
                    text: focus.whyItMatters,
                    tint: OVTheme.lemon.opacity(0.18)
                )

                detailBox(
                    title: "Today's action",
                    text: focus.actionStep,
                    tint: giftAccent(focus.gift).opacity(0.48)
                )

                detailBox(
                    title: "Prayer",
                    text: focus.gift.dailyPrayer,
                    tint: OVTheme.sky.opacity(0.2)
                )

                detailBox(
                    title: "Morning inspiration",
                    text: "\(todayMorningQuote.text) • \(todayMorningQuote.reference)",
                    tint: OVTheme.orchid.opacity(0.16)
                )
            }

            Text("Reflect later: \(focus.reflectionPrompt)")
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.68))
        }
        .padding(OVTheme.cardPadding)
        .glorifyCard()
    }

    private var giftTrackerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily gift training")
                        .font(OVTheme.heading(22))
                        .foregroundStyle(OVTheme.ink)
                    Text("Clock in, work the focus, and check off habits that help your gifts become useful in real life.")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.ink.opacity(0.72))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(todayGiftCheckIn.completedCount)")
                        .font(OVTheme.display(28))
                        .foregroundStyle(OVTheme.midnight)
                    Text("done today")
                        .font(OVTheme.body(12))
                        .foregroundStyle(OVTheme.ink.opacity(0.66))
                }
            }

            weeklyGiftTracker

            VStack(spacing: 12) {
                ForEach(discoveredGifts.prefix(2), id: \.id) { gift in
                    giftHabitCard(gift)
                }
            }
        }
        .padding(.top, 2)
    }

    private var weeklyGiftTracker: some View {
        HStack(spacing: 8) {
            ForEach(weeklyGiftDays) { day in
                VStack(spacing: 8) {
                    Text(shortWeekday(day.date))
                        .font(OVTheme.body(11))
                        .foregroundStyle(OVTheme.ink.opacity(0.6))

                    ZStack {
                        Circle()
                            .fill(day.checkIn.hasMeaningfulProgress ? OVTheme.midnight : OVTheme.smoke)
                            .frame(width: 36, height: 36)

                        if day.checkIn.hasMeaningfulProgress {
                            Text("\(max(1, day.checkIn.completedCount))")
                                .font(OVTheme.heading(13))
                                .foregroundStyle(.white)
                        } else {
                            Circle()
                                .stroke(OVTheme.line, lineWidth: 1)
                                .frame(width: 36, height: 36)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(14)
        .glorifyCard(cornerRadius: 20, fill: OVTheme.elevatedCard)
    }

    private func giftHabitCard(_ gift: SpiritualGiftKind) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(giftAccent(gift))
                        .frame(width: 50, height: 50)

                    Image(systemName: gift.symbol)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(OVTheme.midnight)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(gift.title)
                        .font(OVTheme.heading(18))
                        .foregroundStyle(OVTheme.ink)

                    Text(gift.growthLine)
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.ink.opacity(0.72))
                }

                Spacer()
            }

            HStack(spacing: 8) {
                statChip("\(store.giftActiveDayCount(for: gift))", "days this week")
                statChip("\(store.giftHabitCompletionCount(for: gift))", "habits this week")
            }

            ForEach(gift.habits) { habit in
                let isPriority = dailyGiftFocus?.habitIDs.contains(habit.id) == true
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                        store.toggleGiftHabit(habit.id)
                    }
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(store.isGiftHabitCompleted(habit.id) ? OVTheme.midnight : .white)
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle()
                                        .stroke(store.isGiftHabitCompleted(habit.id) ? OVTheme.midnight : OVTheme.line, lineWidth: 1)
                                )

                            if store.isGiftHabitCompleted(habit.id) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Text(habit.title)
                                    .font(OVTheme.heading(15))
                                    .foregroundStyle(OVTheme.ink)

                                if isPriority {
                                    Text("TODAY")
                                        .font(OVTheme.body(10))
                                        .foregroundStyle(OVTheme.midnight)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(giftAccent(gift))
                                        .clipShape(Capsule())
                                }
                            }

                            Text("\(habit.detail) • \(habit.reference)")
                                .font(OVTheme.body(12))
                                .foregroundStyle(OVTheme.ink.opacity(0.66))
                                .multilineTextAlignment(.leading)
                        }

                        Spacer()
                    }
                    .padding(14)
                    .glorifyCard(
                        cornerRadius: 20,
                        fill: store.isGiftHabitCompleted(habit.id)
                        ? OVTheme.paper
                        : (isPriority ? giftAccent(gift).opacity(0.35) : OVTheme.cardBackground)
                    )
                }
                .buttonStyle(.plain)
            }

            Text(gift.caution)
                .font(OVTheme.body(12))
                .foregroundStyle(OVTheme.gold)
        }
        .padding(OVTheme.cardPadding)
        .glorifyCard(cornerRadius: 22)
    }

    private var giftProfileSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How One Visioon reads your gifts")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text("These are not labels to show off. They are likely lanes of faithfulness the app can now help you practice day to day.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))

            if let primaryNeed = store.giftDiscoveryProfile?.primaryNeed {
                detailBox(
                    title: "Main growth edge",
                    text: primaryNeed.shortSummary,
                    tint: OVTheme.sky.opacity(0.16)
                )
            }

            VStack(spacing: 12) {
                ForEach(discoveredGifts, id: \.id) { gift in
                    HStack(alignment: .top, spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(giftAccent(gift))
                                .frame(width: 46, height: 46)

                            Image(systemName: gift.symbol)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(OVTheme.midnight)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(gift.title)
                                    .font(OVTheme.heading(18))
                                    .foregroundStyle(OVTheme.midnight)

                                Spacer()

                                if let profile = store.giftDiscoveryProfile {
                                    Text("\(profile.score(for: gift)) pts")
                                        .font(OVTheme.body(12))
                                        .foregroundStyle(OVTheme.ink.opacity(0.64))
                                }
                            }

                            Text(gift.shortSummary)
                                .font(OVTheme.body(14))
                                .foregroundStyle(OVTheme.ink.opacity(0.76))

                            Text(gift.growthLine)
                                .font(OVTheme.body(13))
                                .foregroundStyle(OVTheme.gold)
                        }
                    }
                    .padding(16)
                    .glorifyCard(cornerRadius: 20, fill: OVTheme.elevatedCard)
                }
            }

            Button {
                startGiftQuiz()
            } label: {
                Text("Retake gift quiz")
                    .font(OVTheme.heading(14))
                    .foregroundStyle(OVTheme.midnight)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(OVTheme.paper)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 2)
    }

    private var giftReflectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Gift reflection")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text("Write what you actually used today, where it felt hard, or where God is stretching you.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))

            TextEditor(text: $giftReflectionDraft)
                .focused($giftReflectionFocused)
                .font(OVTheme.body(15))
                .frame(minHeight: 120)
                .padding(10)
                .background(OVTheme.paper)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(OVTheme.line, lineWidth: 1)
                )

            Button {
                if store.saveGiftTrainingReflection(giftReflectionDraft) {
                    giftReflectionDraft = store.giftTrainingCheckIn().reflection
                    giftReflectionFocused = false
                }
            } label: {
                Text("Save reflection")
                    .font(OVTheme.heading(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(OVTheme.midnight)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(OVTheme.cardPadding)
        .glorifyCard()
    }

    private func statChip(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(OVTheme.heading(14))
                .foregroundStyle(OVTheme.midnight)
            Text(label)
                .font(OVTheme.body(11))
                .foregroundStyle(OVTheme.ink.opacity(0.62))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(OVTheme.smoke)
        .clipShape(Capsule())
    }

    private func giftAccent(_ gift: SpiritualGiftKind) -> Color {
        switch gift {
        case .encouragement:
            return OVTheme.orchid.opacity(0.32)
        case .service:
            return OVTheme.mint.opacity(0.34)
        case .teaching:
            return OVTheme.sky.opacity(0.34)
        case .mercy:
            return OVTheme.lemon.opacity(0.34)
        case .leadership:
            return OVTheme.sand.opacity(0.38)
        case .creativity:
            return OVTheme.lemon.opacity(0.42)
        }
    }

    private func giftResultAccordionSection<Content: View>(
        id: String,
        title: String,
        subtitle: String,
        systemImage: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        giftAccordionSection(
            id: id,
            title: title,
            subtitle: subtitle,
            systemImage: systemImage,
            expandedIDs: $expandedGiftResultSections,
            content: content
        )
    }

    private func giftPathAccordionSection<Content: View>(
        id: String,
        title: String,
        subtitle: String,
        systemImage: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        giftAccordionSection(
            id: id,
            title: title,
            subtitle: subtitle,
            systemImage: systemImage,
            expandedIDs: $expandedGiftPathSections,
            content: content
        )
    }

    private func giftAccordionSection<Content: View>(
        id: String,
        title: String,
        subtitle: String,
        systemImage: String,
        expandedIDs: Binding<Set<String>>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        let isExpanded = expandedIDs.wrappedValue.contains(id)

        return VStack(alignment: .leading, spacing: isExpanded ? 12 : 0) {
            Button {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
                    if expandedIDs.wrappedValue.contains(id) {
                        expandedIDs.wrappedValue.remove(id)
                    } else {
                        expandedIDs.wrappedValue.insert(id)
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(OVTheme.lemon.opacity(0.28))
                            .frame(width: 46, height: 46)

                        Image(systemName: systemImage)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(OVTheme.midnight)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(OVTheme.heading(17))
                            .foregroundStyle(OVTheme.midnight)

                        Text(subtitle)
                            .font(OVTheme.body(12))
                            .foregroundStyle(OVTheme.ink.opacity(0.66))
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(OVTheme.ink.opacity(0.62))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(16)
                .glorifyCard(cornerRadius: 22, fill: OVTheme.elevatedCard)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("glorify.accordion.\(id)")

            if isExpanded {
                content()
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func startGiftQuiz() {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
            isTakingGiftQuiz = true
            isShowingGiftQuizIntro = true
            showGiftQuizResults = false
            currentGiftQuestionIndex = 0
            giftQuizAnswers = [:]
            expandedGiftResultSections = []
            expandedGiftPathSections = []
            morningReminderStatus = nil
        }
    }

    private func selectGiftQuizOption(_ optionID: String) {
        guard GiftDiscoveryCatalog.questions.indices.contains(currentGiftQuestionIndex) else { return }

        let question = currentGiftQuestion
        giftQuizAnswers[question.id] = optionID

        if currentGiftQuestionIndex == GiftDiscoveryCatalog.questions.count - 1 {
            store.completeGiftQuiz(answers: giftQuizAnswers)
            giftReflectionDraft = store.giftTrainingCheckIn().reflection
            withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
                isTakingGiftQuiz = false
                isShowingGiftQuizIntro = false
                showGiftQuizResults = true
                expandedGiftResultSections = []
            }
            return
        }

        withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
            currentGiftQuestionIndex += 1
        }
    }

    private func enableMorningReminders() {
        Task {
            isEnablingMorningReminders = true
            defer { isEnablingMorningReminders = false }

            let settings = store.glorifyReminderSettings ?? .dailyMorning
            let enabled = await GlorifyReminderService.enableMorningQuotes(using: settings)

            if enabled {
                store.saveGlorifyReminderSettings(settings)
                morningReminderStatus = "Morning inspiration is on. We’ll send one around 7:00 AM each day."
            } else {
                morningReminderStatus = "Morning reminders stayed off for now. You can turn them on later from Glorify."
            }
        }
    }

    @ViewBuilder
    private var creatorFeedSection: some View {
        if isBibleSchoolCreatorSpaceUnlocked {
            NavigationLink {
                CreationFeedView(store: store)
            } label: {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .top, spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(OVTheme.orchid.opacity(0.42))
                                .frame(width: 50, height: 50)

                            Image(systemName: "photo.stack")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(OVTheme.midnight)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Creator feed")
                                .font(OVTheme.heading(22))
                                .foregroundStyle(OVTheme.midnight)
                            Text("An aesthetic space for sharing what Jesus is inspiring in you.")
                                .font(OVTheme.body(14))
                                .foregroundStyle(OVTheme.ink.opacity(0.72))
                        }
                        Spacer()
                        Text("Bible School")
                            .font(OVTheme.body(11))
                            .foregroundStyle(OVTheme.midnight)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(OVTheme.lemon.opacity(0.44))
                            .clipShape(Capsule())
                    }

                    HStack(spacing: 8) {
                        topChip("Longer posts")
                        topChip("3 image slots")
                        topChip("Comments")
                    }

                    HStack {
                        Text("Open creator space")
                            .font(OVTheme.heading(16))
                            .foregroundStyle(.white)
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                        .background(OVTheme.midnight)
                        .clipShape(Capsule())
                }
                .padding(OVTheme.cardPadding)
                .background(
                    LinearGradient(
                        colors: [OVTheme.orchid.opacity(0.36), .white],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .glorifyCard()
            }
            .buttonStyle(.plain)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("Bible School creator space")
                    .font(OVTheme.heading(22))
                    .foregroundStyle(OVTheme.midnight)

                Text("Go beyond personal rhythm into a more communal creative feed with richer sharing, more room, and image attachments.")
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.74))

                VStack(alignment: .leading, spacing: 8) {
                    previewBullet("Share longer creation stories")
                    previewBullet("Attach up to 3 images to a post")
                    previewBullet("Reply inside an aesthetic creator feed")
                }

                Button {
                    showSchoolPreview = true
                } label: {
                    Text("See creator feed preview")
                        .font(OVTheme.heading(15))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(OVTheme.midnight)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(OVTheme.cardPadding)
            .glorifyCard()
        }
    }

    private func topChip(_ label: String) -> some View {
        Text(label)
            .font(OVTheme.body(12))
            .foregroundStyle(OVTheme.midnight)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.white.opacity(0.92))
            .clipShape(Capsule())
    }

    private func previewBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(OVTheme.gold)

            Text(text)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.76))
        }
    }

    private func heroMetricTile(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(OVTheme.heading(16))
                .foregroundStyle(OVTheme.midnight)
            Text(label)
                .font(OVTheme.body(11))
                .foregroundStyle(OVTheme.ink.opacity(0.66))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.white.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func detailBox(title: String, text: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(OVTheme.body(11))
                .foregroundStyle(OVTheme.midnight)

            Text(text)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(tint)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func shortWeekday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }

    private func handleJumpRequest(with proxy: ScrollViewProxy) {
        guard jumpTarget == .discoverGifts else { return }

        DispatchQueue.main.async {
            if !hasGiftProfile {
                startGiftQuiz()
            } else {
                withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
                    proxy.scrollTo(GlorifyScrollAnchor.discoverGifts, anchor: .top)
                }
            }
            jumpTarget = nil
        }
    }
}

private struct CreationFeedView: View {
    @ObservedObject var store: SoulJourneyStore

    @State private var scriptureTarget: BibleReferenceTarget?
    @State private var showComposer = false
    @State private var selectedCommentsPost: CreationFeedPost?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: OVTheme.cardSpacing) {
                headerCard
                composeCard
                feedSection
            }
            .padding(.horizontal, OVTheme.screenHorizontalPadding)
            .padding(.vertical, OVTheme.screenVerticalPadding)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle("Creator Feed")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $scriptureTarget) { target in
            BibleChapterReaderView(store: store, target: target)
        }
        .sheet(isPresented: $showComposer) {
            CreationComposerSheet(store: store)
        }
        .sheet(item: $selectedCommentsPost) { post in
            CreationCommentsSheet(store: store, postID: post.id)
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Share what Jesus is stirring")
                .font(OVTheme.display(30))
                .foregroundStyle(OVTheme.midnight)

            Text("Post artwork, lyrics, visual ideas, testimonies, and creative pieces that point people back to Christ.")
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.74))

            HStack(spacing: 8) {
                feedChip("Aesthetic")
                feedChip("Scripture-linked")
                feedChip("Creative community")
            }
        }
        .padding(OVTheme.cardPadding)
        .background(
            LinearGradient(
                colors: [OVTheme.orchid.opacity(0.34), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .glorifyCard()
    }

    private var composeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Post to the feed")
                .font(OVTheme.heading(20))
                .foregroundStyle(OVTheme.ink)

            Text("Share longer thoughts, add Scripture, and attach up to 3 images to help your work feel alive and grounded.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))

            Button {
                showComposer = true
            } label: {
                HStack {
                    Text("New creation post")
                        .font(OVTheme.heading(15))
                    Spacer()
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(OVTheme.midnight)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(OVTheme.cardPadding)
        .glorifyCard()
    }

    private var feedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent creations")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            ForEach(store.sortedCreationFeedPosts) { post in
                creationPostCard(post)
            }
        }
    }

    private func creationPostCard(_ post: CreationFeedPost) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.authorName)
                        .font(OVTheme.heading(16))
                        .foregroundStyle(OVTheme.ink)
                    Text("\(post.handle) - \(relativeDate(post.createdAt))")
                        .font(OVTheme.body(12))
                        .foregroundStyle(OVTheme.ink.opacity(0.58))
                }

                Spacer()

                Text(post.kind.rawValue.uppercased())
                    .font(OVTheme.body(10))
                    .foregroundStyle(OVTheme.midnight)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(OVTheme.smoke)
                    .clipShape(Capsule())
            }

            Text(post.caption)
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.82))

            if !post.attachmentFileNames.isEmpty {
                CreationAttachmentGrid(store: store, fileNames: post.attachmentFileNames)
            }

            HStack(spacing: 10) {
                if !post.scriptureReference.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Button {
                        scriptureTarget = BibleDataProvider.resolveReference(from: post.scriptureReference)
                    } label: {
                        HStack(spacing: 6) {
                            Text(post.scriptureReference)
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .font(OVTheme.body(12))
                        .foregroundStyle(OVTheme.midnight)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(OVTheme.sky.opacity(0.52))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
            }

            HStack(spacing: 10) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        store.toggleCreationHeart(for: post.id)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: post.didHeart ? "heart.fill" : "heart")
                        Text("\(post.hearts)")
                    }
                    .font(OVTheme.body(13))
                    .foregroundStyle(post.didHeart ? Color.red : OVTheme.midnight)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(post.didHeart ? Color.red.opacity(0.1) : OVTheme.smoke)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button {
                    selectedCommentsPost = post
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left")
                        Text("\(post.comments.count)")
                    }
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.midnight)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(OVTheme.smoke)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            if let latestComment = post.comments.last {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Latest reply")
                        .font(OVTheme.body(11))
                        .foregroundStyle(OVTheme.gold)
                    Text("\(latestComment.authorName): \(latestComment.text)")
                        .font(OVTheme.body(13))
                        .foregroundStyle(OVTheme.ink.opacity(0.72))
                }
                .padding(12)
                .background(OVTheme.paper)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .padding(18)
        .glorifyCard(cornerRadius: 24)
    }

    private func feedChip(_ label: String) -> some View {
        Text(label)
            .font(OVTheme.body(12))
            .foregroundStyle(OVTheme.midnight)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.white.opacity(0.92))
            .clipShape(Capsule())
    }

    private func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: .now)
    }
}

private struct CreationComposerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: SoulJourneyStore

    @State private var selectedKind: CreationPostKind = .artwork
    @State private var caption = ""
    @State private var scriptureReference = ""
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var selectedImages: [CreationComposerImage] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What are you sharing?")
                            .font(OVTheme.heading(22))
                            .foregroundStyle(OVTheme.ink)

                        creationKindChips
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Caption")
                            .font(OVTheme.heading(16))
                            .foregroundStyle(OVTheme.ink)

                        TextEditor(text: $caption)
                            .font(OVTheme.body(15))
                            .frame(minHeight: 130)
                            .padding(10)
                            .background(OVTheme.paper)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(OVTheme.line, lineWidth: 1)
                            )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Scripture reference")
                            .font(OVTheme.heading(16))
                            .foregroundStyle(OVTheme.ink)

                        TextField("Optional, like John 1:5", text: $scriptureReference)
                            .textFieldStyle(.roundedBorder)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Images")
                                .font(OVTheme.heading(16))
                                .foregroundStyle(OVTheme.ink)
                            Spacer()
                            Text("Up to 3")
                                .font(OVTheme.body(12))
                                .foregroundStyle(OVTheme.ink.opacity(0.56))
                        }

                        PhotosPicker(selection: $pickerItems, maxSelectionCount: 3, matching: .images) {
                            HStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                Text("Choose images")
                            }
                            .font(OVTheme.heading(14))
                            .foregroundStyle(OVTheme.midnight)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(OVTheme.sky.opacity(0.52))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)

                        if !selectedImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(selectedImages) { item in
                                        Image(uiImage: item.image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 110, height: 110)
                                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(OVTheme.midnight)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Post") {
                        if store.addCreationFeedPost(
                            kind: selectedKind,
                            caption: caption,
                            scriptureReference: scriptureReference,
                            imageDataItems: selectedImages.map(\.data)
                        ) {
                            dismiss()
                        }
                    }
                    .foregroundStyle(OVTheme.midnight)
                    .disabled(caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onChange(of: pickerItems) { _, newItems in
                Task {
                    await loadImages(from: newItems)
                }
            }
        }
    }

    private var creationKindChips: some View {
        FlexibleChipRow(items: CreationPostKind.allCases, selected: selectedKind) { kind in
            selectedKind = kind
        }
    }

    private func loadImages(from items: [PhotosPickerItem]) async {
        var loaded: [CreationComposerImage] = []

        for item in items.prefix(3) {
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                continue
            }
            loaded.append(CreationComposerImage(image: image, data: data))
        }

        await MainActor.run {
            selectedImages = loaded
        }
    }
}

private struct CreationCommentsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: SoulJourneyStore
    let postID: UUID

    @State private var commentDraft = ""

    private var post: CreationFeedPost? {
        store.creationFeedPosts.first(where: { $0.id == postID })
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if let post {
                            Text(post.caption)
                                .font(OVTheme.body(15))
                                .foregroundStyle(OVTheme.ink.opacity(0.8))
                                .padding(16)
                                .glorifyCard(cornerRadius: 20)

                            ForEach(post.comments) { comment in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("\(comment.authorName) \(comment.handle)")
                                        .font(OVTheme.heading(14))
                                        .foregroundStyle(OVTheme.ink)

                                    Text(comment.text)
                                        .font(OVTheme.body(14))
                                        .foregroundStyle(OVTheme.ink.opacity(0.78))
                                }
                                .padding(14)
                                .glorifyCard(cornerRadius: 18)
                            }
                        }
                    }
                    .padding(20)
                }

                VStack(alignment: .leading, spacing: 10) {
                    TextField("Add a reply...", text: $commentDraft)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        if store.addCreationComment(to: postID, text: commentDraft) {
                            commentDraft = ""
                        }
                    } label: {
                        Text("Reply")
                            .font(OVTheme.heading(15))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(OVTheme.midnight)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(commentDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(commentDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.45 : 1)
                }
                .padding(16)
                .background(.white.opacity(0.96))
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("Replies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(OVTheme.midnight)
                }
            }
        }
    }
}

private struct CreationAttachmentGrid: View {
    @ObservedObject var store: SoulJourneyStore
    let fileNames: [String]

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(fileNames, id: \.self) { fileName in
                if let image = image(for: fileName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: fileNames.count == 1 ? 190 : 120)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
        }
    }

    private func image(for fileName: String) -> UIImage? {
        guard let url = store.creationAttachmentURL(for: fileName),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }
}

private struct GlorifySchoolPreviewView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Bible School creator space")
                        .font(OVTheme.display(32))
                        .foregroundStyle(OVTheme.midnight)

                    Text("Go from private rhythm into a richer community space where creations can be shared, responded to, and built out more deeply.")
                        .font(OVTheme.body(15))
                        .foregroundStyle(OVTheme.ink.opacity(0.74))

                    VStack(alignment: .leading, spacing: 10) {
                        previewRow("Longer creation posts with more room for story and meaning")
                        previewRow("Up to 3 images attached to each post")
                        previewRow("Reply threads that make the space feel more alive")
                        previewRow("A calmer aesthetic feed centered on Jesus, not noise")
                    }
                    .padding(20)
                    .glorifyCard()
                }
                .padding(20)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(OVTheme.midnight)
                }
            }
        }
    }

    private func previewRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(OVTheme.gold)

            Text(text)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.76))
        }
    }
}

private struct FlexibleChipRow<Item: Hashable & Identifiable & RawRepresentable>: View where Item.RawValue == String {
    let items: [Item]
    let selected: Item
    let action: (Item) -> Void

    var body: some View {
        let columns = [GridItem(.adaptive(minimum: 110), spacing: 10)]
        return LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
            ForEach(items) { item in
                Button {
                    action(item)
                } label: {
                    Text(item.rawValue)
                        .font(OVTheme.body(13))
                        .foregroundStyle(selected == item ? .white : OVTheme.midnight)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(selected == item
                                    ? OVTheme.midnight : OVTheme.smoke)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private extension View {
    func glorifyCard(cornerRadius: CGFloat = 24, fill: Color = OVTheme.cardBackground) -> some View {
        premiumSurfaceCard(cornerRadius: cornerRadius, fill: fill, shadowOpacity: 0.06)
    }
}

struct GlorifyView_Previews: PreviewProvider {
    static var previews: some View {
        GlorifyView(
            store: SoulJourneyStore(),
            accessManager: SubscriptionAccessManager(),
            jumpTarget: .constant(nil)
        )
    }
}
