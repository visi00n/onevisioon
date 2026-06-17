import SwiftUI
import UIKit

struct ScriptureHomeView: View {
    @ObservedObject var store: SoulJourneyStore
    let openGlorifyGifts: () -> Void
    let openProfile: () -> Void

    @State private var showStreakCalendarSheet = false
    @State private var showBibleNotesSheet = false
    @State private var dailyVerseSharePayload: DailyVerseSharePayload?
    @State private var streakCalendarDetent: PresentationDetent = .large

    private var continueLocation: BibleLocation {
        store.continueBibleLocation
    }

    private var dailyVerse: DailyBibleVerse? {
        BibleDataProvider.dailyVerse(version: store.selectedBibleVersion)
    }

    private var readingPlan: ReadingRecommendationPlan {
        ReadingRecommendationPlan.build(
            profile: store.onboardingProfile,
            lastReadLocation: store.lastReadBibleLocation,
            reflectionStreak: store.currentReflectionStreak,
            date: .now
        )
    }

    private var focusedStruggleTopic: StruggleSupportTopic {
        StruggleSupportCatalog.selectedTopic(for: store.onboardingProfile)
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
            ScrollView {
                LazyVStack(spacing: OVTheme.cardSpacing) {
                    if let dailyVerse {
                        dailyVerseCard(dailyVerse)
                        quickAccessGrid
                        howToPrayCard
                        iFeelCard
                        struggleHelperCard
                        whereShouldIReadCard(readingPlan)
                        if let dailyGiftFocus {
                            giftFocusCard(dailyGiftFocus)
                        } else {
                            discoverGiftsCard
                        }
                        profileCalloutCard
                    }
                }
                .padding(.horizontal, OVTheme.screenHorizontalPadding)
                .padding(.vertical, OVTheme.screenVerticalPadding)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        streakCalendarDetent = .large
                        showStreakCalendarSheet = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(OVTheme.midnight)

                            Text("\(store.currentStreak)")
                                .font(OVTheme.heading(14))
                                .foregroundStyle(OVTheme.midnight)
                        }
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(OVTheme.elevatedCard)
                        .overlay(
                            Capsule()
                                .stroke(OVTheme.line, lineWidth: 1)
                        )
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    AppInfoButton()
                }
            }
            .sheet(isPresented: $showStreakCalendarSheet) {
                StreakCalendarSheetView(store: store)
                    .presentationDetents([.fraction(0.6), .large], selection: $streakCalendarDetent)
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showBibleNotesSheet) {
                BibleVerseNotesSheet(store: store)
            }
            .sheet(item: $dailyVerseSharePayload, onDismiss: {
                cleanupDailyVerseSharePayload()
            }) { payload in
                ActivityShareSheet(activityItems: payload.activityItems)
            }
        }
    }

    private var iFeelCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("I feel...")
                        .font(OVTheme.heading(20))
                        .foregroundStyle(OVTheme.ink)

                    Text("Tap what feels most honest right now, then let the app point you to verses, a guide, and a prayer.")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.muted)
                }

                Spacer()

                Text("Quick help")
                    .font(OVTheme.body(11))
                    .foregroundStyle(OVTheme.midnight)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(OVTheme.smoke)
                    .clipShape(Capsule())
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ],
                spacing: 10
            ) {
                ForEach(FeelingShortcut.all) { feeling in
                    NavigationLink {
                        FeelingResponseView(
                            store: store,
                            shortcut: feeling
                        )
                    } label: {
                        Text(feeling.label)
                            .font(OVTheme.heading(14))
                            .foregroundStyle(OVTheme.midnight)
                            .frame(maxWidth: .infinity)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                            .padding(.vertical, 12)
                            .background(feeling.accent.opacity(0.16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(OVTheme.line, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(OVTheme.cardPadding)
        .ovSurfaceCard(cornerRadius: 24)
    }

    private var struggleHelperCard: some View {
        let topic = focusedStruggleTopic

        return NavigationLink {
            StruggleSupportView(store: store)
        } label: {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(hex: topic.accentHex).opacity(0.28))
                        .frame(width: 48, height: 48)

                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(OVTheme.midnight)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Freedom")
                        .font(OVTheme.heading(20))
                        .foregroundStyle(OVTheme.ink)

                    Text("Daily help for \(topic.title.lowercased())")
                        .font(OVTheme.heading(15))
                        .foregroundStyle(OVTheme.midnight)

                    Text("Open Scripture, prayer, and one next step for the area you chose in onboarding.")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.muted)
                        .lineLimit(3)
                }

                Spacer(minLength: 10)

                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(OVTheme.midnight)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(OVTheme.cardPadding)
            .ovSurfaceCard(cornerRadius: 22)
        }
        .buttonStyle(.plain)
    }

    private var profileCalloutCard: some View {
        Button(action: openProfile) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(OVTheme.lemon.opacity(0.48))
                        .frame(width: 48, height: 48)

                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(OVTheme.midnight)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("Go to your Profile")
                        .font(OVTheme.heading(20))
                        .foregroundStyle(OVTheme.ink)

                    Text("Edit your name, bio, testimony, settings, and saved growth details.")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.muted)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 8)

                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(OVTheme.midnight)
                    .padding(.top, 5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(OVTheme.cardPadding)
            .premiumSurfaceCard(cornerRadius: 22, fill: OVTheme.elevatedCard)
        }
        .buttonStyle(.plain)
    }

    private func whereShouldIReadCard(_ plan: ReadingRecommendationPlan) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Where should I read today?")
                .font(OVTheme.heading(20))
                .foregroundStyle(OVTheme.ink)

            Text("From what you told us in onboarding, this is a strong place to start today if you want a chapter that fits your season.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.muted)

            NavigationLink {
                WhereShouldIReadTodayView(
                    store: store,
                    plan: plan
                )
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Read \(plan.primary.reference)")
                            .font(OVTheme.heading(16))
                            .foregroundStyle(OVTheme.midnight)

                        Text(plan.primary.title)
                            .font(OVTheme.body(13))
                            .foregroundStyle(OVTheme.ink.opacity(0.74))
                            .lineLimit(2)
                    }

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(OVTheme.midnight)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(plan.primary.accent.opacity(0.14))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(OVTheme.line, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(OVTheme.cardPadding)
        .ovSurfaceCard(cornerRadius: 24)
    }

    private var quickAccessGrid: some View {
        let chapter = BibleDataProvider.chapter(
            at: continueLocation,
            version: store.selectedBibleVersion
        )

        return LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            NavigationLink {
                BibleChapterReaderView(
                    store: store,
                    target: BibleReferenceTarget(location: continueLocation, verse: nil)
                )
            } label: {
                homeQuickAccessTile(
                    eyebrow: store.lastReadBibleLocation == nil ? "Start here" : "Continue",
                    title: chapter?.title ?? "\(continueLocation.book) \(continueLocation.chapter)",
                    detail: store.lastReadBibleLocation == nil ? "Open your first chapter" : "Pick up where you left off",
                    systemImage: "book.closed"
                )
            }
            .buttonStyle(.plain)

            Button {
                showBibleNotesSheet = true
            } label: {
                homeQuickAccessTile(
                    eyebrow: "Bible notes",
                    title: store.sortedBibleVerseNotes.isEmpty ? "No notes yet" : "\(store.sortedBibleVerseNotes.count) saved",
                    detail: store.sortedBibleVerseNotes.isEmpty ? "Highlights and notes will live here" : "Open your saved highlights and notes",
                    systemImage: "note.text"
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var howToPrayCard: some View {
        NavigationLink {
            HowToPrayView()
        } label: {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(OVTheme.sky.opacity(0.42))
                        .frame(width: 46, height: 46)

                    Image(systemName: "hands.sparkles")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(OVTheme.midnight)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("How to pray")
                        .font(OVTheme.heading(20))
                        .foregroundStyle(OVTheme.ink)

                    Text("Start with Psalm 23, then learn a simple prayer rhythm you can use every day.")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(3)
                }

                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(OVTheme.midnight)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(OVTheme.cardPadding)
            .ovSurfaceCard(cornerRadius: 22)
        }
        .buttonStyle(.plain)
    }

    private func homeQuickAccessTile(
        eyebrow: String,
        title: String,
        detail: String,
        systemImage: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(eyebrow.uppercased())
                    .font(OVTheme.body(10))
                    .foregroundStyle(OVTheme.muted)

                Spacer()

                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(OVTheme.midnight.opacity(0.68))
            }

            Text(title)
                .font(OVTheme.heading(18))
                .foregroundStyle(OVTheme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)

            Text(detail)
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, minHeight: 138, alignment: .topLeading)
        .padding(16)
        .ovSurfaceCard(cornerRadius: 22)
    }

    private func dailyVerseCard(_ dailyVerse: DailyBibleVerse) -> some View {
        let isLiked = store.isBibleVerseLiked(dailyVerse.referenceText)
        let communityLikes = BibleDataProvider.communityLikeCount(for: dailyVerse) + (isLiked ? 1 : 0)
        let verseTarget = BibleReferenceTarget(
            location: dailyVerse.location,
            verse: dailyVerse.verse.verse
        )

        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily verse")
                        .font(OVTheme.heading(20))
                        .foregroundStyle(OVTheme.ink)

                    Text(Date.now.formatted(date: .abbreviated, time: .omitted))
                        .font(OVTheme.body(12))
                        .foregroundStyle(OVTheme.muted)
                }

                Spacer()

                HStack(spacing: 6) {
                    Text(dailyVerse.version.shortName)
                    Text("Updates daily")
                }
                .font(OVTheme.body(11))
                .foregroundStyle(OVTheme.midnight)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(OVTheme.smoke)
                .clipShape(Capsule())
            }

            NavigationLink {
                BibleChapterReaderView(store: store, target: verseTarget)
            } label: {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Text(dailyVerse.referenceText)
                            .font(OVTheme.heading(15))
                            .foregroundStyle(OVTheme.midnight)

                        Spacer()

                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(OVTheme.ink.opacity(0.42))
                    }

                    Text(dailyVerse.verse.text)
                        .font(OVTheme.body(18))
                        .foregroundStyle(OVTheme.ink.opacity(0.82))
                        .lineLimit(3)
                        .lineSpacing(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(OVTheme.smoke.opacity(0.88))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(OVTheme.line, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)

            HStack(spacing: 10) {
                Button {
                    shareDailyVerseCard(dailyVerse)
                } label: {
                    homeIconAction(
                        systemImage: "square.and.arrow.up",
                        foreground: OVTheme.midnight
                    )
                }
                .buttonStyle(.plain)

                Button {
                    store.toggleBibleVerseLike(dailyVerse.referenceText)
                } label: {
                    homeIconAction(
                        systemImage: isLiked ? "heart.fill" : "heart",
                        value: communityLikes.formatted(),
                        foreground: isLiked ? OVTheme.coral : OVTheme.midnight
                    )
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
            .padding(OVTheme.cardPadding)
            .ovSurfaceCard(cornerRadius: 24)
    }

    private var discoverGiftsCard: some View {
        Button {
            openGlorifyGifts()
        } label: {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(OVTheme.lemon.opacity(0.42))
                        .frame(width: 46, height: 46)

                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(OVTheme.midnight)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Take your gift discovery quiz")
                        .font(OVTheme.heading(18))
                        .foregroundStyle(OVTheme.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Answer once, then let Glorify guide you day by day with habits, Scripture, and practical steps.")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(OVTheme.midnight)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(OVTheme.cardPadding)
            .ovSurfaceCard(cornerRadius: 22)
        }
        .buttonStyle(.plain)
    }

    private func giftFocusCard(_ focus: GiftDailyFocus) -> some View {
        Button {
            openGlorifyGifts()
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(homeGiftAccent(focus.gift))
                            .frame(width: 46, height: 46)

                        Image(systemName: focus.gift.symbol)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(OVTheme.midnight)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Today's gift focus")
                            .font(OVTheme.heading(18))
                            .foregroundStyle(OVTheme.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("Step \(focus.dayNumber) • \(focus.gift.title)")
                            .font(OVTheme.body(12))
                            .foregroundStyle(OVTheme.gold)
                    }

                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(OVTheme.midnight)
                        .padding(.top, 4)
                }

                ProgressView(value: Double(focus.dayNumber), total: Double(max(focus.totalSteps, focus.dayNumber)))
                    .tint(OVTheme.gold)

                VStack(alignment: .leading, spacing: 6) {
                    Text(focus.title)
                        .font(OVTheme.heading(17))
                        .foregroundStyle(OVTheme.midnight)

                    Text(focus.detail)
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(3)

                    Text(focus.actionStep)
                        .font(OVTheme.body(13))
                        .foregroundStyle(OVTheme.ink.opacity(0.8))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                HStack(spacing: 10) {
                    homeStatChip("Gift", focus.gift.title)
                    homeStatChip("Streak", "\(store.giftTrainingStreak) days")
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(OVTheme.cardPadding)
            .ovSurfaceCard(cornerRadius: 22)
        }
        .buttonStyle(.plain)
    }

    private func homeGiftAccent(_ gift: SpiritualGiftKind) -> Color {
        switch gift {
        case .encouragement:
            return OVTheme.orchid.opacity(0.34)
        case .service:
            return OVTheme.mint.opacity(0.34)
        case .teaching:
            return OVTheme.sky.opacity(0.34)
        case .mercy:
            return OVTheme.lemon.opacity(0.34)
        case .leadership:
            return OVTheme.sand.opacity(0.38)
        case .creativity:
            return OVTheme.lemon.opacity(0.44)
        }
    }

    @MainActor
    private func shareDailyVerseCard(_ dailyVerse: DailyBibleVerse) {
        cleanupDailyVerseSharePayload()

        let renderer = ImageRenderer(
            content: DailyVerseShareGraphic(dailyVerse: dailyVerse)
                .frame(width: 360, height: 520)
        )
        renderer.scale = 3

        guard let image = renderer.uiImage, let data = image.pngData() else {
            dailyVerseSharePayload = DailyVerseSharePayload(shareText: dailyVerse.shareText, fileURL: nil)
            return
        }

        let filename = [
            "onevisioon-daily-verse",
            dailyVerse.location.book
                .lowercased()
                .replacingOccurrences(of: " ", with: "-"),
            "\(dailyVerse.location.chapter)",
            "\(dailyVerse.verse.verse)",
            UUID().uuidString
        ].joined(separator: "-") + ".png"

        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        do {
            try data.write(to: url, options: .atomic)
            dailyVerseSharePayload = DailyVerseSharePayload(
                shareText: dailyVerse.shareText,
                fileURL: url
            )
        } catch {
            dailyVerseSharePayload = DailyVerseSharePayload(shareText: dailyVerse.shareText, fileURL: nil)
        }
    }

    private func cleanupDailyVerseSharePayload() {
        if let fileURL = dailyVerseSharePayload?.fileURL {
            try? FileManager.default.removeItem(at: fileURL)
        }
        dailyVerseSharePayload = nil
    }

}

struct FullBibleView: View {
    @ObservedObject var store: SoulJourneyStore
    @Binding var externalTarget: BibleReferenceTarget?

    var body: some View {
        NavigationStack {
            BibleLibraryScreen(store: store, externalTarget: $externalTarget)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Menu {
                            ForEach(BibleVersion.allCases) { version in
                                Button {
                                    store.setBibleVersion(version)
                                } label: {
                                    if version == store.selectedBibleVersion {
                                        Label(version.shortName, systemImage: "checkmark")
                                    } else {
                                        Text(version.shortName)
                                    }
                                }
                            }
                        } label: {
                            Text(store.selectedBibleVersion.shortName)
                                .font(OVTheme.heading(13))
                                .foregroundStyle(OVTheme.midnight)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(OVTheme.elevatedCard)
                                .overlay(
                                    Capsule()
                                        .stroke(OVTheme.line, lineWidth: 1)
                                )
                                .clipShape(Capsule())
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        AppInfoButton()
                    }
                }
        }
    }
}

private struct HowToPrayView: View {
    private let psalmLines = [
        "The Lord is my shepherd; I shall not want.",
        "He maketh me to lie down in green pastures: he leadeth me beside the still waters.",
        "He restoreth my soul: he leadeth me in the paths of righteousness for his name's sake.",
        "Yea, though I walk through the valley of the shadow of death, I will fear no evil: for thou art with me; thy rod and thy staff they comfort me.",
        "Thou preparest a table before me in the presence of mine enemies: thou anointest my head with oil; my cup runneth over.",
        "Surely goodness and mercy shall follow me all the days of my life: and I will dwell in the house of the Lord for ever."
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: OVTheme.cardSpacing) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("How to pray")
                        .font(OVTheme.display(34))
                        .foregroundStyle(OVTheme.midnight)

                    Text("Start with Scripture. Let the words slow you down, then answer God honestly in your own words.")
                        .font(OVTheme.body(15))
                        .foregroundStyle(OVTheme.ink.opacity(0.74))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(OVTheme.cardPadding)
                .ovSurfaceCard(cornerRadius: 24)

                VStack(alignment: .leading, spacing: 14) {
                    Text("Psalm 23")
                        .font(OVTheme.heading(22))
                        .foregroundStyle(OVTheme.midnight)

                    Text("A prayer of trust")
                        .font(OVTheme.body(12))
                        .foregroundStyle(OVTheme.gold)

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(psalmLines.enumerated()), id: \.offset) { index, line in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(OVTheme.body(11))
                                    .foregroundStyle(OVTheme.gold)
                                    .frame(width: 18, alignment: .leading)

                                Text(line)
                                    .font(OVTheme.body(16))
                                    .foregroundStyle(OVTheme.ink.opacity(0.82))
                                    .lineSpacing(2)
                            }
                        }
                    }
                    .padding(16)
                    .background(OVTheme.paper.opacity(0.96))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(OVTheme.line, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(OVTheme.cardPadding)
                .ovSurfaceCard(cornerRadius: 24)

                NavigationLink {
                    PrayerTeachingView()
                } label: {
                    HStack {
                        Text("Teach me how to pray")
                            .font(OVTheme.heading(16))
                            .foregroundStyle(.white)

                        Spacer()

                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(OVTheme.midnight)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, OVTheme.screenHorizontalPadding)
            .padding(.vertical, OVTheme.screenVerticalPadding)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle("Prayer")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct PrayerTeachingView: View {
    private let steps: [PrayerTeachingStep] = [
        PrayerTeachingStep(
            title: "Start with who God is",
            detail: "Before asking for anything, slow down and remember His character: Father, Shepherd, Savior, King."
        ),
        PrayerTeachingStep(
            title: "Be honest about where you are",
            detail: "Tell God what is actually happening in your heart. Prayer is not performance. It is coming near in truth."
        ),
        PrayerTeachingStep(
            title: "Confess and receive mercy",
            detail: "Name what needs repentance, then trust that Jesus is not surprised by your weakness."
        ),
        PrayerTeachingStep(
            title: "Ask for what you need",
            detail: "Bring your needs, burdens, decisions, family, future, and temptations before Him clearly."
        ),
        PrayerTeachingStep(
            title: "Leave with obedience",
            detail: "End by asking: what is one faithful step I can take today?"
        )
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: OVTheme.cardSpacing) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("A simple way to pray")
                        .font(OVTheme.display(32))
                        .foregroundStyle(OVTheme.midnight)

                    Text("You do not need perfect words. Begin with God, tell the truth, ask for help, and take one obedient step.")
                        .font(OVTheme.body(15))
                        .foregroundStyle(OVTheme.ink.opacity(0.74))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(OVTheme.cardPadding)
                .ovSurfaceCard(cornerRadius: 24)

                VStack(spacing: 12) {
                    ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                        PrayerTeachingStepCard(number: index + 1, step: step)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Try this now")
                        .font(OVTheme.heading(20))
                        .foregroundStyle(OVTheme.midnight)

                    Text("Lord, teach me to come to You honestly. Show me what I am carrying, what I need to confess, what I need to ask, and what step of obedience is in front of me today. In Jesus' name, amen.")
                        .font(OVTheme.body(15))
                        .foregroundStyle(OVTheme.ink.opacity(0.78))
                        .lineSpacing(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(OVTheme.cardPadding)
                .ovSurfaceCard(cornerRadius: 24)
            }
            .padding(.horizontal, OVTheme.screenHorizontalPadding)
            .padding(.vertical, OVTheme.screenVerticalPadding)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle("How to pray")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct PrayerTeachingStep: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let detail: String
}

private struct PrayerTeachingStepCard: View {
    let number: Int
    let step: PrayerTeachingStep

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(String(format: "%02d", number))
                .font(OVTheme.body(12))
                .foregroundStyle(OVTheme.gold)
                .frame(width: 28, alignment: .leading)

            VStack(alignment: .leading, spacing: 6) {
                Text(step.title)
                    .font(OVTheme.heading(18))
                    .foregroundStyle(OVTheme.midnight)

                Text(step.detail)
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.74))
                    .lineSpacing(2)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .ovSurfaceCard(cornerRadius: 22)
    }
}

struct BibleLibraryScreen: View {
    @ObservedObject var store: SoulJourneyStore
    @Binding var externalTarget: BibleReferenceTarget?

    @State private var query = ""
    @State private var jumpTarget: BibleReferenceTarget?
    @State private var showNotesSheet = false
    @FocusState private var isSearchFocused: Bool

    private let bookColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var cleanedQuery: String {
        query.trimmed
    }

    private var visibleOldTestamentBooks: [BibleBook] {
        filterBooks(BibleDataProvider.oldTestamentBooks(for: store.selectedBibleVersion))
    }

    private var visibleNewTestamentBooks: [BibleBook] {
        filterBooks(BibleDataProvider.newTestamentBooks(for: store.selectedBibleVersion))
    }

    private var continueLocation: BibleLocation {
        if let lastReadBibleLocation = store.lastReadBibleLocation,
           BibleDataProvider.chapter(at: lastReadBibleLocation, version: store.selectedBibleVersion) != nil {
            return lastReadBibleLocation
        }

        if let firstBook = BibleDataProvider.books(for: store.selectedBibleVersion).first {
            return BibleLocation(book: firstBook.name, chapter: 1)
        }

        return store.defaultBibleLocation
    }

    private var suggestedTarget: BibleReferenceTarget? {
        guard let target = BibleDataProvider.resolveReference(from: cleanedQuery),
              BibleDataProvider.chapter(at: target.location, version: store.selectedBibleVersion) != nil else {
            return nil
        }

        return target
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: OVTheme.cardSpacing) {
                searchCard
                continueCard
                testamentSection(title: "Old Testament", books: visibleOldTestamentBooks)
                testamentSection(title: "New Testament", books: visibleNewTestamentBooks)
            }
            .padding(.horizontal, OVTheme.screenHorizontalPadding)
            .padding(.vertical, OVTheme.screenVerticalPadding)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle("Bible")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $jumpTarget) { target in
            BibleChapterReaderView(store: store, target: target)
        }
        .overlay(alignment: .bottomTrailing) {
            BibleNotesFloatingButton(noteCount: store.sortedBibleVerseNotes.count) {
                showNotesSheet = true
            }
            .padding(.trailing, 20)
            .padding(.bottom, 18)
        }
        .sheet(isPresented: $showNotesSheet) {
            BibleVerseNotesSheet(store: store)
        }
        .onAppear {
            consumeExternalTargetIfNeeded()
        }
        .onChange(of: externalTarget) { _, _ in
            consumeExternalTargetIfNeeded()
        }
    }

    private var searchCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Find a chapter")
                        .font(OVTheme.heading(20))
                        .foregroundStyle(OVTheme.ink)

                    Text("Type a reference like John 3, Romans 8:28, or search by book name.")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.muted)
                }

                Spacer()

                if !store.sortedBibleVerseNotes.isEmpty {
                    Text("\(store.sortedBibleVerseNotes.count) notes")
                        .font(OVTheme.body(11))
                        .foregroundStyle(OVTheme.midnight)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(OVTheme.smoke)
                        .clipShape(Capsule())
                }
            }

            TextField("Try Genesis 1 or John 3:16", text: $query)
                .font(OVTheme.body(16))
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled(true)
                .keyboardType(.default)
                .submitLabel(.go)
                .focused($isSearchFocused)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(OVTheme.smoke.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(OVTheme.line, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .onSubmit {
                    guard let suggestedTarget else { return }
                    isSearchFocused = false
                    jumpTarget = suggestedTarget
                }

            if let suggestedTarget {
                Button {
                    isSearchFocused = false
                    jumpTarget = suggestedTarget
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Open \(referenceLabel(for: suggestedTarget))")
                                .font(OVTheme.heading(15))
                                .foregroundStyle(.white)
                            Text("Jump straight to that chapter.")
                                .font(OVTheme.body(12))
                                .foregroundStyle(.white.opacity(0.82))
                        }
                        Spacer()
                        Image(systemName: "arrow.right")
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(OVTheme.midnight)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
            } else if !cleanedQuery.isEmpty {
                Text("No exact chapter match yet. You can still browse the matching books below.")
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
            .padding(OVTheme.cardPadding)
            .ovSurfaceCard(cornerRadius: 24)
    }

    private var continueCard: some View {
        NavigationLink {
            BibleChapterReaderView(
                store: store,
                target: BibleReferenceTarget(location: continueLocation, verse: nil)
            )
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Continue reading")
                        .font(OVTheme.heading(16))
                        .foregroundStyle(OVTheme.ink)

                    Text("\(continueLocation.book) \(continueLocation.chapter)")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.midnight)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(OVTheme.ink.opacity(0.45))
            }
            .padding(OVTheme.cardPadding)
            .ovSurfaceCard(cornerRadius: 20)
        }
        .buttonStyle(.plain)
    }

    private func consumeExternalTargetIfNeeded() {
        guard let externalTarget else { return }

        let target = externalTarget
        self.externalTarget = nil

        guard BibleDataProvider.chapter(at: target.location, version: store.selectedBibleVersion) != nil else {
            return
        }

        if jumpTarget?.id == target.id {
            jumpTarget = nil
            DispatchQueue.main.async {
                jumpTarget = target
            }
            return
        }

        jumpTarget = target
    }

    private func testamentSection(title: String, books: [BibleBook]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(OVTheme.heading(22))
                    .foregroundStyle(OVTheme.ink)

                Spacer()

                Text("\(books.count) books")
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.muted)
            }

            if books.isEmpty {
                Text(emptyMessage(for: title))
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.muted)
                    .padding(.vertical, 8)
            } else {
                LazyVGrid(columns: bookColumns, spacing: 12) {
                    ForEach(books) { book in
                        NavigationLink {
                            BibleBookDetailView(store: store, book: book)
                        } label: {
                            bookCard(book)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func emptyMessage(for testamentTitle: String) -> String {
        if store.selectedBibleVersion.isNewTestamentOnly && testamentTitle == "Old Testament" {
            return "This translation does not include Old Testament books."
        }

        return "No books match that search."
    }

    private func bookCard(_ book: BibleBook) -> some View {
        let lastReadChapter = store.lastReadBibleLocation?.book == book.name ? store.lastReadBibleLocation?.chapter : nil

        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(book.name)
                    .font(OVTheme.heading(16))
                    .foregroundStyle(OVTheme.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)

                if lastReadChapter != nil {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(OVTheme.gold)
                }
            }

            Text("\(book.chapterCount) chapter\(book.chapterCount == 1 ? "" : "s")")
                .font(OVTheme.body(12))
                .foregroundStyle(OVTheme.muted)

            if let lastReadChapter {
                Text("Last read: \(lastReadChapter)")
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.midnight)
            } else {
                Text("Open book")
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.midnight)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
        .padding(16)
        .ovSurfaceCard(cornerRadius: 20)
    }

    private func filterBooks(_ books: [BibleBook]) -> [BibleBook] {
        guard !cleanedQuery.isEmpty else { return books }
        return books.filter { $0.name.localizedCaseInsensitiveContains(cleanedQuery) }
    }

    private func referenceLabel(for target: BibleReferenceTarget) -> String {
        if let verse = target.verse {
            return "\(target.location.book) \(target.location.chapter):\(verse)"
        }
        return "\(target.location.book) \(target.location.chapter)"
    }
}

struct BibleBookDetailView: View {
    @ObservedObject var store: SoulJourneyStore
    let book: BibleBook

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: OVTheme.cardSpacing) {
                headerCard

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(book.chapters) { chapter in
                        NavigationLink {
                            BibleChapterReaderView(
                                store: store,
                                target: BibleReferenceTarget(
                                    location: BibleLocation(book: book.name, chapter: chapter.chapter),
                                    verse: nil
                                )
                            )
                        } label: {
                            chapterCard(chapter.chapter)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, OVTheme.screenHorizontalPadding)
            .padding(.vertical, OVTheme.screenVerticalPadding)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle(book.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                homeStatChip("Chapters", "\(book.chapterCount)")
                homeStatChip("Version", store.selectedBibleVersion.shortName)

                if let lastReadBibleLocation = store.lastReadBibleLocation,
                   lastReadBibleLocation.book == book.name {
                    homeStatChip("Last read", "Ch. \(lastReadBibleLocation.chapter)")
                }
            }

            Text("Choose a chapter and your place will stay saved automatically.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(OVTheme.cardPadding)
        .ovSurfaceCard(cornerRadius: 22)
    }

    private func chapterCard(_ chapterNumber: Int) -> some View {
        let isLastRead = store.lastReadBibleLocation == BibleLocation(book: book.name, chapter: chapterNumber)

        return VStack(spacing: 6) {
            Text("\(chapterNumber)")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.midnight)

            Text(isLastRead ? "Current" : "Chapter")
                .font(OVTheme.body(11))
                .foregroundStyle(isLastRead ? OVTheme.midnight : OVTheme.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(isLastRead ? OVTheme.lemon.opacity(0.45) : OVTheme.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isLastRead ? OVTheme.gold.opacity(0.5) : OVTheme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct BibleChapterReaderView: View {
    @ObservedObject var store: SoulJourneyStore
    let target: BibleReferenceTarget

    @State private var hasScrolledToInitialVerse = false
    @State private var selectedVerseNumbers: Set<Int> = []
    @State private var showNotesSheet = false
    @State private var showNoteComposerSheet = false
    @State private var noteDraft = ""
    @State private var feedbackMessage = ""
    @State private var chapterSwipeTarget: BibleReferenceTarget?
    @State private var isHandlingChapterSwipe = false
    @State private var originalLanguagePassage: OriginalLanguageStudyPassage?

    private var chapter: BibleChapter? {
        BibleDataProvider.chapter(
            at: target.location,
            version: store.selectedBibleVersion
        )
    }

    private var previousLocation: BibleLocation? {
        BibleDataProvider.previousChapter(
            before: target.location,
            version: store.selectedBibleVersion
        )
    }

    private var nextLocation: BibleLocation? {
        BibleDataProvider.nextChapter(
            after: target.location,
            version: store.selectedBibleVersion
        )
    }

    private var hasActiveSelection: Bool {
        !selectedVerseNumbers.isEmpty
    }

    private var selectedVerses: [BibleVerse] {
        guard let chapter else { return [] }
        return chapter.verses
            .filter { selectedVerseNumbers.contains($0.verse) }
            .sorted(by: { $0.verse < $1.verse })
    }

    private var selectedVerseReferences: [String] {
        selectedVerses.map { verseReference(for: $0) }
    }

    private var selectedShareText: String {
        selectedVerses.map { verse in
            var lines = [
                verseReference(for: verse),
                verse.text
            ]

            if store.selectedBibleVersion.isOriginalLanguage,
               let englishText = englishVerseText(for: verse) {
                lines.append("English")
                lines.append(englishText)
            }

            return lines.joined(separator: "\n")
        }
        .joined(separator: "\n\n")
    }

    private var selectedHighlightStyle: BibleHighlightStyle? {
        let styles = Set(selectedVerseReferences.compactMap { store.bibleVerseHighlightStyle(for: $0) })
        guard styles.count == 1 else { return nil }
        return styles.first
    }

    private var hasSelectedHighlights: Bool {
        selectedVerseReferences.contains(where: store.isBibleVerseHighlighted)
    }

    var body: some View {
        Group {
            if let chapter {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            chapterNavigation
                            verseList(chapter)
                            chapterNavigation
                        }
                        .padding(.horizontal, OVTheme.screenHorizontalPadding)
                        .padding(.vertical, OVTheme.screenVerticalPadding)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .background(OVTheme.mainBackground.ignoresSafeArea())
                    .navigationTitle(chapter.title)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationDestination(item: $chapterSwipeTarget) { target in
                        BibleChapterReaderView(store: store, target: target)
                    }
                    .simultaneousGesture(chapterSwipeGesture)
                    .onAppear {
                        store.saveLastReadBibleLocation(target.location)
                        guard let verse = target.verse, !hasScrolledToInitialVerse else { return }
                        hasScrolledToInitialVerse = true
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(verse, anchor: .top)
                            }
                        }
                    }
                    .safeAreaInset(edge: .bottom) {
                        if hasActiveSelection {
                            verseSelectionBar
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                                .padding(.bottom, 6)
                        }
                    }
                    .overlay(alignment: .bottomTrailing) {
                        BibleNotesFloatingButton(noteCount: store.sortedBibleVerseNotes.count) {
                            showNotesSheet = true
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, hasActiveSelection ? 112 : 18)
                    }
                    .overlay(alignment: .top) {
                        if !feedbackMessage.isEmpty {
                            Text(feedbackMessage)
                                .font(OVTheme.body(13))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(OVTheme.midnight)
                                .clipShape(Capsule())
                                .padding(.top, 10)
                        }
                    }
                    .sheet(isPresented: $showNotesSheet) {
                        BibleVerseNotesSheet(store: store)
                    }
                    .sheet(isPresented: $showNoteComposerSheet) {
                        BibleVerseNoteComposerSheet(
                            references: selectedVerseReferences,
                            noteText: $noteDraft,
                            navigationTitle: "New note",
                            saveButtonTitle: "Save"
                        ) {
                            if store.addBibleVerseNote(references: selectedVerseReferences, text: noteDraft) {
                                noteDraft = ""
                                showNoteComposerSheet = false
                                clearSelection()
                                showFeedback("Note saved")
                            }
                        }
                    }
                    .sheet(item: $originalLanguagePassage) { passage in
                        OriginalLanguageStudySheet(passage: passage)
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Text("Chapter not found")
                        .font(OVTheme.heading(24))
                        .foregroundStyle(OVTheme.ink)

                    Text("This chapter could not be loaded from the Bible library.")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.muted)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(OVTheme.mainBackground.ignoresSafeArea())
            }
        }
    }

    private var chapterNavigation: some View {
        HStack(spacing: 12) {
            if let previousLocation {
                NavigationLink {
                    BibleChapterReaderView(
                        store: store,
                        target: BibleReferenceTarget(location: previousLocation, verse: nil)
                    )
                } label: {
                    chapterNavButton(title: "Previous")
                }
                .buttonStyle(.plain)
            }

            if let nextLocation {
                NavigationLink {
                    BibleChapterReaderView(
                        store: store,
                        target: BibleReferenceTarget(location: nextLocation, verse: nil)
                    )
                } label: {
                    chapterNavButton(title: "Next")
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var chapterSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 72, coordinateSpace: .local)
            .onEnded { value in
                guard !isHandlingChapterSwipe else { return }

                let actualHorizontal = value.translation.width
                let actualVertical = value.translation.height
                let predictedHorizontal = value.predictedEndTranslation.width
                let predictedVertical = value.predictedEndTranslation.height

                guard abs(actualHorizontal) > 90,
                      abs(predictedHorizontal) > 120,
                      abs(actualHorizontal) > abs(actualVertical) * 1.4,
                      abs(predictedHorizontal) > abs(predictedVertical) * 1.65 else { return }

                let destination: BibleLocation?
                if predictedHorizontal < 0 {
                    destination = nextLocation
                } else {
                    destination = previousLocation
                }

                guard let destination else { return }

                isHandlingChapterSwipe = true
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.easeInOut(duration: 0.22)) {
                    chapterSwipeTarget = BibleReferenceTarget(location: destination, verse: nil)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    isHandlingChapterSwipe = false
                }
            }
    }

    private func verseList(_ chapter: BibleChapter) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(chapter.verses) { verse in
                let reference = verseReference(for: verse)
                let isSelected = selectedVerseNumbers.contains(verse.verse)
                let highlightStyle = store.bibleVerseHighlightStyle(for: reference)
                let hasNote = store.hasBibleVerseNote(for: reference)
                let isFocused = verse.verse == target.verse

                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(verse.verse)")
                            .font(OVTheme.heading(13))
                            .foregroundStyle(OVTheme.gold)

                        if hasNote {
                            Image(systemName: "note.text")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(OVTheme.midnight.opacity(0.6))
                        }
                    }
                    .frame(width: 30, alignment: .leading)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(verse.text)
                            .font(OVTheme.body(17))
                            .foregroundStyle(OVTheme.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineSpacing(4)

                        if store.selectedBibleVersion.isOriginalLanguage,
                           isSelected,
                           let englishText = englishVerseText(for: verse) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("English")
                                    .font(OVTheme.body(11))
                                    .foregroundStyle(OVTheme.gold)

                                Text(englishText)
                                    .font(OVTheme.body(15))
                                    .foregroundStyle(OVTheme.ink.opacity(0.72))
                                    .lineSpacing(3)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 4)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 10)
                .background(
                    verseBackground(
                        isSelected: isSelected,
                        highlightStyle: highlightStyle,
                        isFocused: isFocused
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(
                            verseStroke(
                                isSelected: isSelected,
                                highlightStyle: highlightStyle,
                                isFocused: isFocused
                            ),
                            lineWidth: 1
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .onTapGesture {
                    toggleVerseSelection(verse.verse, activateSelection: !hasActiveSelection)
                }
                .onLongPressGesture(minimumDuration: 0.35) {
                    toggleVerseSelection(verse.verse, activateSelection: true)
                }
                .id(verse.verse)
            }
        }
    }

    private func chapterNavButton(title: String) -> some View {
        HStack {
            if title == "Previous" {
                Image(systemName: "arrow.left")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(OVTheme.midnight)
            }

            Text(title)
                .font(OVTheme.heading(15))
                .foregroundStyle(OVTheme.midnight)

            Spacer()

            if title == "Next" {
                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(OVTheme.midnight)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .ovSurfaceCard(cornerRadius: 18)
    }

    private var verseSelectionBar: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(selectedVerseNumbers.count) verse\(selectedVerseNumbers.count == 1 ? "" : "s") selected")
                    .font(OVTheme.heading(14))
                    .foregroundStyle(OVTheme.midnight)

                Spacer()

                Button("Clear") {
                    clearSelection()
                }
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.muted)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    if OriginalLanguageStudyProvider.supportsOriginalLanguage(for: target.location) {
                        Button {
                            openOriginalLanguageStudy()
                        } label: {
                            originalLanguageActionChip
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        UIPasteboard.general.string = selectedShareText
                        showFeedback("Copied selection")
                    } label: {
                        verseActionChip(title: "Copy", systemImage: "doc.on.doc")
                    }
                    .buttonStyle(.plain)

                    ShareLink(item: selectedShareText) {
                        verseActionChip(title: "Share", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.plain)

                    ForEach(BibleHighlightStyle.allCases) { style in
                        Button {
                            store.setBibleVerseHighlight(selectedVerseReferences, style: style)
                            showFeedback("\(style.title) highlight added")
                        } label: {
                            highlightColorDot(
                                style: style,
                                isSelected: selectedHighlightStyle == style
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    if hasSelectedHighlights {
                        Button {
                            store.clearBibleVerseHighlight(selectedVerseReferences)
                            showFeedback("Highlight removed")
                        } label: {
                            verseActionChip(title: "Clear color", systemImage: "highlighter")
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        noteDraft = ""
                        let unhighlightedReferences = selectedVerseReferences.filter {
                            !store.isBibleVerseHighlighted($0)
                        }
                        if !unhighlightedReferences.isEmpty {
                            store.setBibleVerseHighlight(
                                unhighlightedReferences,
                                style: selectedHighlightStyle ?? .butter
                            )
                        }
                        showNoteComposerSheet = true
                    } label: {
                        verseActionChip(title: "Note", systemImage: "note.text.badge.plus")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .ovSurfaceCard(cornerRadius: 22, fill: OVTheme.elevatedCard, shadowOpacity: 0.1)
    }

    private var originalLanguageActionChip: some View {
        HStack(spacing: 8) {
            Text("Ἑ")
                .font(OVTheme.heading(14))

            Text("Greek study")
                .font(OVTheme.heading(13))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(OVTheme.midnight)
        .clipShape(Capsule())
    }

    private func openOriginalLanguageStudy() {
        guard let passage = OriginalLanguageStudyProvider.passage(
            for: target.location,
            selectedVerses: selectedVerses,
            selectedVersion: store.selectedBibleVersion
        ) else {
            showFeedback("Greek study is not available here yet")
            return
        }

        originalLanguagePassage = passage
    }

    private func verseReference(for verse: BibleVerse) -> String {
        "\(target.location.book) \(target.location.chapter):\(verse.verse)"
    }

    private func englishVerseText(for verse: BibleVerse) -> String? {
        BibleDataProvider.chapter(at: target.location, version: .esv)?
            .verses
            .first(where: { $0.verse == verse.verse })?
            .text
    }

    private func verseBackground(
        isSelected: Bool,
        highlightStyle: BibleHighlightStyle?,
        isFocused: Bool
    ) -> Color {
        if isSelected {
            if let highlightStyle {
                return highlightFill(for: highlightStyle).opacity(0.96)
            }
            return OVTheme.sky.opacity(0.62)
        }

        if let highlightStyle {
            return highlightFill(for: highlightStyle)
        }

        if isFocused {
            return OVTheme.smoke.opacity(0.72)
        }

        return .clear
    }

    private func verseStroke(
        isSelected: Bool,
        highlightStyle: BibleHighlightStyle?,
        isFocused: Bool
    ) -> Color {
        if isSelected {
            if let highlightStyle {
                return highlightStroke(for: highlightStyle)
            }
            return OVTheme.midnight.opacity(0.2)
        }

        if let highlightStyle {
            return highlightStroke(for: highlightStyle)
        }

        if isFocused {
            return OVTheme.line.opacity(0.72)
        }

        return .clear
    }

    private func toggleVerseSelection(_ verseNumber: Int, activateSelection: Bool = false) {
        if activateSelection || hasActiveSelection {
            if selectedVerseNumbers.contains(verseNumber) {
                selectedVerseNumbers.remove(verseNumber)
            } else {
                selectedVerseNumbers.insert(verseNumber)
            }
        }
    }

    private func clearSelection() {
        selectedVerseNumbers.removeAll()
    }

    private func highlightFill(for style: BibleHighlightStyle) -> Color {
        switch style {
        case .butter:
            return Color(hex: "F6E08C").opacity(0.58)
        case .mint:
            return Color(hex: "BFE9CC").opacity(0.62)
        case .sky:
            return Color(hex: "BDDDFB").opacity(0.66)
        case .lilac:
            return Color(hex: "D8C5F4").opacity(0.66)
        }
    }

    private func highlightStroke(for style: BibleHighlightStyle) -> Color {
        switch style {
        case .butter:
            return Color(hex: "C7A84C").opacity(0.72)
        case .mint:
            return Color(hex: "5DA376").opacity(0.72)
        case .sky:
            return Color(hex: "5E90C7").opacity(0.72)
        case .lilac:
            return Color(hex: "8E72C8").opacity(0.72)
        }
    }

    private func showFeedback(_ message: String) {
        feedbackMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            if feedbackMessage == message {
                feedbackMessage = ""
            }
        }
    }
}

private struct OriginalLanguageStudySheet: View {
    let passage: OriginalLanguageStudyPassage

    @Environment(\.dismiss) private var dismiss
    @State private var selectedToken: OriginalLanguageWordToken?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: OVTheme.cardSpacing) {
                    headerCard
                    selectedTranslationCard

                    ForEach(passage.originalVerses) { verse in
                        originalVerseCard(verse)
                    }

                    if let selectedToken {
                        tokenDetailCard(selectedToken)
                    } else {
                        Text("Tap any Greek word to see what it means here, how to pronounce it, the English used in this verse, Strong's number, and grammar.")
                            .font(OVTheme.body(13))
                            .foregroundStyle(OVTheme.muted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(OVTheme.cardPadding)
                            .ovSurfaceCard(cornerRadius: 20)
                    }
                }
                .padding(.horizontal, OVTheme.screenHorizontalPadding)
                .padding(.vertical, OVTheme.screenVerticalPadding)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("Greek study")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(OVTheme.heading(14))
                    .foregroundStyle(OVTheme.midnight)
                }
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(passage.referenceTitle)
                .font(OVTheme.display(30))
                .foregroundStyle(OVTheme.midnight)

            Text("Original-language layer: \(passage.languageTitle)")
                .font(OVTheme.heading(14))
                .foregroundStyle(OVTheme.gold)

            Text("This shows your selected translation first, then the Greek text underneath. Word glosses are study helps, not one-to-one replacements for the full verse meaning.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))

            Text(passage.attribution)
                .font(OVTheme.body(11))
                .foregroundStyle(OVTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.elevatedCard)
    }

    private var selectedTranslationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Selected \(passage.selectedVersionName)")
                .font(OVTheme.heading(18))
                .foregroundStyle(OVTheme.midnight)

            ForEach(passage.selectedVerses) { verse in
                VStack(alignment: .leading, spacing: 6) {
                    Text(verse.reference)
                        .font(OVTheme.heading(12))
                        .foregroundStyle(OVTheme.gold)

                    Text(verse.text)
                        .font(OVTheme.body(15))
                        .foregroundStyle(OVTheme.ink)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(OVTheme.cardPadding)
        .ovSurfaceCard(cornerRadius: 22, fill: OVTheme.elevatedCard)
    }

    private func originalVerseCard(_ verse: OriginalLanguageStudyVerse) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("\(verse.reference) Greek")
                    .font(OVTheme.heading(18))
                    .foregroundStyle(OVTheme.midnight)

                Text(verse.originalText)
                    .font(.system(size: 21, weight: .regular, design: .serif))
                    .foregroundStyle(OVTheme.ink)
                    .lineSpacing(6)
                    .textSelection(.enabled)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: 10)], alignment: .leading, spacing: 10) {
                ForEach(verse.tokens) { token in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedToken = token
                        }
                    } label: {
                        tokenChip(token)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(OVTheme.cardPadding)
        .ovSurfaceCard(cornerRadius: 22, fill: OVTheme.elevatedCard)
    }

    private func tokenChip(_ token: OriginalLanguageWordToken) -> some View {
        VStack(spacing: 4) {
            Text(token.surface)
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(OVTheme.midnight)
                .lineLimit(1)
                .minimumScaleFactor(0.76)

            Text(token.transliteration.isEmpty ? "tap" : token.transliteration)
                .font(OVTheme.body(10))
                .foregroundStyle(OVTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, minHeight: 58)
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(selectedToken?.id == token.id ? OVTheme.lemon.opacity(0.62) : OVTheme.smoke.opacity(0.9))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(selectedToken?.id == token.id ? OVTheme.gold.opacity(0.75) : OVTheme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func tokenDetailCard(_ token: OriginalLanguageWordToken) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(token.surface)
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(OVTheme.midnight)

                Text(token.transliteration.isEmpty ? "Greek word" : token.transliteration)
                    .font(OVTheme.heading(16))
                    .foregroundStyle(OVTheme.gold)
            }

            originalLanguageDetailRow("Meaning in this place", token.glossSummary)

            originalLanguageDetailRow(
                "Pronunciation",
                token.transliteration.isEmpty ? "Pronunciation guide is being expanded for this word." : token.transliteration
            )

            originalLanguageDetailRow(
                "English used here",
                token.alignedEnglish.isEmpty ? "English alignment is being expanded for this word." : token.alignedEnglish
            )

            if !token.lemma.isEmpty {
                originalLanguageDetailRow("Dictionary form", token.lemma)
            }

            if !token.strongs.isEmpty {
                originalLanguageDetailRow("Strong’s", token.strongs)
            }

            if !token.morphology.isEmpty {
                originalLanguageDetailRow("Grammar", token.morphology)
            }

            Text(token.studyNote)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.78))
                .lineSpacing(4)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(OVTheme.cardPadding)
        .premiumSurfaceCard(cornerRadius: 24, fill: OVTheme.lemon.opacity(0.22), shadowOpacity: 0.05)
    }

    private func originalLanguageDetailRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(OVTheme.body(10))
                .foregroundStyle(OVTheme.muted)

            Text(value)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink)
        }
    }
}

private func homeStatChip(_ label: String, _ value: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        Text(label.uppercased())
            .font(OVTheme.body(10))
            .foregroundStyle(OVTheme.muted)

        Text(value)
            .font(OVTheme.heading(14))
            .foregroundStyle(OVTheme.midnight)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 10)
    .background(OVTheme.smoke.opacity(0.96))
    .overlay(
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .stroke(OVTheme.line, lineWidth: 1)
    )
    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
}

private func homeIconAction(systemImage: String, value: String? = nil, foreground: Color) -> some View {
    HStack(spacing: 6) {
        Image(systemName: systemImage)
            .font(.system(size: 12, weight: .bold))

        if let value {
            Text(value)
                .font(OVTheme.heading(13))
        }
    }
    .foregroundStyle(foreground)
    .padding(.horizontal, 12)
    .padding(.vertical, 10)
    .background(OVTheme.smoke.opacity(0.96))
    .overlay(
        Capsule()
            .stroke(OVTheme.line, lineWidth: 1)
    )
    .clipShape(Capsule())
}

private func verseActionChip(title: String, systemImage: String) -> some View {
    HStack(spacing: 8) {
        Image(systemName: systemImage)
            .font(.system(size: 12, weight: .bold))

        Text(title)
            .font(OVTheme.heading(13))
    }
    .foregroundStyle(OVTheme.midnight)
    .padding(.horizontal, 12)
    .padding(.vertical, 10)
    .background(OVTheme.smoke.opacity(0.96))
    .overlay(
        Capsule()
            .stroke(OVTheme.line, lineWidth: 1)
    )
    .clipShape(Capsule())
}

private func highlightColorDot(style: BibleHighlightStyle, isSelected: Bool) -> some View {
    Circle()
        .fill(highlightSwatch(for: style))
        .frame(width: 30, height: 30)
        .overlay {
            Circle()
                .stroke(isSelected ? OVTheme.midnight : .white.opacity(0.92), lineWidth: isSelected ? 2.5 : 1.5)
        }
        .overlay {
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(OVTheme.midnight)
            }
        }
        .shadow(color: .black.opacity(isSelected ? 0.12 : 0.05), radius: isSelected ? 8 : 4, y: 2)
        .accessibilityLabel(Text(style.title))
}

private func highlightSwatch(for style: BibleHighlightStyle) -> Color {
    switch style {
    case .butter:
        return Color(hex: "F3D66F")
    case .mint:
        return Color(hex: "98D9AD")
    case .sky:
        return Color(hex: "8EC6F5")
    case .lilac:
        return Color(hex: "C29BEA")
    }
}

private struct HomeStudyFocus: Hashable {
    let title: String
    let kicker: String
    let detail: String
    let prompt: String
    let badge: String
    let pathLabel: String
    let target: BibleReferenceTarget

    var chapterTitle: String {
        "\(target.location.book) \(target.location.chapter)"
    }

    static func pick(for profile: OnboardingAnswerSet, date: Date) -> HomeStudyFocus? {
        if let seasonal = seasonalFocus(for: date) {
            return seasonal
        }

        let key = profile.biggestChallenge.trimmed.lowercased()
        let options = focusMap[key] ?? fallbackFocuses
        guard !options.isEmpty else { return nil }

        let calendar = Calendar.current
        let ordinal = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        return options[(ordinal - 1) % options.count]
    }

    private static let focusMap: [String: [HomeStudyFocus]] = [
        "staying consistent": [
            focus(
                title: "Stay rooted in the Word",
                kicker: "For steady consistency",
                detail: "Hebrews 12 helps you keep running with endurance when the walk with God feels harder than you expected.",
                prompt: "What would steady obedience look like in the next 24 hours?",
                badge: "Personal",
                pathLabel: "Consistency",
                reference: "Hebrews 12"
            ),
            focus(
                title: "Delight before discipline",
                kicker: "For steady consistency",
                detail: "Psalm 1 shows that lasting consistency grows where delight in God's Word comes first.",
                prompt: "What habit is shaping you most right now: Scripture or distraction?",
                badge: "Personal",
                pathLabel: "Consistency",
                reference: "Psalms 1"
            ),
            focus(
                title: "Abide, do not drift",
                kicker: "For steady consistency",
                detail: "John 15 reframes spiritual growth as remaining close to Christ instead of trying harder alone.",
                prompt: "Where do you need to stay connected instead of self-reliant today?",
                badge: "Personal",
                pathLabel: "Consistency",
                reference: "John 15"
            )
        ],
        "hearing god clearly": [
            focus(
                title: "Learn the Shepherd's voice",
                kicker: "For hearing God clearly",
                detail: "John 10 anchors clarity in knowing the Shepherd, not in chasing louder feelings.",
                prompt: "What voice has been shaping your decisions more than Scripture lately?",
                badge: "Personal",
                pathLabel: "Clarity",
                reference: "John 10"
            ),
            focus(
                title: "Light for the next step",
                kicker: "For hearing God clearly",
                detail: "Psalm 119 teaches that God often gives enough light for faithful next steps, not the whole map at once.",
                prompt: "What next step is already clear, even if the full future is not?",
                badge: "Personal",
                pathLabel: "Clarity",
                reference: "Psalms 119"
            ),
            focus(
                title: "Ask for wisdom without splitting your heart",
                kicker: "For hearing God clearly",
                detail: "Proverbs 2 shows that God gives wisdom to people who seek Him with an honest heart.",
                prompt: "Where are you asking God for direction while still gripping control?",
                badge: "Personal",
                pathLabel: "Clarity",
                reference: "Proverbs 2"
            )
        ],
        "controlling thoughts": [
            focus(
                title: "Renew the mind",
                kicker: "For controlling thoughts",
                detail: "Romans 12 shows that transformation begins when the mind is reshaped by God instead of the world.",
                prompt: "What thought pattern needs to be surrendered instead of rehearsed today?",
                badge: "Personal",
                pathLabel: "Mind",
                reference: "Romans 12"
            ),
            focus(
                title: "Think on what is true",
                kicker: "For controlling thoughts",
                detail: "Philippians 4 does not ignore anxiety; it redirects the mind toward what is holy, good, and steady.",
                prompt: "What truth from God needs more room in your mind than fear today?",
                badge: "Personal",
                pathLabel: "Mind",
                reference: "Philippians 4"
            ),
            focus(
                title: "Take every thought captive",
                kicker: "For controlling thoughts",
                detail: "2 Corinthians 10 reminds you that inner battles are fought by bringing thoughts back under Christ.",
                prompt: "Which recurring thought needs to be confronted instead of believed?",
                badge: "Personal",
                pathLabel: "Mind",
                reference: "2 Corinthians 10"
            )
        ],
        "anxiety and peace": [
            focus(
                title: "Do not live under anxious striving",
                kicker: "For anxiety and peace",
                detail: "Matthew 6 meets anxiety by pulling your eyes back to the Father's care and the kingdom first.",
                prompt: "What burden feels heavy because you keep carrying what belongs to God?",
                badge: "Personal",
                pathLabel: "Peace",
                reference: "Matthew 6"
            ),
            focus(
                title: "Peace that guards the heart",
                kicker: "For anxiety and peace",
                detail: "Philippians 4 teaches peace through prayer, gratitude, and disciplined thought.",
                prompt: "What do you need to turn into prayer before this day gets louder?",
                badge: "Personal",
                pathLabel: "Peace",
                reference: "Philippians 4"
            ),
            focus(
                title: "The Lord is my light",
                kicker: "For anxiety and peace",
                detail: "Psalm 27 brings courage by fixing the heart on who God is before measuring the threat in front of you.",
                prompt: "What would courage look like if God's presence felt more real than your fear?",
                badge: "Personal",
                pathLabel: "Peace",
                reference: "Psalms 27"
            )
        ],
        "relationships and forgiveness": [
            focus(
                title: "Forgive from the heart",
                kicker: "For relationships and forgiveness",
                detail: "Matthew 18 turns forgiveness from theory into obedience rooted in the mercy you have received.",
                prompt: "Who do you still want to keep at a distance instead of forgiving before God?",
                badge: "Personal",
                pathLabel: "Forgiveness",
                reference: "Matthew 18"
            ),
            focus(
                title: "Put on grace in real relationships",
                kicker: "For relationships and forgiveness",
                detail: "Colossians 3 calls you to clothe yourself in patience, kindness, and forgiveness inside everyday tension.",
                prompt: "What relationship would look different if grace led the conversation first?",
                badge: "Personal",
                pathLabel: "Forgiveness",
                reference: "Colossians 3"
            ),
            focus(
                title: "Let bitterness go",
                kicker: "For relationships and forgiveness",
                detail: "Ephesians 4 exposes bitterness and points you back to the forgiving pattern of Christ.",
                prompt: "What wound are you still rehearsing instead of placing before Christ?",
                badge: "Personal",
                pathLabel: "Forgiveness",
                reference: "Ephesians 4"
            )
        ],
        "purpose and direction": [
            focus(
                title: "Trust God with the path",
                kicker: "For purpose and direction",
                detail: "Proverbs 3 grounds direction in surrender, trust, and refusing to lean on your own understanding.",
                prompt: "Where do you need trust to come before certainty today?",
                badge: "Personal",
                pathLabel: "Direction",
                reference: "Proverbs 3"
            ),
            focus(
                title: "Ask God for wisdom in the middle of pressure",
                kicker: "For purpose and direction",
                detail: "Psalm 25 slows you down and teaches you to ask God to show you the way you should walk.",
                prompt: "What decision needs wisdom more than speed right now?",
                badge: "Personal",
                pathLabel: "Direction",
                reference: "Psalms 25"
            ),
            focus(
                title: "Walk in what was prepared for you",
                kicker: "For purpose and direction",
                detail: "Ephesians 2 places your purpose inside grace and obedience, not self-made identity.",
                prompt: "What good work might God already be placing in front of you today?",
                badge: "Personal",
                pathLabel: "Direction",
                reference: "Ephesians 2"
            )
        ]
    ]

    private static let fallbackFocuses: [HomeStudyFocus] = [
        focus(
            title: "Begin by seeing Christ clearly",
            kicker: "For today's study",
            detail: "John 1 is a simple place to begin when you want to come back to who Jesus is and what it means to follow Him.",
            prompt: "What do you notice first about Jesus in this chapter?",
            badge: "Today",
            pathLabel: "Start",
            reference: "John 1"
        ),
        focus(
            title: "Stay planted",
            kicker: "For today's study",
            detail: "Psalm 1 contrasts drifting with rootedness and calls you back to steady delight in God's Word.",
            prompt: "What has been forming you more than Scripture this week?",
            badge: "Today",
            pathLabel: "Start",
            reference: "Psalms 1"
        ),
        focus(
            title: "Remain close to Christ",
            kicker: "For today's study",
            detail: "John 15 turns spiritual growth away from self-effort and back toward abiding in Jesus.",
            prompt: "Where do you need closeness with Christ more than a better plan?",
            badge: "Today",
            pathLabel: "Start",
            reference: "John 15"
        )
    ]

    private static func seasonalFocus(for date: Date) -> HomeStudyFocus? {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        if month == 12 && day >= 1 && day <= 26 {
            return focus(
                title: "God with us",
                kicker: "For this season",
                detail: "Let the Christmas season center you on the nearness of Christ instead of the noise around Him.",
                prompt: "How can you make room for Christ instead of only the season around Him?",
                badge: "Seasonal",
                pathLabel: "Christmas",
                reference: "Luke 2"
            )
        }

        if let easterSunday = easterSunday(in: calendar.component(.year, from: date)) {
            let holyWeekStart = calendar.date(byAdding: .day, value: -7, to: easterSunday) ?? easterSunday
            let normalized = calendar.startOfDay(for: date)

            if normalized >= holyWeekStart && normalized <= easterSunday {
                return focus(
                    title: "Resurrection hope",
                    kicker: "For Holy Week",
                    detail: "This week is not just about remembering events. It is about being re-centered on Christ's death and resurrection.",
                    prompt: "What needs to be surrendered again at the cross before you move on with this week?",
                    badge: "Seasonal",
                    pathLabel: "Holy Week",
                    reference: "Luke 24"
                )
            }
        }

        if month == 11 && isThanksgiving(date: date) {
            return focus(
                title: "Give thanks on purpose",
                kicker: "For Thanksgiving",
                detail: "Psalm 100 turns gratitude into worship and reminds you to enter God's presence with thanksgiving.",
                prompt: "What gift from God have you treated as ordinary lately?",
                badge: "Seasonal",
                pathLabel: "Thanksgiving",
                reference: "Psalms 100"
            )
        }

        return nil
    }

    private static func focus(
        title: String,
        kicker: String,
        detail: String,
        prompt: String,
        badge: String,
        pathLabel: String,
        reference: String
    ) -> HomeStudyFocus {
        let target = BibleDataProvider.resolveReference(from: reference)
            ?? BibleReferenceTarget(location: BibleLocation(book: "James", chapter: 1), verse: nil)

        return HomeStudyFocus(
            title: title,
            kicker: kicker,
            detail: detail,
            prompt: prompt,
            badge: badge,
            pathLabel: pathLabel,
            target: target
        )
    }

    private static func easterSunday(in year: Int) -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        let a = year % 19
        let b = year / 100
        let c = year % 100
        let d = b / 4
        let e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30
        let i = c / 4
        let k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7
        let m = (a + 11 * h + 22 * l) / 451
        let month = (h + l - 7 * m + 114) / 31
        let day = ((h + l - 7 * m + 114) % 31) + 1
        return calendar.date(from: DateComponents(year: year, month: month, day: day))
    }

    private static func isThanksgiving(date: Date) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .weekday, .weekdayOrdinal], from: date)
        return components.month == 11 && components.weekday == 5 && components.weekdayOrdinal == 4
    }
}

