import SwiftUI
import PhotosUI
import UIKit

enum GlorifyRoute: Hashable {
    case discoverGifts
}

private struct GlorifyWay: Identifiable {
    let title: String
    let detail: String
    let practice: String
    let reference: String
    let symbol: String
    let accent: Color

    var id: String { title }
}

private struct GlorifyPrompt: Identifiable {
    let title: String
    let detail: String
    let reference: String

    var id: String { title }
}

private struct GiftLane: Identifiable {
    let title: String
    let detail: String
    let application: String
    let reference: String
    let symbol: String
    let accent: Color

    var id: String { title }
}

private struct WeeklyCreativeDay: Identifiable {
    let id = UUID()
    let date: Date
    let checkIn: CreativeCheckIn
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

    private let ways: [GlorifyWay] = [
        GlorifyWay(
            title: "Worship through what you make",
            detail: "Your creativity does not have to be separate from your faith. It can become worship when it is offered back to God.",
            practice: "Before you create, pray over the work and give the result to Jesus.",
            reference: "Colossians 3:17",
            symbol: "hands.sparkles",
            accent: OVTheme.lemon.opacity(0.46)
        ),
        GlorifyWay(
            title: "Reflect truth beautifully",
            detail: "The world does not only need louder content. It needs truth carried with beauty, clarity, peace, and conviction.",
            practice: "Create one piece that makes Christ more visible than yourself.",
            reference: "Matthew 5:16",
            symbol: "sparkles",
            accent: OVTheme.sky.opacity(0.62)
        ),
        GlorifyWay(
            title: "Use your gifts with discipline",
            detail: "God-given creativity grows when it is practiced faithfully instead of waiting on perfect moods or perfect timing.",
            practice: "Finish one small thing today, even if it is unfinished in your eyes.",
            reference: "Ecclesiastes 9:10",
            symbol: "paintbrush.pointed",
            accent: OVTheme.mint.opacity(0.72)
        ),
        GlorifyWay(
            title: "Share light with people",
            detail: "What you write, sing, design, film, or paint can comfort, convict, encourage, and point people back to Jesus.",
            practice: "Share one truth-filled creation or encouragement with someone today.",
            reference: "1 Peter 4:10",
            symbol: "sun.max",
            accent: OVTheme.orchid.opacity(0.66)
        )
    ]

    private let prompts: [GlorifyPrompt] = [
        GlorifyPrompt(
            title: "Write one honest line of worship",
            detail: "Do not chase a full song first. Start with one line that is true about God.",
            reference: "Psalms 96:1"
        ),
        GlorifyPrompt(
            title: "Make something small but real",
            detail: "A rough draft made in faith is better than another day of not starting.",
            reference: "Zechariah 4:10"
        ),
        GlorifyPrompt(
            title: "Turn a verse into a visual",
            detail: "Sketch, design, film, or style something that helps Scripture stay visible.",
            reference: "Habakkuk 2:2"
        ),
        GlorifyPrompt(
            title: "Encourage one person creatively",
            detail: "Send something thoughtful that carries peace, hope, or biblical truth.",
            reference: "Hebrews 10:24"
        )
    ]

    private let giftLanes: [GiftLane] = [
        GiftLane(
            title: "Creative skill",
            detail: "God can fill people with skill, wisdom, and craftsmanship for work that reflects His beauty and order.",
            application: "Build, design, write, compose, or shape something with excellence and humility.",
            reference: "Exodus 31:3-5",
            symbol: "paintpalette",
            accent: OVTheme.lemon.opacity(0.48)
        ),
        GiftLane(
            title: "Encouragement and mercy",
            detail: "Some gifts strengthen tired people, restore hope, and make God's kindness feel visible.",
            application: "Use your words and presence to steady someone instead of only impressing them.",
            reference: "Romans 12:8",
            symbol: "heart.text.square",
            accent: OVTheme.orchid.opacity(0.68)
        ),
        GiftLane(
            title: "Service and faithfulness",
            detail: "Not every gift is loud. Many are seen in steady service, care, and hidden faithfulness.",
            application: "Turn your reliability into ministry instead of treating it like a small thing.",
            reference: "1 Peter 4:10",
            symbol: "hands.sparkles",
            accent: OVTheme.mint.opacity(0.72)
        ),
        GiftLane(
            title: "Teaching and clarity",
            detail: "Some gifts help people understand truth, connect Scripture, and walk away with clearer conviction.",
            application: "Explain God's Word clearly, patiently, and in a way that leads people toward obedience.",
            reference: "Romans 12:6-7",
            symbol: "book.pages",
            accent: OVTheme.sky.opacity(0.6)
        )
    ]