private struct LifeSituationGuideLibraryView: View {
    @ObservedObject var store: SoulJourneyStore

    private var featuredGuide: LifeSituationGuide {
        LifeSituationGuide.recommended(for: store.onboardingProfile)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                libraryHeroCard

                VStack(alignment: .leading, spacing: 14) {
                    Text("All guides")
                        .font(OVTheme.heading(22))
                        .foregroundStyle(OVTheme.ink)

                    Text("Each guide gives you chapters to read, a short explanation, reflection questions, a prayer, and one action step to carry into the day.")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.ink.opacity(0.72))

                    ForEach(LifeSituationGuide.all) { guide in
                        NavigationLink {
                            LifeSituationGuideDetailView(store: store, guide: guide)
                        } label: {
                            guideRow(guide, isFeatured: guide.id == featuredGuide.id)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(22)
                .background(OVTheme.elevatedCard)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(OVTheme.line, lineWidth: 1)
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle("Life guides")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var libraryHeroCard: some View {
        NavigationLink {
            LifeSituationGuideDetailView(store: store, guide: featuredGuide)
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(store.onboardingProfile.biggestChallenge.trimmed.isEmpty ? "Recommended start" : "Based on what you told us")
                            .font(OVTheme.body(11))
                            .foregroundStyle(OVTheme.gold)

                        Text(featuredGuide.title)
                            .font(OVTheme.display(30))
                            .foregroundStyle(OVTheme.midnight)

                        Text(featuredGuide.subtitle)
                            .font(OVTheme.body(15))
                            .foregroundStyle(OVTheme.ink.opacity(0.76))
                    }

                    Spacer(minLength: 12)

                    VStack(spacing: 8) {
                        guideStat(value: "\(featuredGuide.chapterPlans.count)", label: "chapters")
                        guideStat(value: "1", label: "prayer")
                    }
                }

                Text(featuredGuide.detail)
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.76))

                HStack(spacing: 8) {
                    guideChip("Reflection")
                    guideChip("Prayer")
                    guideChip("Action step")
                }

                HStack {
                    Text("Open guide")
                        .font(OVTheme.heading(15))
                        .foregroundStyle(.white)

                    Spacer()

                    Image(systemName: "arrow.right")
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .background(OVTheme.midnight)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .padding(22)
            .background(
                LinearGradient(
                    colors: [featuredGuide.accent.opacity(0.22), .white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(OVTheme.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func guideRow(_ guide: LifeSituationGuide, isFeatured: Bool) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(guide.accent.opacity(0.22))
                    .frame(width: 54, height: 54)

                Image(systemName: guide.symbol)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(OVTheme.midnight)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    if isFeatured {
                        Text("FOR YOU")
                            .font(OVTheme.body(10))
                            .foregroundStyle(OVTheme.gold)
                    }

                    Text("\(guide.chapterPlans.count) chapters")
                        .font(OVTheme.body(10))
                        .foregroundStyle(OVTheme.ink.opacity(0.55))
                }

                Text(guide.title)
                    .font(OVTheme.heading(20))
                    .foregroundStyle(OVTheme.midnight)

                Text(guide.subtitle)
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.74))

                HStack {
                    Text("Open guide")
                        .font(OVTheme.heading(14))
                        .foregroundStyle(OVTheme.midnight)

                    Spacer()

                    Text(guide.chapterPlans.first?.reference ?? "")
                        .font(OVTheme.body(12))
                        .foregroundStyle(OVTheme.ink.opacity(0.56))

                    Image(systemName: "arrow.right")
                        .foregroundStyle(OVTheme.midnight)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(.white.opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
    }

    private func guideChip(_ label: String) -> some View {
        Text(label)
            .font(OVTheme.body(12))
            .foregroundStyle(OVTheme.midnight)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.white.opacity(0.94))
            .clipShape(Capsule())
    }

    private func guideStat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(OVTheme.heading(18))
                .foregroundStyle(OVTheme.midnight)

            Text(label.uppercased())
                .font(OVTheme.body(10))
                .foregroundStyle(OVTheme.ink.opacity(0.55))
        }
        .frame(minWidth: 74)
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(.white.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct LifeSituationGuideDetailView: View {
    @ObservedObject var store: SoulJourneyStore
    let guide: LifeSituationGuide

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                headerCard
                chapterSection
                reflectionSection
                prayerSection
                actionSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle(guide.shortTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(guide.accent.opacity(0.24))
                        .frame(width: 58, height: 58)

                    Image(systemName: guide.symbol)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(OVTheme.midnight)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(guide.title)
                        .font(OVTheme.display(28))
                        .foregroundStyle(OVTheme.midnight)

                    Text(guide.subtitle)
                        .font(OVTheme.body(15))
                        .foregroundStyle(OVTheme.ink.opacity(0.76))
                }
            }

            Text(guide.detail)
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.78))

            HStack(spacing: 8) {
                detailMetaPill("\(guide.chapterPlans.count) chapters")
                detailMetaPill("Prayer")
                detailMetaPill("Action step")
            }
        }
        .padding(22)
        .background(
            LinearGradient(
                colors: [guide.accent.opacity(0.2), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
    }

    private var chapterSection: some View {
        guideSectionCard(title: "Recommended chapters", subtitle: "Start with one chapter, not all of them at once. Each card gives you a clearer angle for this exact season.") {
            VStack(spacing: 12) {
                ForEach(guide.chapterPlans) { plan in
                    NavigationLink {
                        BibleChapterReaderView(store: store, target: plan.target)
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(plan.reference)
                                        .font(OVTheme.heading(16))
                                        .foregroundStyle(OVTheme.midnight)

                                    Text(plan.title)
                                        .font(OVTheme.body(14))
                                        .foregroundStyle(OVTheme.ink.opacity(0.82))
                                }

                                Spacer()

                                Image(systemName: "arrow.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(OVTheme.midnight)
                            }

                            Text(plan.summary)
                                .font(OVTheme.body(14))
                                .foregroundStyle(OVTheme.ink.opacity(0.74))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Reflect")
                                    .font(OVTheme.body(11))
                                    .foregroundStyle(OVTheme.gold)

                                Text(plan.reflectionPrompt)
                                    .font(OVTheme.body(14))
                                    .foregroundStyle(OVTheme.ink)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(18)
                        .background(.white.opacity(0.96))
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(OVTheme.line, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var reflectionSection: some View {
        guideSectionCard(title: "Reflection questions", subtitle: "Slow down and let the chapter turn into honest self-examination before you move on.") {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(guide.reflectionQuestions.enumerated()), id: \.offset) { index, question in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(index + 1)")
                            .font(OVTheme.heading(14))
                            .foregroundStyle(OVTheme.gold)
                            .frame(width: 20, alignment: .leading)

                        Text(question)
                            .font(OVTheme.body(14))
                            .foregroundStyle(OVTheme.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }

    private var prayerSection: some View {
        guideSectionCard(title: "Prayer", subtitle: "Use this as a start, then keep it honest in your own words.") {
            Text(guide.prayer)
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.82))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .background(guide.accent.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(OVTheme.line, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private var actionSection: some View {
        guideSectionCard(title: "Action step", subtitle: "Keep the response small enough to obey today, but real enough to change something.") {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(OVTheme.midnight)

                Text(guide.actionStep)
                    .font(OVTheme.body(15))
                    .foregroundStyle(OVTheme.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(18)
            .background(.white.opacity(0.96))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(OVTheme.line, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private func guideSectionCard<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text(subtitle)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))

            content()
        }
        .padding(22)
        .background(OVTheme.elevatedCard)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
    }

    private func detailMetaPill(_ label: String) -> some View {
        Text(label)
            .font(OVTheme.body(12))
            .foregroundStyle(OVTheme.midnight)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.white.opacity(0.94))
            .clipShape(Capsule())
    }
}

struct LifeSituationGuide: Identifiable {
    let id: String
    let title: String
    let shortTitle: String
    let subtitle: String
    let detail: String
    let prayer: String
    let actionStep: String
    let symbol: String
    let accentHex: String
    let reflectionQuestions: [String]
    let chapterPlans: [LifeSituationChapterPlan]

    var accent: Color {
        Color(hex: accentHex)
    }

    static var totalChapterCount: Int {
        all.reduce(0) { $0 + $1.chapterPlans.count }
    }

    static func recommended(for profile: OnboardingAnswerSet) -> LifeSituationGuide {
        let challenge = profile.biggestChallenge.trimmed.lowercased()

        switch challenge {
        case "anxiety and peace":
            return guide(withID: "anxious")
        case "purpose and direction":
            return guide(withID: "purpose")
        case "relationships and forgiveness":
            return guide(withID: "forgiveness")
        case "staying consistent":
            return guide(withID: "discipline")
        case "controlling thoughts":
            return guide(withID: "falling-into-sin")
        case "hearing god clearly":
            return guide(withID: "far-from-god")
        default:
            return guide(withID: "anxious")
        }
    }

    private static func guide(withID id: String) -> LifeSituationGuide {
        all.first(where: { $0.id == id }) ?? all[0]
    }

    static let all: [LifeSituationGuide] = [
        LifeSituationGuide(
            id: "anxious",
            title: "When you feel anxious",
            shortTitle: "Anxious",
            subtitle: "Let Scripture move you from anxious striving into trust, prayer, and steadiness.",
            detail: "Anxiety often makes everything feel urgent at once. This guide slows you down and walks you through chapters that call your heart back to the Father's care, a guarded mind, and courage in God's presence.",
            prayer: "Father, my thoughts are loud and my heart is restless. Teach me to trust You more than my fears. Pull me away from anxious striving and anchor me in Your care, Your nearness, and Your peace. Give me the grace to bring every burden to You instead of carrying it alone. In Jesus' name, amen.",
            actionStep: "Write down the one burden pressing on you most, turn it into a short prayer, and come back to that prayer before the day ends.",
            symbol: "wind",
            accentHex: "DDEAF2",
            reflectionQuestions: [
                "What am I trying to control right now that belongs in God's hands?",
                "Which fear keeps replaying in my mind, and what truth from Scripture confronts it?",
                "What would trusting God actually look like before this day ends?"
            ],
            chapterPlans: [
                LifeSituationChapterPlan(
                    reference: "Matthew 6",
                    title: "Leave anxious striving behind",
                    summary: "Jesus addresses worry directly and brings your attention back to the Father's care, daily dependence, and the kingdom first.",
                    reflectionPrompt: "What am I seeking first right now: relief, control, or the kingdom of God?"
                ),
                LifeSituationChapterPlan(
                    reference: "Philippians 4",
                    title: "Pray instead of spiraling",
                    summary: "Paul links peace to prayer, gratitude, and disciplined thought, not to pretending pressure is not real.",
                    reflectionPrompt: "What do I need to turn into prayer before I keep rehearsing it in my head?"
                ),
                LifeSituationChapterPlan(
                    reference: "Psalms 27",
                    title: "Find courage in God's presence",
                    summary: "David faces fear by fixing his heart on who God is before measuring the threat in front of him.",
                    reflectionPrompt: "How would my next decision change if God's presence felt more real than the fear in front of me?"
                )
            ]
        ),
        LifeSituationGuide(
            id: "far-from-god",
            title: "When you feel far from God",
            shortTitle: "Far from God",
            subtitle: "Use these chapters when you feel numb, distant, or unsure whether your heart is still close to Him.",
            detail: "Feeling far from God does not always mean you have stopped caring. Sometimes it means your heart is dry, distracted, ashamed, or tired. These chapters bring you back to abiding, honest longing, repentance, and the Father's welcome.",
            prayer: "Lord Jesus, I do not want distance from You to become normal. Wake my heart back up. Where I have drifted, bring me back. Where I feel numb, make me tender again. Where shame has kept me back, remind me that You still call me near. In Jesus' name, amen.",
            actionStep: "Open one of these chapters before anything else tomorrow morning and stay in it for ten quiet minutes without rushing.",
            symbol: "water.waves",
            accentHex: "E7E1F0",
            reflectionQuestions: [
                "When did closeness with God start to feel weaker, and what was happening in me then?",
                "Is my distance coming more from distraction, shame, exhaustion, or quiet disobedience?",
                "What would returning to God honestly look like today?"
            ],
            chapterPlans: [
                LifeSituationChapterPlan(
                    reference: "John 15",
                    title: "Abide instead of drifting",
                    summary: "Jesus teaches that fruitfulness and spiritual life come from remaining close to Him, not from independent effort.",
                    reflectionPrompt: "Where have I tried to keep spiritual life going while living disconnected from Christ?"
                ),
                LifeSituationChapterPlan(
                    reference: "Psalms 42",
                    title: "Bring spiritual dryness into the light",
                    summary: "The psalmist names his thirst, grief, and longing honestly before God instead of hiding spiritual dryness.",
                    reflectionPrompt: "What am I actually thirsting for, and what has been replacing God in that space?"
                ),
                LifeSituationChapterPlan(
                    reference: "Luke 15",
                    title: "Return to the Father's welcome",
                    summary: "Jesus shows the heart of the Father toward the wandering, the ashamed, and the self-righteous alike.",
                    reflectionPrompt: "Do I believe God receives returning people with mercy, or do I still picture Him only with disappointment?"
                ),
                LifeSituationChapterPlan(
                    reference: "Isaiah 55",
                    title: "Come back while He is near",
                    summary: "Isaiah calls the thirsty to come, the wandering to return, and the heart to trust God's higher ways.",
                    reflectionPrompt: "What would it mean for me to stop delaying and seek the Lord while He is near?"
                )
            ]
        ),
        LifeSituationGuide(
            id: "falling-into-sin",
            title: "When you keep falling into sin",
            shortTitle: "Falling into sin",
            subtitle: "Take these chapters when temptation feels repetitive and you need truth deeper than guilt.",
            detail: "When sin keeps repeating, shame can either harden you or bring you to honesty. These chapters help you understand temptation, confession, freedom, and what it looks like to actually flee what keeps pulling you down.",
            prayer: "Father, I am tired of grieving You in the same places. Bring what is hidden into the light. Break my love for what is destroying me. Give me honesty, repentance, and real obedience instead of empty promises I keep breaking. Teach me to walk in the freedom Christ purchased. In Jesus' name, amen.",
            actionStep: "Name the trigger, place, or pattern most tied to this sin and remove one access point to it today.",
            symbol: "flame",
            accentHex: "F5D2C6",
            reflectionQuestions: [
                "What pattern keeps pulling me back, and what usually happens right before I give in?",
                "Am I managing guilt more than I am confronting the roots of temptation?",
                "What would repentance look like beyond regret this time?"
            ],
            chapterPlans: [
                LifeSituationChapterPlan(
                    reference: "James 1",
                    title: "Understand how temptation grows",
                    summary: "James exposes the inner movement from desire to sin to death and calls you to stop blaming outward things first.",
                    reflectionPrompt: "What desire keeps getting fed until it becomes action?"
                ),
                LifeSituationChapterPlan(
                    reference: "Romans 6",
                    title: "Remember whose you are now",
                    summary: "Paul teaches that union with Christ changes your relationship to sin and calls you to present yourself to God instead.",
                    reflectionPrompt: "What would it look like to treat this sin as something I do not belong to anymore?"
                ),
                LifeSituationChapterPlan(
                    reference: "1 John 1",
                    title: "Walk in the light",
                    summary: "John shows that confession is not weakness but the path back into truth, cleansing, and fellowship.",
                    reflectionPrompt: "What am I still hiding that needs to be confessed plainly before God?"
                ),
                LifeSituationChapterPlan(
                    reference: "2 Timothy 2",
                    title: "Do not just resist, flee",
                    summary: "Paul pairs fleeing youthful lusts with pursuing righteousness, faith, love, and peace with other believers.",
                    reflectionPrompt: "What do I keep trying to resist from too close instead of fully running from it?"
                )
            ]
        ),
        LifeSituationGuide(
            id: "purpose",
            title: "When you need purpose",
            shortTitle: "Purpose",
            subtitle: "Let these chapters move you from confusion into trust, calling, and clear next steps.",
            detail: "Purpose is often not missing because God forgot you. It is usually clouded by hurry, self-focus, or the pressure to see the whole future at once. These chapters help you trust God with the path and walk in what He has already prepared.",
            prayer: "God, I do not want to waste the life You gave me. Give me wisdom for the next step, not just a dream for the distant future. Align my plans with Your ways and teach me to live with obedience, patience, and purpose that honors Christ. In Jesus' name, amen.",
            actionStep: "Write one concrete next step you already know is right and do it before chasing a bigger answer.",
            symbol: "location.north.line",
            accentHex: "ECDDAB",
            reflectionQuestions: [
                "Am I waiting for a full life plan when God may only be asking for the next obedient step?",
                "What gifts, burdens, or opportunities has God already put in front of me?",
                "Where do I need trust more than certainty right now?"
            ],
            chapterPlans: [
                LifeSituationChapterPlan(
                    reference: "Proverbs 3",
                    title: "Trust God with the path",
                    summary: "Proverbs 3 anchors direction in surrender, humility, and refusing to lean on your own understanding.",
                    reflectionPrompt: "Where am I demanding clarity before I am willing to trust?"
                ),
                LifeSituationChapterPlan(
                    reference: "Ephesians 2",
                    title: "Walk in what was prepared for you",
                    summary: "Paul reminds you that grace saves you and also sends you into good works God already prepared.",
                    reflectionPrompt: "What good work might already be in front of me that I keep overlooking?"
                ),
                LifeSituationChapterPlan(
                    reference: "Romans 12",
                    title: "Discern God's will with a renewed mind",
                    summary: "Purpose becomes clearer as your mind is renewed and your life is offered to God rather than shaped by the world.",
                    reflectionPrompt: "What part of my thinking needs renewal before my direction becomes clearer?"
                )
            ]
        ),
        LifeSituationGuide(
            id: "forgiveness",
            title: "When you need forgiveness",
            shortTitle: "Forgiveness",
            subtitle: "Come here when bitterness, offense, guilt, or unresolved hurt has started shaping your heart.",
            detail: "Forgiveness is never small in Scripture. It is personal, costly, and rooted in the mercy you have already received in Christ. These chapters help you face both receiving grace and extending it to others.",
            prayer: "Father, search my heart. Show me where I still carry bitterness, resentment, or guilt. Teach me to forgive as I have been forgiven, and bring my heart into agreement with Your mercy. Heal what is wounded and soften what has become hard. In Jesus' name, amen.",
            actionStep: "Name one person or wound before God specifically today, then write one honest prayer of release over that person or situation.",
            symbol: "hands.clap",
            accentHex: "D9EBDD",
            reflectionQuestions: [
                "What hurt do I still revisit more than I release to God?",
                "Do I want justice, distance, restoration, or revenge most right now?",
                "How has God's mercy toward me changed the way I should face this wound?"
            ],
            chapterPlans: [
                LifeSituationChapterPlan(
                    reference: "Matthew 18",
                    title: "Forgive from the heart",
                    summary: "Jesus refuses shallow forgiveness and grounds mercy in remembering how much you have been forgiven.",
                    reflectionPrompt: "Where am I still keeping score instead of forgiving from the heart?"
                ),
                LifeSituationChapterPlan(
                    reference: "Ephesians 4",
                    title: "Put bitterness away",
                    summary: "Paul names bitterness, wrath, and clamor, then calls believers to kindness, tenderness, and forgiveness in Christ.",
                    reflectionPrompt: "What has bitterness been doing inside me while I keep telling myself I am just protecting my heart?"
                ),
                LifeSituationChapterPlan(
                    reference: "Colossians 3",
                    title: "Put on grace in real relationships",
                    summary: "Paul calls believers to clothe themselves in humility, patience, and forgiveness within everyday community life.",
                    reflectionPrompt: "What relationship would look different if grace led instead of self-protection?"
                )
            ]
        ),
        LifeSituationGuide(
            id: "alone",
            title: "When you feel alone",
            shortTitle: "Alone",
            subtitle: "Use these chapters when isolation, rejection, or inner heaviness is making you feel unseen.",
            detail: "Feeling alone can make everything feel smaller and darker than it is. Scripture does not treat loneliness lightly. These chapters remind you that God sees, sustains, and stays with His people, even when they feel forgotten or emotionally drained.",
            prayer: "God, I feel the weight of isolation and I do not want to harden underneath it. Thank You that You see me more fully than anyone else. Meet me in this place, steady my heart, and remind me that I am not abandoned. Give me courage to receive Your presence and not close myself off. In Jesus' name, amen.",
            actionStep: "Reach out to one safe person today instead of telling yourself you need to carry everything alone.",
            symbol: "person.crop.circle.badge.questionmark",
            accentHex: "DDEAF2",
            reflectionQuestions: [
                "What kind of loneliness am I feeling most right now: emotional, spiritual, relational, or all of it together?",
                "How do I usually respond when I feel unseen: do I withdraw, numb out, or pretend I am fine?",
                "What truth from these chapters tells me I am not abandoned?"
            ],
            chapterPlans: [
                LifeSituationChapterPlan(
                    reference: "Psalms 139",
                    title: "Be reminded that God sees you fully",
                    summary: "David meditates on the God who searches, knows, surrounds, and never loses sight of him.",
                    reflectionPrompt: "How would my loneliness shift if I really believed God sees me completely right now?"
                ),
                LifeSituationChapterPlan(
                    reference: "1 Kings 19",
                    title: "Let God meet you in exhaustion",
                    summary: "Elijah collapses under fear and isolation, and God meets him with care, truth, and renewed direction.",
                    reflectionPrompt: "Am I spiritually low because I am faithless, or because I am simply exhausted and need God to restore me?"
                ),
                LifeSituationChapterPlan(
                    reference: "John 14",
                    title: "Receive the comfort of Christ",
                    summary: "Jesus prepares His disciples for trouble by promising His presence, peace, and the Spirit's help.",
                    reflectionPrompt: "What part of me still lives as if Jesus left me alone?"
                )
            ]
        ),
        LifeSituationGuide(
            id: "angry",
            title: "When you are angry",
            shortTitle: "Angry",
            subtitle: "Open these chapters when frustration, offense, or irritation is rising faster than wisdom.",
            detail: "Anger can feel justified and still become destructive very quickly. These chapters expose the speed, pride, and words that often drive sinful anger, then point you toward slowness, gentleness, and self-control.",
            prayer: "Lord, do not let my anger take over my speech, my thoughts, or my judgment. Show me what is righteous and what is selfish in me. Slow me down, humble me, and teach me to respond in a way that honors You and protects others from my flesh. In Jesus' name, amen.",
            actionStep: "Before you answer the person or situation stirring you up, pause and pray for one full minute in silence.",
            symbol: "bolt.heart",
            accentHex: "F5D2C6",
            reflectionQuestions: [
                "What am I actually protecting or demanding when I get angry?",
                "How fast do my words move when my heart feels provoked?",
                "What would slowness, meekness, or self-control look like in this exact situation?"
            ],
            chapterPlans: [
                LifeSituationChapterPlan(
                    reference: "James 1",
                    title: "Be swift to hear and slow to wrath",
                    summary: "James ties spiritual maturity to receiving the Word with meekness and refusing the anger that does not produce God's righteousness.",
                    reflectionPrompt: "Where do I become quick to speak before I have become quick to hear?"
                ),
                LifeSituationChapterPlan(
                    reference: "Proverbs 15",
                    title: "Use words that turn away wrath",
                    summary: "Proverbs contrasts harsh speech with gentle answers and shows how the tongue can either inflame or heal.",
                    reflectionPrompt: "What kind of words am I about to use, and what kind of fruit will they likely produce?"
                ),
                LifeSituationChapterPlan(
                    reference: "Ephesians 4",
                    title: "Do not let anger become a foothold",
                    summary: "Paul acknowledges anger but warns against letting it harden into sin, bitterness, or access for the enemy.",
                    reflectionPrompt: "What anger have I let stay too long without bringing it under Christ?"
                )
            ]
        ),
        LifeSituationGuide(
            id: "discipline",
            title: "When you need discipline",
            shortTitle: "Discipline",
            subtitle: "Start here when you want steadiness, obedience, and habits that help you actually keep showing up.",
            detail: "Discipline is not about becoming impressive. It is about becoming available, teachable, and steady before God. These chapters help you see daily formation as rootedness, training, and long obedience rather than bursts of emotion.",
            prayer: "Father, form discipline in me without pride. Teach me to keep showing up when feelings are weak and distractions are strong. Make me steady in Scripture, prayer, and obedience so my life grows deeper roots and stronger fruit. In Jesus' name, amen.",
            actionStep: "Choose one small daily rhythm for the next seven days and protect it like an appointment with God.",
            symbol: "figure.run",
            accentHex: "ECDDAB",
            reflectionQuestions: [
                "What habit is shaping me right now, even if I never meant for it to?",
                "Do I want the fruit of discipline more than I want the structure it requires?",
                "What small rhythm could I actually sustain this week?"
            ],
            chapterPlans: [
                LifeSituationChapterPlan(
                    reference: "Psalms 1",
                    title: "Stay planted in the Word",
                    summary: "The blessed life is shaped by steady delight in God's law, not occasional inspiration.",
                    reflectionPrompt: "What am I rooted in day after day, and where is that root taking me?"
                ),
                LifeSituationChapterPlan(
                    reference: "Hebrews 12",
                    title: "Receive training without quitting",
                    summary: "Hebrews reframes hardship and correction as part of the Father's loving discipline that produces holiness.",
                    reflectionPrompt: "Where am I tempted to treat God's training like rejection instead of love?"
                ),
                LifeSituationChapterPlan(
                    reference: "1 Corinthians 9",
                    title: "Train with purpose",
                    summary: "Paul uses athletic language to describe a life brought under discipline for the sake of faithfulness.",
                    reflectionPrompt: "What part of my life most needs training instead of drifting?"
                )
            ]
        ),
        LifeSituationGuide(
            id: "happy",
            title: "When you feel happy",
            shortTitle: "Happy",
            subtitle: "Turn joy into praise, gratitude, and love that points back to God.",
            detail: "Happiness is a gift worth bringing back to God. These chapters help joy become worship instead of distraction, so gladness leads to praise, thanksgiving, generosity, and deeper love for Christ.",
            prayer: "Father, thank You for joy. Help me receive this good moment with gratitude and turn it back into praise. Let my happiness make me more worshipful, generous, and aware of Your goodness. In Jesus' name, amen.",
            actionStep: "Name one reason you are joyful, thank God for it directly, and share one encouragement with someone today.",
            symbol: "sun.max",
            accentHex: "ECDDAB",
            reflectionQuestions: [
                "What good gift from God am I enjoying right now?",
                "How can this joy become worship instead of self-focus?",
                "Who can I bless out of the overflow of this moment?"
            ],
            chapterPlans: [
                LifeSituationChapterPlan(
                    reference: "Psalms 100",
                    title: "Enter His presence with thanksgiving",
                    summary: "Psalm 100 turns gladness into worship by calling God's people to joyful praise, thanksgiving, and remembering His steadfast love.",
                    reflectionPrompt: "What would it look like to enter this happy moment with thanksgiving instead of just enjoying it silently?"
                ),
                LifeSituationChapterPlan(
                    reference: "James 1",
                    title: "See the gift and the Giver",
                    summary: "James reminds believers that every good and perfect gift comes from above, keeping gratitude rooted in God's character.",
                    reflectionPrompt: "What good gift can I name specifically without taking it for granted?"
                ),
                LifeSituationChapterPlan(
                    reference: "Philippians 4",
                    title: "Rejoice in the Lord",
                    summary: "Paul calls believers to rejoice in the Lord, practice gratitude, and let God's peace shape the heart.",
                    reflectionPrompt: "How can rejoicing in the Lord shape the way I carry this joy today?"
                )
            ]
        ),
        LifeSituationGuide(
            id: "hopeful",
            title: "When you feel hopeful",
            shortTitle: "Hopeful",
            subtitle: "Let hope become patient trust, prayer, and steady obedience.",
            detail: "Hope is strongest when it is anchored in God instead of circumstances. These chapters help you hold hope with humility, pray with expectation, and keep walking faithfully.",
            prayer: "God of hope, fill me with joy and peace as I trust You. Keep my hope rooted in Christ, not in control, and teach me to walk faithfully with what You have placed before me. In Jesus' name, amen.",
            actionStep: "Write what you are hoping for, surrender the timeline to God, and take one faithful step today.",
            symbol: "sparkles",
            accentHex: "D9EBDD",
            reflectionQuestions: [
                "What is my hope attached to right now?",
                "Where do I need patience while I wait?",
                "What faithful step can hope produce in me today?"
            ],
            chapterPlans: [
                LifeSituationChapterPlan(
                    reference: "Romans 15",
                    title: "Abound in hope",
                    summary: "Romans 15 names God as the source of hope and connects hope to trusting Him by the power of the Holy Spirit.",
                    reflectionPrompt: "Am I asking God to fill me with hope, or am I trying to manufacture it alone?"
                ),
                LifeSituationChapterPlan(
                    reference: "Lamentations 3",
                    title: "Hope in mercy that is new",
                    summary: "In the middle of grief, Lamentations remembers God's steadfast love, mercy, and faithfulness.",
                    reflectionPrompt: "What mercy from God can I remember while I wait?"
                ),
                LifeSituationChapterPlan(
                    reference: "Psalms 27",
                    title: "Wait for the Lord",
                    summary: "Psalm 27 ties courage to waiting on the Lord with a strengthened heart.",
                    reflectionPrompt: "Where does hope need to become courage and patience?"
                )
            ]
        ),
        LifeSituationGuide(
            id: "peaceful",
            title: "When you feel peaceful",
            shortTitle: "Peaceful",
            subtitle: "Receive peace as a gift from Christ and let it shape the rest of your day.",
            detail: "Peace should not make you forget God; it can become a quiet place to abide with Him. These chapters help you guard peace through gratitude, Scripture, and closeness with Christ.",
            prayer: "Jesus, thank You for peace. Help me receive it from You, guard it with truth, and carry it into how I speak, choose, and love today. In Your name, amen.",
            actionStep: "Stay with God for five quiet minutes and ask how this peace should shape your next conversation or decision.",
            symbol: "leaf",
            accentHex: "DDEAF2",
            reflectionQuestions: [
                "Where do I sense God's peace right now?",
                "What usually steals this peace from me?",
                "How can I carry peace into the next part of my day?"
            ],
            chapterPlans: [
                LifeSituationChapterPlan(
                    reference: "John 14",
                    title: "Receive Christ's peace",
                    summary: "Jesus gives peace that is different from the world's peace and tells troubled hearts not to be afraid.",
                    reflectionPrompt: "What makes Christ's peace different from temporary calm?"
                ),
                LifeSituationChapterPlan(
                    reference: "Colossians 3",
                    title: "Let peace rule",
                    summary: "Paul calls believers to let the peace of Christ rule in their hearts and to live with thankfulness.",
                    reflectionPrompt: "Where does Christ's peace need to rule my response today?"
                ),
                LifeSituationChapterPlan(
                    reference: "Psalms 23",
                    title: "Rest under the Shepherd's care",
                    summary: "Psalm 23 pictures the Lord as Shepherd who restores the soul and leads His people without fear.",
                    reflectionPrompt: "What would it look like to follow the Shepherd from peace, not pressure?"
                )
            ]
        )
    ]
}

struct LifeSituationChapterPlan: Identifiable {
    let reference: String
    let title: String
    let summary: String
    let reflectionPrompt: String

    var id: String { reference }

    var target: BibleReferenceTarget {
        BibleDataProvider.resolveReference(from: reference)
            ?? BibleReferenceTarget(location: BibleLocation(book: "Genesis", chapter: 1), verse: nil)
    }
}

private struct ReadingRecommendation: Identifiable, Hashable {
    let reference: String
    let title: String
    let reason: String
    let prompt: String
    let badge: String
    let accentHex: String

    var id: String { "\(reference)-\(title)" }

    var accent: Color {
        Color(hex: accentHex)
    }

    var target: BibleReferenceTarget {
        BibleDataProvider.resolveReference(from: reference)
            ?? BibleReferenceTarget(location: BibleLocation(book: "John", chapter: 1), verse: nil)
    }
}

private struct ReadingRecommendationPlan {
    let primary: ReadingRecommendation
    let alternates: [ReadingRecommendation]
    let reasons: [String]

    static func build(
        profile: OnboardingAnswerSet,
        lastReadLocation: BibleLocation?,
        reflectionStreak: Int,
        date: Date
    ) -> ReadingRecommendationPlan {
        let focus = HomeStudyFocus.pick(for: profile, date: date)
            ?? HomeStudyFocus(
                title: "Start by seeing Christ clearly",
                kicker: "For today's study",
                detail: "John 1 is a clean place to begin when you want to come back to who Jesus is and why He matters.",
                prompt: "What does this chapter show you about Jesus today?",
                badge: "Today",
                pathLabel: "Start",
                target: BibleReferenceTarget(location: BibleLocation(book: "John", chapter: 1), verse: nil)
            )

        let primary = recommendation(from: focus)
        var usedReferences = Set([primary.reference])
        var alternates: [ReadingRecommendation] = []

        func append(_ recommendation: ReadingRecommendation?) {
            guard let recommendation, usedReferences.insert(recommendation.reference).inserted else { return }
            alternates.append(recommendation)
        }

        append(continueRecommendation(for: lastReadLocation))
        append(challengeRecommendation(for: profile))
        append(stageRecommendation(for: profile))
        append(rhythmRecommendation(for: profile))

        var reasons: [String] = []

        if focus.badge == "Seasonal" {
            reasons.append("It fits the season you are in right now, so the chapter feels especially timely.")
        }

        if !profile.biggestChallenge.trimmed.isEmpty {
            reasons.append("It lines up with your main challenge: \(profile.biggestChallenge).")
        }

        if reflectionStreak > 0 {
            reasons.append("Your current reflection streak is \(reflectionStreak) day\(reflectionStreak == 1 ? "" : "s"), so this keeps the momentum moving.")
        } else {
            reasons.append("It is strong for getting back in without needing a long setup or a big plan first.")
        }

        reasons.append("It is simple to open, clear to follow, and strong for getting back into the Word without overthinking where to begin.")

        if lastReadLocation != nil {
            reasons.append("Your saved place is still available below, so you can either continue there or follow today's stronger fit.")
        }

        return ReadingRecommendationPlan(
            primary: primary,
            alternates: Array(alternates.prefix(3)),
            reasons: reasons
        )
    }

    private static func recommendation(from focus: HomeStudyFocus) -> ReadingRecommendation {
        ReadingRecommendation(
            reference: focus.chapterTitle,
            title: focus.title,
            reason: focus.detail,
            prompt: focus.prompt,
            badge: focus.badge,
            accentHex: accentHex(for: focus.pathLabel)
        )
    }

    private static func continueRecommendation(for location: BibleLocation?) -> ReadingRecommendation? {
        guard let location else { return nil }
        return ReadingRecommendation(
            reference: "\(location.book) \(location.chapter)",
            title: "Continue where you left off",
            reason: "Picking your place back up is often better for habit-building than constantly restarting.",
            prompt: "What did you notice last time that you should keep following instead of starting over?",
            badge: "Continue",
            accentHex: "DDEAF2"
        )
    }

    private static func challengeRecommendation(for profile: OnboardingAnswerSet) -> ReadingRecommendation? {
        let guide = LifeSituationGuide.recommended(for: profile)
        guard let firstPlan = guide.chapterPlans.first else { return nil }
        return ReadingRecommendation(
            reference: firstPlan.reference,
            title: firstPlan.title,
            reason: firstPlan.summary,
            prompt: firstPlan.reflectionPrompt,
            badge: "Personal",
            accentHex: guide.accentHex
        )
    }

    private static func stageRecommendation(for profile: OnboardingAnswerSet) -> ReadingRecommendation? {
        switch profile.faithStage.trimmed.lowercased() {
        case "lost / unsure":
            return ReadingRecommendation(
                reference: "John 1",
                title: "Meet Christ clearly",
                reason: "John opens by showing who Jesus is before asking you to master the rest of Scripture.",
                prompt: "What does this chapter reveal about who Jesus really is?",
                badge: "Faith stage",
                accentHex: "E7E1F0"
            )
        case "fully committed":
            return ReadingRecommendation(
                reference: "Romans 12",
                title: "Offer your life back to God",
                reason: "Romans 12 is strong when you want the Word to shape obedience, humility, and daily transformation.",
                prompt: "What would it look like to offer your real life to God instead of just your intentions?",
                badge: "Faith stage",
                accentHex: "D9EBDD"
            )
        case "trying to grow":
            fallthrough
        default:
            return ReadingRecommendation(
                reference: "John 15",
                title: "Stay connected to Christ",
                reason: "Growth becomes steadier when you read a chapter that centers abiding, not just trying harder.",
                prompt: "Where do you need closeness with Christ more than a better routine?",
                badge: "Faith stage",
                accentHex: "ECDDAB"
            )
        }
    }

    private static func rhythmRecommendation(for profile: OnboardingAnswerSet) -> ReadingRecommendation? {
        let scripture = profile.scriptureRhythm.trimmed.lowercased()
        let prayer = profile.prayerRhythm.trimmed.lowercased()

        if scripture == "never" {
            return ReadingRecommendation(
                reference: "Psalms 1",
                title: "Start with rootedness",
                reason: "Psalm 1 is short, direct, and perfect for rebuilding a daily Scripture habit from scratch.",
                prompt: "What has been shaping you more than God's Word lately?",
                badge: "Habit",
                accentHex: "ECDDAB"
            )
        }

        if prayer == "never" || prayer == "a few times a week" {
            return ReadingRecommendation(
                reference: "Matthew 6",
                title: "Let Jesus reset your prayer life",
                reason: "Matthew 6 gently pulls prayer out of performance and back into real dependence on the Father.",
                prompt: "What burden do you need to turn into prayer before the day gets louder?",
                badge: "Prayer",
                accentHex: "DDEAF2"
            )
        }

        if scripture == "most days" || scripture == "daily" {
            return ReadingRecommendation(
                reference: "Colossians 3",
                title: "Put the Word on your real life",
                reason: "Colossians 3 keeps mature rhythms from becoming abstract by pushing them into everyday character and relationships.",
                prompt: "What part of your life most needs to come under Christ today?",
                badge: "Depth",
                accentHex: "D9EBDD"
            )
        }

        return ReadingRecommendation(
            reference: "Proverbs 3",
            title: "Trust before certainty",
            reason: "Proverbs 3 is a strong middle-ground chapter when you need direction, surrender, and simple next-step wisdom.",
            prompt: "Where do you need trust to come before certainty today?",
            badge: "Habit",
            accentHex: "ECDDAB"
        )
    }

    private static func accentHex(for pathLabel: String) -> String {
        switch pathLabel.lowercased() {
        case "peace", "clarity":
            return "DDEAF2"
        case "forgiveness", "consistency":
            return "D9EBDD"
        case "mind":
            return "E7E1F0"
        default:
            return "ECDDAB"
        }
    }
}

private struct WhereShouldIReadTodayView: View {
    @ObservedObject var store: SoulJourneyStore
    let plan: ReadingRecommendationPlan

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                headerCard
                primaryActionCard
                reasoningCard
                alternatesCard
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle("Where to read")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(plan.primary.accent.opacity(0.24))
                        .frame(width: 58, height: 58)

                    Image(systemName: "books.vertical.fill")
                        .font(.system(size: 23, weight: .semibold))
                        .foregroundStyle(OVTheme.midnight)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Best fit for today")
                        .font(OVTheme.body(11))
                        .foregroundStyle(OVTheme.gold)

                    Text(plan.primary.reference)
                        .font(OVTheme.display(30))
                        .foregroundStyle(OVTheme.midnight)

                    Text(plan.primary.title)
                        .font(OVTheme.heading(20))
                        .foregroundStyle(OVTheme.ink)
                }
            }

            Text(plan.primary.reason)
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.78))

            Text(plan.primary.prompt)
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink)
                .padding(16)
                .background(.white.opacity(0.94))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(OVTheme.line, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .padding(22)
        .background(
            LinearGradient(
                colors: [plan.primary.accent.opacity(0.22), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
    }

    private var primaryActionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Open it now")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            NavigationLink {
                BibleChapterReaderView(store: store, target: plan.primary.target)
            } label: {
                actionRow(
                    title: "Read \(plan.primary.reference)",
                    subtitle: "Open the chapter in the full \(store.selectedBibleVersion.shortName) reader."
                )
            }
            .buttonStyle(.plain)
        }
        .padding(22)
        .background(OVTheme.elevatedCard)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
    }

    private var reasoningCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Why this is showing up")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            ForEach(plan.reasons, id: \.self) { reason in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(OVTheme.gold)

                    Text(reason)
                        .font(OVTheme.body(15))
                        .foregroundStyle(OVTheme.ink.opacity(0.82))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
                .background(.white.opacity(0.94))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(OVTheme.line, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
        .padding(22)
        .background(OVTheme.elevatedCard)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
    }

    private var alternatesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Also good today")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text("If you want a different angle, these are still strong choices for today.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))

            ForEach(plan.alternates) { recommendation in
                NavigationLink {
                    BibleChapterReaderView(store: store, target: recommendation.target)
                } label: {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(recommendation.reference)
                                    .font(OVTheme.heading(16))
                                    .foregroundStyle(OVTheme.midnight)

                                Text(recommendation.title)
                                    .font(OVTheme.body(14))
                                    .foregroundStyle(OVTheme.ink.opacity(0.82))
                            }

                            Spacer()

                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(OVTheme.midnight)
                        }

                        Text(recommendation.reason)
                            .font(OVTheme.body(14))
                            .foregroundStyle(OVTheme.ink.opacity(0.76))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(4)
                    }
                    .padding(18)
                    .background(recommendation.accent.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(OVTheme.line, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(22)
        .background(OVTheme.elevatedCard)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
    }

    private func actionRow(title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(OVTheme.heading(16))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(OVTheme.body(13))
                    .foregroundStyle(.white.opacity(0.82))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()

            Image(systemName: "arrow.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(OVTheme.midnight)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct ResetChallengeDayGuide: Identifiable, Hashable {
    let day: Int
    let title: String
    let reference: String
    let summary: String
    let prayer: String
    let reflectionPrompt: String
    let actionStep: String
    let accentHex: String

    var id: Int { day }

    var accent: Color {
        Color(hex: accentHex)
    }

    var target: BibleReferenceTarget {
        BibleDataProvider.resolveReference(from: reference)
            ?? BibleReferenceTarget(location: BibleLocation(book: "John", chapter: 1), verse: nil)
    }

    static let all: [ResetChallengeDayGuide] = [
        ResetChallengeDayGuide(
            day: 1,
            title: "Ask God for wisdom again",
            reference: "James 1",
            summary: "Start the reset with a chapter that calls you to endure pressure, ask God for wisdom, and do the Word instead of only hearing it.",
            prayer: "Father, I do not want this reset to be shallow. Give me wisdom, honesty, and the grace to obey what You show me today.",
            reflectionPrompt: "Where do I most need wisdom and obedience right now?",
            actionStep: "Write one area where your life feels unstable and ask God for wisdom there before the day ends.",
            accentHex: "ECDDAB"
        ),
        ResetChallengeDayGuide(
            day: 2,
            title: "Get re-rooted in the Word",
            reference: "Psalms 1",
            summary: "Psalm 1 resets your direction by showing the difference between a rooted life and a drifting one.",
            prayer: "Lord, plant me again in Your Word. I do not want to be shaped more by distraction than by truth.",
            reflectionPrompt: "What has been forming me more than Scripture lately?",
            actionStep: "Protect one quiet reading window tomorrow morning before anything else starts.",
            accentHex: "D9EBDD"
        ),
        ResetChallengeDayGuide(
            day: 3,
            title: "Trade anxiety for trust",
            reference: "Matthew 6",
            summary: "Jesus pulls your attention away from anxious striving and back to the Father's care and the kingdom first.",
            prayer: "Father, lift the weight of anxious striving off my chest and teach me to trust Your care more than my fear.",
            reflectionPrompt: "What burden am I still carrying as if it depends on me alone?",
            actionStep: "Turn your biggest worry into one sentence of prayer and revisit it tonight.",
            accentHex: "DDEAF2"
        ),
        ResetChallengeDayGuide(
            day: 4,
            title: "Stay connected to Christ",
            reference: "John 15",
            summary: "This chapter reminds you that real fruit comes from abiding in Jesus, not from pushing yourself harder alone.",
            prayer: "Jesus, keep me close. I do not want to build a routine without closeness to You.",
            reflectionPrompt: "Where have I been trying to produce fruit while disconnected from Christ?",
            actionStep: "Before opening any other app tomorrow, read one verse from this chapter again.",
            accentHex: "E7E1F0"
        ),
        ResetChallengeDayGuide(
            day: 5,
            title: "Let your mind be renewed",
            reference: "Romans 12",
            summary: "Romans 12 brings the reset into your thinking, your worship, and your real everyday life before God.",
            prayer: "God, renew my mind and pull my life back into alignment with what is holy, true, and pleasing to You.",
            reflectionPrompt: "What thought pattern most needs surrender and renewal right now?",
            actionStep: "Replace one recurring negative thought with one truth you wrote down from the chapter.",
            accentHex: "D9EBDD"
        ),
        ResetChallengeDayGuide(
            day: 6,
            title: "Return honestly",
            reference: "Psalms 51",
            summary: "David models repentance that is honest, broken, and hopeful in God's mercy instead of trapped in shame.",
            prayer: "Father, search me and cleanse me. I do not want to hide from You where I most need Your mercy.",
            reflectionPrompt: "What do I need to bring into the light instead of managing quietly?",
            actionStep: "Confess one specific sin or pattern to God plainly instead of speaking around it.",
            accentHex: "F5D2C6"
        ),
        ResetChallengeDayGuide(
            day: 7,
            title: "Put on the new life",
            reference: "Colossians 3",
            summary: "Finish the reset by asking what it looks like to actually wear the new life Christ has already given you.",
            prayer: "Lord, let this reset lead to changed habits and a changed heart, not just one strong week.",
            reflectionPrompt: "What part of the new life do I most need to put on this coming week?",
            actionStep: "Choose one trait from Colossians 3 to practice intentionally over the next seven days.",
            accentHex: "ECDDAB"
        )
    ]
}

struct ResetWithGodView: View {
    @ObservedObject var store: SoulJourneyStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                headerCard

                ForEach(ResetChallengeDayGuide.all) { day in
                    dayCard(day)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle("7 Day Reset")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("7 Day Reset With God")
                        .font(OVTheme.display(30))
                        .foregroundStyle(OVTheme.midnight)

                    Text("A guided challenge for coming back to Scripture, prayer, and honest obedience without overcomplicating the next week.")
                        .font(OVTheme.body(15))
                        .foregroundStyle(OVTheme.ink.opacity(0.78))
                }

                Spacer(minLength: 12)

                VStack(spacing: 8) {
                    resetStat(value: "\(store.resetChallengeCompletedCount)", label: "done")
                    resetStat(
                        value: store.hasCompletedResetChallenge ? "done" : "day \(store.nextResetChallengeDayNumber ?? 7)",
                        label: "next"
                    )
                }
            }

            HStack(spacing: 8) {
                ForEach(1...7, id: \.self) { day in
                    Capsule()
                        .fill(store.isResetChallengeDayCompleted(day) ? OVTheme.gold : OVTheme.smoke)
                        .frame(maxWidth: .infinity, minHeight: 10)
                        .overlay(
                            Capsule()
                                .stroke(OVTheme.line, lineWidth: 1)
                        )
                }
            }

            HStack(spacing: 10) {
                resetMetaPill(store.hasCompletedResetChallenge ? "Reset complete" : "Guided 7-day path")
                resetMetaPill("Prayer")
                resetMetaPill("Action step")
            }

            if store.hasStartedResetChallenge {
                Button("Start over") {
                    store.restartResetChallenge()
                }
                .font(OVTheme.heading(14))
                .foregroundStyle(OVTheme.midnight)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.white.opacity(0.94))
                .overlay(
                    Capsule()
                        .stroke(OVTheme.line, lineWidth: 1)
                )
                .clipShape(Capsule())
            }
        }
        .padding(22)
        .background(
            LinearGradient(
                colors: [OVTheme.lemon.opacity(0.22), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
    }

    private func dayCard(_ day: ResetChallengeDayGuide) -> some View {
        let isCompleted = store.isResetChallengeDayCompleted(day.day)

        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Day \(day.day)")
                        .font(OVTheme.body(11))
                        .foregroundStyle(OVTheme.gold)

                    Text(day.reference)
                        .font(OVTheme.heading(20))
                        .foregroundStyle(OVTheme.midnight)

                    Text(day.title)
                        .font(OVTheme.body(15))
                        .foregroundStyle(OVTheme.ink)
                }

                Spacer()

                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(isCompleted ? OVTheme.midnight : OVTheme.line)
            }

            Text(day.summary)
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.78))
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 10) {
                resetDetailBlock(title: "Prayer", body: day.prayer, accent: day.accent)
                resetDetailBlock(title: "Reflect", body: day.reflectionPrompt, accent: day.accent)
                resetDetailBlock(title: "Action", body: day.actionStep, accent: day.accent)
            }

            HStack(spacing: 10) {
                NavigationLink {
                    BibleChapterReaderView(store: store, target: day.target)
                } label: {
                    resetActionButton(
                        title: "Open chapter",
                        subtitle: "Read the full chapter",
                        fill: OVTheme.midnight,
                        foreground: .white,
                        outlined: false
                    )
                }
                .buttonStyle(.plain)
            }

            Button {
                store.toggleResetChallengeDay(day.day)
            } label: {
                HStack {
                    Text(isCompleted ? "Completed" : "Mark day complete")
                        .font(OVTheme.heading(14))
                        .foregroundStyle(OVTheme.midnight)

                    Spacer()

                    Image(systemName: isCompleted ? "checkmark" : "arrow.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(OVTheme.midnight)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(day.accent.opacity(0.16))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(OVTheme.line, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(22)
        .background(OVTheme.elevatedCard)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
    }

    private func resetDetailBlock(title: String, body: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(OVTheme.body(11))
                .foregroundStyle(OVTheme.gold)

            Text(body)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.82))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(accent.opacity(0.12))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func resetActionButton(
        title: String,
        subtitle: String,
        fill: Color,
        foreground: Color,
        outlined: Bool
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(OVTheme.heading(14))

                Text(subtitle)
                    .font(OVTheme.body(12))
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "arrow.right")
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(fill)
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(outlined ? OVTheme.line : .clear, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func resetStat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(OVTheme.heading(16))
                .foregroundStyle(OVTheme.midnight)

            Text(label.uppercased())
                .font(OVTheme.body(10))
                .foregroundStyle(OVTheme.ink.opacity(0.55))
        }
        .frame(minWidth: 78)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.white.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func resetMetaPill(_ label: String) -> some View {
        Text(label)
            .font(OVTheme.body(12))
            .foregroundStyle(OVTheme.midnight)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.white.opacity(0.94))
            .clipShape(Capsule())
    }

}