    private var isBibleSchoolCreatorSpaceUnlocked: Bool {
        store.onboardingProfile.selectedVersion == "premium" || accessManager.hasActiveSubscription
    }

    private var todayCheckIn: CreativeCheckIn {
        store.creativeCheckIn()
    }

    private var weeklyDays: [WeeklyCreativeDay] {
        let calendar = Calendar.current
        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -(6 - offset), to: .now) else {
                return nil
            }
            return WeeklyCreativeDay(date: date, checkIn: store.creativeCheckIn(for: date))
        }
    }

    private var todaysPrompt: GlorifyPrompt {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 1
        return prompts[(day - 1) % prompts.count]
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        heroCard
                        dailyPromptCard
                        creativeRhythmSection
                        giftsSection
                        creatorFeedSection
                        waysSection
                        galleryVisionCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
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
                    handleJumpRequest(with: proxy)
                }
                .onChange(of: jumpTarget) { _, _ in
                    handleJumpRequest(with: proxy)
                }
            }
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Glorify God with your creation")
                .font(OVTheme.display(34))
                .foregroundStyle(OVTheme.midnight)

            Text("A creative rhythm that helps you worship, make, refine, and share what God has placed in you.")
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.76))

            HStack(spacing: 8) {
                topChip("Free rhythm")
                topChip("Safe space")
                topChip(isBibleSchoolCreatorSpaceUnlocked ? "Creator feed on" : "Bible School feed")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(
            LinearGradient(
                colors: [OVTheme.lemon.opacity(0.32), .white, OVTheme.mist.opacity(0.54)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .glorifyCard()
    }

    private var dailyPromptCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's creative prompt")
                        .font(OVTheme.heading(22))
                        .foregroundStyle(OVTheme.ink)
                    Text("Start small, stay honest, and make something with God in view.")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.ink.opacity(0.72))
                }
                Spacer()
                Text("Daily")
                    .font(OVTheme.body(11))
                    .foregroundStyle(OVTheme.midnight)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(OVTheme.smoke)
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(todaysPrompt.title)
                    .font(OVTheme.heading(18))
                    .foregroundStyle(OVTheme.midnight)

                Text(todaysPrompt.detail)
                    .font(OVTheme.body(15))
                    .foregroundStyle(OVTheme.ink.opacity(0.74))
            }

            Button {
                scriptureTarget = BibleDataProvider.resolveReference(from: todaysPrompt.reference)
            } label: {
                HStack(spacing: 8) {
                    Text(todaysPrompt.reference)
                        .font(OVTheme.heading(14))
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundStyle(OVTheme.midnight)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(OVTheme.sky.opacity(0.56))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .glorifyCard()
    }

    private var creativeRhythmSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Creative rhythm")
                        .font(OVTheme.heading(22))
                        .foregroundStyle(OVTheme.ink)
                    Text("Free daily habits that help creativity feel holy and consistent again.")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.ink.opacity(0.72))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(store.creativeStreak)")
                        .font(OVTheme.display(30))
                        .foregroundStyle(OVTheme.midnight)
                    Text("day streak")
                        .font(OVTheme.body(12))
                        .foregroundStyle(OVTheme.ink.opacity(0.66))
                }
            }

            weeklyTracker

            VStack(spacing: 10) {
                ForEach(CreativeHabit.allCases) { habit in
                    creativeHabitRow(habit)
                }
            }
        }
    }

    private var weeklyTracker: some View {
        HStack(spacing: 8) {
            ForEach(weeklyDays) { day in
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
        .padding(16)
        .glorifyCard(cornerRadius: 22, fill: OVTheme.elevatedCard)
    }

    private func creativeHabitRow(_ habit: CreativeHabit) -> some View {
        let isDone = todayCheckIn.completedHabits.contains(habit)

        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                store.toggleCreativeHabit(habit)
            }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(habitAccent(habit))
                        .frame(width: 48, height: 48)

                    Image(systemName: habit.symbol)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(OVTheme.midnight)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.title)
                        .font(OVTheme.heading(16))
                        .foregroundStyle(OVTheme.ink)

                    Text(habit.detail)
                        .font(OVTheme.body(13))
                        .foregroundStyle(OVTheme.ink.opacity(0.68))
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(isDone ? OVTheme.midnight : .white)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(isDone ? OVTheme.midnight : OVTheme.line, lineWidth: 1)
                        )

                    if isDone {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(16)
            .glorifyCard(cornerRadius: 22, fill: isDone ? OVTheme.paper : OVTheme.cardBackground)
        }
        .buttonStyle(.plain)
    }

    private var giftsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Discover your gifts")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text("Scripture helps people see that gifts are not random talent flexes. They are entrusted ways to glorify God and serve others.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))

            VStack(spacing: 12) {
                ForEach(giftLanes) { lane in
                    Button {
                        scriptureTarget = BibleDataProvider.resolveReference(from: lane.reference)
                    } label: {
                        HStack(alignment: .top, spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(lane.accent)
                                    .frame(width: 48, height: 48)

                                Image(systemName: lane.symbol)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(OVTheme.midnight)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text(lane.title)
                                    .font(OVTheme.heading(16))
                                    .foregroundStyle(OVTheme.ink)

                                Text(lane.detail)
                                    .font(OVTheme.body(14))
                                    .foregroundStyle(OVTheme.ink.opacity(0.72))

                                Text("\(lane.application) - \(lane.reference)")
                                    .font(OVTheme.body(12))
                                    .foregroundStyle(OVTheme.gold)
                            }

                            Spacer()
                        }
                        .padding(16)
                        .glorifyCard(cornerRadius: 22)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .id(GlorifyRoute.discoverGifts)
    }

    @ViewBuilder
    private var creatorFeedSection: some View {
        if isBibleSchoolCreatorSpaceUnlocked {
            NavigationLink {
                CreationFeedView(store: store)
            } label: {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
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
                .padding(20)
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
            .padding(20)
            .glorifyCard()
        }
    }

    private var waysSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Creative lanes")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text("These keep your creativity anchored in Scripture, not only in inspiration.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))

            VStack(spacing: 12) {
                ForEach(ways) { way in
                    Button {
                        scriptureTarget = BibleDataProvider.resolveReference(from: way.reference)
                    } label: {
                        HStack(alignment: .top, spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(way.accent)
                                    .frame(width: 50, height: 50)

                                Image(systemName: way.symbol)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(OVTheme.midnight)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text(way.title)
                                    .font(OVTheme.heading(16))
                                    .foregroundStyle(OVTheme.ink)
                                Text(way.detail)
                                    .font(OVTheme.body(14))
                                    .foregroundStyle(OVTheme.ink.opacity(0.72))
                                Text("\(way.practice) - \(way.reference)")
                                    .font(OVTheme.body(12))
                                    .foregroundStyle(OVTheme.gold)
                            }

                            Spacer()
                        }
                        .padding(16)
                        .glorifyCard(cornerRadius: 22)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var galleryVisionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sacred gallery")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.midnight)

            Text("This space can grow into Jesus-centered paintings, visual devotionals, and curated art that helps people feel safe creating for God again.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.74))

            HStack(spacing: 8) {
                topChip("Art")
                topChip("Visual devotionals")
                topChip("Creation culture")
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [OVTheme.sky.opacity(0.35), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .glorifyCard()
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

    private func habitAccent(_ habit: CreativeHabit) -> Color {
        switch habit {
        case .worshipFirst:
            return OVTheme.lemon.opacity(0.5)
        case .createSomething:
            return OVTheme.sky.opacity(0.62)
        case .refineWithCare:
            return OVTheme.mint.opacity(0.7)
        case .shareLight:
            return OVTheme.orchid.opacity(0.68)
        }
    }

    private func shortWeekday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }

    private func handleJumpRequest(with proxy: ScrollViewProxy) {
        guard jumpTarget == .discoverGifts else { return }

        DispatchQueue.main.async {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
                proxy.scrollTo(GlorifyRoute.discoverGifts, anchor: .top)
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
            VStack(alignment: .leading, spacing: 18) {
                headerCard
                composeCard
                feedSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
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
        .padding(20)
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
        .padding(20)
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
                        .background(selected == item ? OVTheme.midnight : OVTheme.smoke)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct GlorifySurfaceCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let fill: Color

    func body(content: Content) -> some View {
        content
            .background(fill)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(OVTheme.line, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 18, y: 8)
    }
}

private extension View {
    func glorifyCard(cornerRadius: CGFloat = 24, fill: Color = OVTheme.cardBackground) -> some View {
        modifier(GlorifySurfaceCardModifier(cornerRadius: cornerRadius, fill: fill))
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