private struct FeelingShortcut: Identifiable {
    let id: String
    let label: String
    let guideID: String
    let accentHex: String
    let verseReferences: [String]
    let intro: String

    var accent: Color {
        Color(hex: accentHex)
    }

    var guide: LifeSituationGuide {
        LifeSituationGuide.all.first(where: { $0.id == guideID }) ?? LifeSituationGuide.all[0]
    }

    static let all: [FeelingShortcut] = [
        FeelingShortcut(
            id: "anxious",
            label: "anxious",
            guideID: "anxious",
            accentHex: "DDEAF2",
            verseReferences: ["Philippians 4:6", "Matthew 6:33", "Psalm 27:1"],
            intro: "When your mind feels loud, do not start with more scrolling. Start with truth that steadies the heart."
        ),
        FeelingShortcut(
            id: "tempted",
            label: "tempted",
            guideID: "falling-into-sin",
            accentHex: "F5D2C6",
            verseReferences: ["James 1:14", "Romans 6:12", "1 John 1:9"],
            intro: "Temptation grows fast in the dark. Bring it into the light quickly and let Scripture interrupt the pattern."
        ),
        FeelingShortcut(
            id: "lonely",
            label: "lonely",
            guideID: "alone",
            accentHex: "DDEAF2",
            verseReferences: ["Psalm 139:1", "John 14:18", "James 5:16"],
            intro: "Loneliness can make you feel invisible. These passages pull you back toward God's presence and honest connection."
        ),
        FeelingShortcut(
            id: "confused",
            label: "confused",
            guideID: "purpose",
            accentHex: "ECDDAB",
            verseReferences: ["Proverbs 3:5", "James 1:5", "Romans 12:2"],
            intro: "Confusion usually makes you want the whole answer now. Scripture often starts by giving you wisdom for the next faithful step."
        ),
        FeelingShortcut(
            id: "tired",
            label: "tired",
            guideID: "far-from-god",
            accentHex: "E7E1F0",
            verseReferences: ["Psalm 42:1", "John 15:4", "Isaiah 55:3"],
            intro: "When your soul feels tired, do not assume God is absent. Slow down, return, and let the Word re-root you."
        ),
        FeelingShortcut(
            id: "unmotivated",
            label: "unmotivated",
            guideID: "discipline",
            accentHex: "D9EBDD",
            verseReferences: ["Proverbs 6:6", "Psalm 1:2", "1 Corinthians 9:27"],
            intro: "When motivation is weak, structure matters more than waiting for a better mood. Let Scripture move you back into steady action."
        ),
        FeelingShortcut(
            id: "angry",
            label: "angry",
            guideID: "angry",
            accentHex: "F5D2C6",
            verseReferences: ["James 1:19", "Proverbs 15:1", "Ephesians 4:26"],
            intro: "Anger needs truth before it gets words. Slow down, pray first, and let Scripture shape the response."
        ),
        FeelingShortcut(
            id: "ashamed",
            label: "ashamed",
            guideID: "falling-into-sin",
            accentHex: "E7E1F0",
            verseReferences: ["1 John 1:9", "Romans 8:1", "Luke 15:20"],
            intro: "Shame wants you to hide. Bring it into the light and return to the mercy of God without delay."
        ),
        FeelingShortcut(
            id: "discouraged",
            label: "discouraged",
            guideID: "far-from-god",
            accentHex: "DDEAF2",
            verseReferences: ["Galatians 6:9", "Isaiah 40:31", "Psalm 42:11"],
            intro: "Discouragement can make quitting feel reasonable. Start with truth that reminds your heart to hope in God again."
        ),
        FeelingShortcut(
            id: "happy",
            label: "happy",
            guideID: "happy",
            accentHex: "ECDDAB",
            verseReferences: ["Psalm 100:2", "James 1:17", "Philippians 4:4"],
            intro: "Joy is a gift to bring back to God. Let happiness become praise, gratitude, and love that overflows."
        ),
        FeelingShortcut(
            id: "grateful",
            label: "grateful",
            guideID: "happy",
            accentHex: "D9EBDD",
            verseReferences: ["Psalm 100:4", "1 Thessalonians 5:18", "Colossians 3:17"],
            intro: "Gratitude gets stronger when it becomes worship. Name the gift, thank the Giver, and carry it into action."
        ),
        FeelingShortcut(
            id: "peaceful",
            label: "peaceful",
            guideID: "peaceful",
            accentHex: "DDEAF2",
            verseReferences: ["John 14:27", "Colossians 3:15", "Psalm 23:2"],
            intro: "Peace is not only relief. It is a place to stay close to Christ and let His presence shape what comes next."
        ),
        FeelingShortcut(
            id: "hopeful",
            label: "hopeful",
            guideID: "hopeful",
            accentHex: "D9EBDD",
            verseReferences: ["Romans 15:13", "Lamentations 3:24", "Psalm 27:14"],
            intro: "Hope is meant to become trust. Bring expectation to God and let it produce patience and faithful action."
        ),
        FeelingShortcut(
            id: "excited",
            label: "excited",
            guideID: "happy",
            accentHex: "ECDDAB",
            verseReferences: ["Psalm 103:1", "James 1:17", "Romans 12:11"],
            intro: "Excitement can become worship instead of hurry. Thank God, ask for wisdom, and move with joy."
        )
    ]
}

private struct FeelingResponseView: View {
    @ObservedObject var store: SoulJourneyStore
    let shortcut: FeelingShortcut

    private var guide: LifeSituationGuide {
        shortcut.guide
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                headerCard
                versesSection
                guideSection
                prayerSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle("I feel \(shortcut.label)")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(shortcut.accent.opacity(0.22))
                        .frame(width: 56, height: 56)

                    Image(systemName: "sparkles.rectangle.stack")
                        .font(.system(size: 23, weight: .semibold))
                        .foregroundStyle(OVTheme.midnight)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Start here when you feel \(shortcut.label)")
                        .font(OVTheme.display(28))
                        .foregroundStyle(OVTheme.midnight)

                    Text(shortcut.intro)
                        .font(OVTheme.body(15))
                        .foregroundStyle(OVTheme.ink.opacity(0.76))
                }
            }

            HStack(spacing: 8) {
                quickHelpChip("\(shortcut.verseReferences.count) verses")
                quickHelpChip("Guide")
                quickHelpChip("Prayer")
            }
        }
        .padding(22)
        .background(
            LinearGradient(
                colors: [shortcut.accent.opacity(0.22), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
    }

    private var versesSection: some View {
        quickSectionCard(
            title: "Verses for right now",
            subtitle: "Open one of these first if you need truth fast before you do anything else."
        ) {
            VStack(spacing: 12) {
                ForEach(shortcut.verseReferences, id: \.self) { reference in
                    if let verse = QuickHelpVerse(reference: reference) {
                        NavigationLink {
                            BibleChapterReaderView(store: store, target: verse.target)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(verse.reference)
                                        .font(OVTheme.heading(15))
                                        .foregroundStyle(OVTheme.midnight)

                                    Spacer()

                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(OVTheme.midnight)
                                }

                                Text(verse.text)
                                    .font(OVTheme.body(14))
                                    .foregroundStyle(OVTheme.ink.opacity(0.8))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(4)
                            }
                            .padding(16)
                            .background(.white.opacity(0.96))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(OVTheme.line, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var guideSection: some View {
        quickSectionCard(
            title: "Go deeper",
            subtitle: "If you need more than a few verses, open the full guide for Scripture, prayer, and a clear next step."
        ) {
            VStack(spacing: 12) {
                NavigationLink {
                    LifeSituationGuideDetailView(store: store, guide: guide)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Open full guide")
                                .font(OVTheme.heading(15))
                                .foregroundStyle(OVTheme.midnight)

                            Text(guide.title)
                                .font(OVTheme.body(13))
                                .foregroundStyle(OVTheme.ink.opacity(0.72))
                        }

                        Spacer()

                        Image(systemName: "arrow.right")
                            .foregroundStyle(OVTheme.midnight)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(shortcut.accent.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(OVTheme.line, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var prayerSection: some View {
        quickSectionCard(
            title: "Prayer",
            subtitle: "Use this as your first honest prayer, then keep going in your own words."
        ) {
            Text(guide.prayer)
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.82))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .background(shortcut.accent.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(OVTheme.line, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private func quickSectionCard<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text(subtitle)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))

            content()
        }
        .padding(22)
        .background(OVTheme.elevatedCard)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
    }

    private func quickHelpChip(_ label: String) -> some View {
        Text(label)
            .font(OVTheme.body(12))
            .foregroundStyle(OVTheme.midnight)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.white.opacity(0.94))
            .clipShape(Capsule())
    }

}

private struct QuickHelpVerse {
    let reference: String
    let text: String
    let target: BibleReferenceTarget

    init?(reference: String) {
        guard let target = BibleDataProvider.resolveReference(from: reference),
              let chapter = BibleDataProvider.chapter(at: target.location),
              let verseNumber = target.verse,
              let verse = chapter.verses.first(where: { $0.verse == verseNumber }) else {
            return nil
        }

        self.reference = reference
        self.text = verse.text
        self.target = target
    }
}

private extension View {
    func ovSurfaceCard(
        cornerRadius: CGFloat = 20,
        fill: Color = OVTheme.cardBackground,
        shadowOpacity: Double = 0.05
    ) -> some View {
        premiumSurfaceCard(
            cornerRadius: cornerRadius,
            fill: fill,
            shadowOpacity: shadowOpacity
        )
    }
}

private struct BibleNotesFloatingButton: View {
    let noteCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "note.text")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(18)
                    .background(OVTheme.midnight)
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.85), lineWidth: 2)
                    )
                    .clipShape(Circle())

                if noteCount > 0 {
                    Text("\(min(noteCount, 99))")
                        .font(OVTheme.body(10))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(OVTheme.coral)
                        .clipShape(Capsule())
                        .offset(x: 6, y: -4)
                }
            }
        }
        .buttonStyle(.plain)
        .shadow(color: .black.opacity(0.16), radius: 16, y: 8)
    }
}

private struct BibleVerseNotesSheet: View {
    @ObservedObject var store: SoulJourneyStore
    @Environment(\.dismiss) private var dismiss
    @State private var editingNote: BibleVerseNote?
    @State private var editDraft = ""
    @State private var pendingDeleteNote: BibleVerseNote?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Notes keep their original Bible version. If you switch versions, they remain visible with a label.")
                        .font(OVTheme.body(12))
                        .foregroundStyle(OVTheme.muted)

                    if store.sortedBibleVerseNotes.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("No Bible notes yet")
                                .font(OVTheme.heading(22))
                                .foregroundStyle(OVTheme.ink)

                            Text("Long press verses in the Bible, select what stands out, and save notes here.")
                                .font(OVTheme.body(14))
                                .foregroundStyle(OVTheme.muted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .ovSurfaceCard(cornerRadius: 22)
                    } else {
                        ForEach(store.sortedBibleVerseNotes) { note in
                            noteCard(note)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("Bible notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(OVTheme.body(15))
                }
            }
            .sheet(item: $editingNote) { note in
                BibleVerseNoteComposerSheet(
                    references: note.references,
                    noteText: $editDraft,
                    navigationTitle: "Edit note",
                    saveButtonTitle: "Update"
                ) {
                    if store.updateBibleVerseNote(id: note.id, text: editDraft) {
                        editDraft = ""
                        editingNote = nil
                    }
                }
            }
            .confirmationDialog(
                "Delete this note?",
                isPresented: Binding(
                    get: { pendingDeleteNote != nil },
                    set: { if !$0 { pendingDeleteNote = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete note", role: .destructive) {
                    guard let pendingDeleteNote else { return }
                    store.removeBibleVerseNote(id: pendingDeleteNote.id)
                    self.pendingDeleteNote = nil
                }

                Button("Cancel", role: .cancel) {
                    pendingDeleteNote = nil
                }
            } message: {
                Text("This will permanently remove the saved note.")
            }
        }
    }

    private func noteCard(_ note: BibleVerseNote) -> some View {
        let target = note.firstReference.flatMap { BibleDataProvider.resolveReference(from: $0) }

        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.title)
                        .font(OVTheme.heading(15))
                        .foregroundStyle(OVTheme.midnight)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(note.version.shortName)
                        .font(OVTheme.body(11))
                        .foregroundStyle(OVTheme.midnight)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(OVTheme.smoke)
                        .clipShape(Capsule())

                    Text(shortDate(note.updatedAt))
                        .font(OVTheme.body(11))
                        .foregroundStyle(OVTheme.muted)
                }

                Spacer(minLength: 10)

                Menu {
                    Button {
                        editDraft = note.text
                        editingNote = note
                    } label: {
                        Label("Edit note", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        pendingDeleteNote = note
                    } label: {
                        Label("Delete note", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(OVTheme.midnight)
                        .padding(6)
                }
            }

            Text(note.previewText)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.76))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(5)

            HStack(spacing: 10) {
                if let target {
                    NavigationLink {
                        BibleChapterReaderView(store: store, target: target)
                    } label: {
                        HStack(spacing: 6) {
                            Text("Open verse")
                                .font(OVTheme.heading(13))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundStyle(OVTheme.midnight)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(OVTheme.sand)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Button {
                    editDraft = note.text
                    editingNote = note
                } label: {
                    Text("Edit")
                        .font(OVTheme.body(12))
                        .foregroundStyle(OVTheme.midnight)
                }
                .buttonStyle(.plain)

                Button(role: .destructive) {
                    pendingDeleteNote = note
                } label: {
                    Text("Delete")
                        .font(OVTheme.body(12))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .ovSurfaceCard(cornerRadius: 20)
    }

    private func shortDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
}

private struct BibleVerseNoteComposerSheet: View {
    let references: [String]
    @Binding var noteText: String
    let navigationTitle: String
    let saveButtonTitle: String
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isEditorFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Text("Selected verses")
                    .font(OVTheme.heading(18))
                    .foregroundStyle(OVTheme.ink)

                Text(references.joined(separator: ", "))
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.72))
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(OVTheme.smoke)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(OVTheme.line, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Text("What did you learn?")
                    .font(OVTheme.heading(18))
                    .foregroundStyle(OVTheme.ink)

                ZStack(alignment: .topLeading) {
                    TextEditor(text: $noteText)
                        .font(OVTheme.body(16))
                        .frame(minHeight: 180)
                        .padding(10)
                        .background(OVTheme.elevatedCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(OVTheme.line, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .focused($isEditorFocused)

                    if noteText.trimmed.isEmpty {
                        Text("Write what stood out, what you learned, and how you want to live it out.")
                            .font(OVTheme.body(16))
                            .foregroundStyle(OVTheme.muted)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 22)
                            .allowsHitTesting(false)
                    }
                }

                Spacer()
            }
            .padding(20)
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isEditorFocused = true
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(OVTheme.body(15))
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(saveButtonTitle) {
                        onSave()
                    }
                    .font(OVTheme.heading(15))
                    .disabled(noteText.trimmed.isEmpty)
                }
            }
        }
    }
}

private struct DailyVerseShareGraphic: View {
    let dailyVerse: DailyBibleVerse

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [OVTheme.lemon.opacity(0.38), .white, OVTheme.mist.opacity(0.68)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("Daily verse")
                        .font(OVTheme.heading(16))
                        .foregroundStyle(OVTheme.midnight)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.9))
                        .clipShape(Capsule())

                    Spacer()

                    Text(dailyVerse.version.shortName)
                        .font(OVTheme.heading(14))
                        .foregroundStyle(OVTheme.midnight.opacity(0.82))
                }

                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 16) {
                    Text(dailyVerse.referenceText)
                        .font(OVTheme.display(34))
                        .foregroundStyle(OVTheme.midnight)

                    Text(dailyVerse.verse.text)
                        .font(OVTheme.body(24))
                        .foregroundStyle(OVTheme.ink.opacity(0.88))
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                HStack(alignment: .bottom) {
                    Text(Date.now.formatted(date: .abbreviated, time: .omitted))
                        .font(OVTheme.body(13))
                        .foregroundStyle(OVTheme.muted)

                    Spacer()

                    Text("@one.visioon")
                        .font(OVTheme.heading(13))
                        .foregroundStyle(OVTheme.midnight.opacity(0.54))
                }
            }
            .padding(28)
        }
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
    }
}

private struct ActivityShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private struct DailyVerseSharePayload: Identifiable {
    let id = UUID()
    let shareText: String
    let fileURL: URL?

    var activityItems: [Any] {
        if let fileURL {
            return [fileURL, shareText]
        }
        return [shareText]
    }
}

struct BibleAppView_Previews: PreviewProvider {
    static var previews: some View {
        ScriptureHomeView(
            store: SoulJourneyStore(),
            openGlorifyGifts: {},
            openProfile: {}
        )
    }
}
