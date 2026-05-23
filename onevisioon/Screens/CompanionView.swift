import SwiftUI

struct CourseView: View {
    @ObservedObject var store: SoulJourneyStore
    @State private var learnedToday = ""
    @State private var applicationPlan = ""
    @State private var prayerAction = ""
    @State private var trackerFeedback = ""
    @State private var showDailyCheckInForm = false
    @State private var showDailyCheckInCompletedState = false
    @State private var showStreakCalendarSheet = false
    @State private var streakCalendarDetent: PresentationDetent = .large
    @State private var showContent = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    courseHeader
                        .stagedReveal(showContent, delay: 0.02)
                    quickSessionCard
                        .stagedReveal(showContent, delay: 0.05)
                    discordCommunityCard
                        .stagedReveal(showContent, delay: 0.08)
                    if shouldShowDailyCheckInCard {
                        dailyCheckInCard
                            .stagedReveal(showContent, delay: 0.14)
                    }
                    foldersSection
                        .stagedReveal(showContent, delay: 0.2)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("Learn")
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
                                .foregroundStyle(store.didUseAppToday ? OVTheme.coral : OVTheme.ink.opacity(0.45))

                            Text("\(store.currentStreak)")
                                .font(OVTheme.heading(14))
                                .foregroundStyle(.black)
                                .contentTransition(.numericText())
                                .animation(.easeInOut(duration: 0.24), value: store.currentStreak)

                            Text(store.currentStreak == 1 ? "day streak" : "day streak")
                                .font(OVTheme.heading(15))
                                .foregroundStyle(.black.opacity(0.72))
                        }
                        .fixedSize(horizontal: true, vertical: false)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.95))
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
            .onAppear {
                guard !showContent else { return }
                showContent = true
            }
        }
    }

    private var courseHeader: some View {
        let currentLesson = store.currentCourseLesson
        let progress = store.progress(for: currentLesson)

        return VStack(alignment: .leading, spacing: 12) {
            Text("Today's focus")
                .font(OVTheme.heading(15))
                .foregroundStyle(OVTheme.gold)

            Text("Your next step")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text(store.course.title)
                .font(OVTheme.display(34))
                .foregroundStyle(OVTheme.midnight)

            Text(store.course.subtitle)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.74))
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            HStack(spacing: 10) {
                chip("Lessons", "\(store.completedLessonsCount)/\(store.lessons.count)")
                chip("Quests", "\(store.passedQuestsCount)/\(store.lessons.count)")
                chip("Points", "\(store.wisdomPoints)")
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Continue here")
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.ink.opacity(0.6))

                Text("Lesson \(currentLesson.order): \(currentLesson.title)")
                    .font(OVTheme.heading(16))
                    .foregroundStyle(OVTheme.ink)
                    .lineLimit(2)

                Text(currentLessonSummary(for: currentLesson, progress: progress))
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.ink.opacity(0.7))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("What you'll become")
                    .font(OVTheme.heading(14))
                    .foregroundStyle(OVTheme.ink)

                ForEach(courseTransformationOutcomes, id: \.self) { outcome in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(OVTheme.gold)
                        Text(outcome)
                            .font(OVTheme.body(13))
                            .foregroundStyle(OVTheme.ink.opacity(0.76))
                    }
                }
            }
            .padding(14)
            .background(.white.opacity(0.88))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Course Completion")
                        .font(OVTheme.heading(14))
                        .foregroundStyle(OVTheme.ink)
                    Spacer()
                    Text("\(store.courseCompletionPercent)%")
                        .font(OVTheme.heading(14))
                        .foregroundStyle(OVTheme.midnight)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.24), value: store.courseCompletionPercent)
                }

                ProgressView(value: Double(store.courseCompletionPercent), total: 100)
                    .tint(OVTheme.midnight)
            }

            NavigationLink {
                WisdomFolderView(store: store, course: store.course)
            } label: {
                HStack {
                    Text("Continue your walk")
                        .font(OVTheme.heading(15))
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(OVTheme.midnight)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                colors: [OVTheme.lemon.opacity(0.62), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var courseTransformationOutcomes: [String] {
        [
            "Make wiser decisions before emotions take over.",
            "Build a disciplined daily walk instead of drifting.",
            "Turn Scripture into action while you're still in the day."
        ]
    }

    private func currentLessonSummary(for lesson: WisdomLesson, progress: LessonProgress) -> String {
        if store.courseCompletionPercent == 100 {
            return "You've finished this path. Revisit any lesson whenever you need it."
        }
        if progress.lessonCompleted && !progress.quizPassed {
            return "Your lesson is done. Finish the quest to lock it in."
        }
        if progress.quizPassed {
            return "You've earned the next unlocked lesson."
        }
        return "This is the next lesson shaping your walk."
    }

    private var shouldShowDailyCheckInCard: Bool {
        showDailyCheckInCompletedState || !store.hasSubmittedDailyGrowthToday
    }

    private var discordCommunityCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "person.3.fill")
                    .foregroundStyle(OVTheme.midnight)
                Text("Daily Discord Bible Study")
                    .font(OVTheme.heading(20))
                    .foregroundStyle(OVTheme.ink)
            }

            Text("Join daily live Bible study calls and connect with the community on Discord.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))

            if let discordURL = URL(string: "https://discord.gg/jadCeEm8TE") {
                Link(destination: discordURL) {
                    Text("Join Discord")
                        .font(OVTheme.heading(14))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(OVTheme.midnight)
                        .clipShape(Capsule())
                }
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
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var quickSessionCard: some View {
        let lesson = store.currentCourseLesson
        let slide = lesson.slides.first
        let insight = slide.map { VerseInsightLibrary.insight(for: $0.supportVerse) }

        return NavigationLink {
            QuickSessionView(store: store, lesson: lesson)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Quick 3 min session")
                        .font(OVTheme.heading(22))
                        .foregroundStyle(OVTheme.ink)
                    Spacer()
                    Text("Reset fast")
                        .font(OVTheme.body(11))
                        .foregroundStyle(OVTheme.gold)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.9))
                        .clipShape(Capsule())
                }

                Text("Some days you do not need a full lesson first. Take one verse, one truth, and one action.")
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.72))

                if let insight {
                    Text(insight.reference)
                        .font(OVTheme.heading(15))
                        .foregroundStyle(OVTheme.midnight)

                    Text(insight.summary)
                        .font(OVTheme.body(13))
                        .foregroundStyle(OVTheme.ink.opacity(0.7))
                        .lineLimit(2)
                }

                HStack {
                    Text("Open quick session")
                        .font(OVTheme.heading(14))
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(OVTheme.midnight)
                .clipShape(Capsule())
            }
            .padding(20)
            .background(.white.opacity(0.96))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func chip(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(label.uppercased())
                .font(OVTheme.body(10))
                .foregroundStyle(OVTheme.ink.opacity(0.55))
            Text(value)
                .font(OVTheme.heading(14))
                .foregroundStyle(OVTheme.midnight)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var dailyCheckInCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Daily Check in")
                    .font(OVTheme.heading(22))
                    .foregroundStyle(OVTheme.ink)

                Spacer()

                if showDailyCheckInCompletedState {
                    Text("Completed")
                        .font(OVTheme.heading(13))
                        .foregroundStyle(.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(.green.opacity(0.12))
                        .clipShape(Capsule())
                } else {
                    Button {
                        trackerFeedback = ""
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showDailyCheckInForm.toggle()
                        }
                    } label: {
                        Text(showDailyCheckInForm ? "Hide" : (store.canUseDailyCheckIn ? "Open" : "Locked"))
                            .font(OVTheme.heading(13))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                            .background(store.canUseDailyCheckIn ? OVTheme.midnight : OVTheme.ink.opacity(0.3))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(!store.canUseDailyCheckIn)
                }
            }

            Text("What did God show you today? Write the truth, the action, and the prayer you will carry into the rest of today. (Unlocked after one lesson today)")
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.7))

            if showDailyCheckInCompletedState {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Today's check in is saved. This card will disappear in a moment.")
                        .font(OVTheme.body(13))
                        .foregroundStyle(OVTheme.ink.opacity(0.74))
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            } else if showDailyCheckInForm && store.canUseDailyCheckIn {
                VStack(alignment: .leading, spacing: 10) {
                    trackerField("Insight: what did God show you today?", text: $learnedToday)
                    trackerField("Action: what will you obey today?", text: $applicationPlan)
                    trackerField("Prayer: what are you asking God to do?", text: $prayerAction)

                    Button {
                        let saved = store.addDailyGrowthEntry(
                            learnedToday: learnedToday,
                            applicationPlan: applicationPlan,
                            prayerAction: prayerAction
                        )

                        if saved {
                            trackerFeedback = ""
                            learnedToday = ""
                            applicationPlan = ""
                            prayerAction = ""

                            withAnimation(.easeInOut(duration: 0.2)) {
                                showDailyCheckInForm = false
                                showDailyCheckInCompletedState = true
                            }

                            Task {
                                try? await Task.sleep(nanoseconds: 3_000_000_000)
                                await MainActor.run {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        showDailyCheckInCompletedState = false
                                    }
                                }
                            }
                        } else if store.hasSubmittedDailyGrowthToday {
                            trackerFeedback = "Today's check in is already submitted."
                        } else {
                            trackerFeedback = "Complete all three fields."
                        }
                    } label: {
                        Text("Save Check In (+25)")
                            .font(OVTheme.heading(15))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(OVTheme.midnight)
                            .clipShape(Capsule())
                    }

                    if !trackerFeedback.isEmpty {
                        Text(trackerFeedback)
                            .font(OVTheme.body(12))
                            .foregroundStyle(.orange)
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            } else {
                requirementRow("Complete one lesson today", met: store.hasCompletedLessonToday)

                Text("Finish today's lesson to unlock the check in form.")
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.ink.opacity(0.66))
            }
        }
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .animation(.easeInOut(duration: 0.2), value: showDailyCheckInForm)
        .animation(.easeInOut(duration: 0.2), value: showDailyCheckInCompletedState)
    }

    private var foldersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your paths")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            NavigationLink {
                WisdomFolderView(store: store, course: store.course)
            } label: {
                folderCard(
                    title: "Wisdom",
                    subtitle: "Start with Proverbs",
                    detail: "\(store.lessons.count) lessons that build disciplined wisdom chapter by chapter",
                    icon: "book.pages",
                    gradient: [OVTheme.lemon.opacity(0.5), .white]
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                WisdomFolderView(store: store, course: store.wisdomV2Course)
            } label: {
                folderCard(
                    title: "Wisdom v2",
                    subtitle: "Bible-wide wisdom",
                    detail: "\(store.lessons(for: store.wisdomV2Course).count) deeper lessons across Scripture with stronger checkpoints",
                    icon: "books.vertical.fill",
                    gradient: [OVTheme.lemon.opacity(0.5), .white]
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                ComingSoonFolderView()
            } label: {
                folderCard(
                    title: "Coming Soon",
                    subtitle: "Next folders",
                    detail: "Psalms, parables, doctrine, Christian life",
                    icon: "sparkles.rectangle.stack",
                    gradient: [OVTheme.sky.opacity(0.36), .white]
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func folderCard(
        title: String,
        subtitle: String,
        detail: String,
        icon: String,
        gradient: [Color]
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(OVTheme.midnight)
                .frame(width: 38, height: 38)
                .background(.white.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(OVTheme.heading(19))
                    .foregroundStyle(OVTheme.ink)
                Text(subtitle)
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.midnight)
                Text(detail)
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.ink.opacity(0.7))
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(OVTheme.ink.opacity(0.35))
                .padding(.top, 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var outcomesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What you'll gain")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            ForEach(store.course.outcomes, id: \.self) { outcome in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(OVTheme.midnight)
                    Text(outcome)
                        .font(OVTheme.body(15))
                        .foregroundStyle(OVTheme.ink.opacity(0.76))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var lessonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lessons (unlock in order)")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            ForEach(store.lessons) { lesson in
                lessonCard(lesson)
            }
        }
    }

    private func lessonCard(_ lesson: WisdomLesson) -> some View {
        let unlocked = store.isLessonUnlocked(lesson)
        let progress = store.progress(for: lesson)

        return NavigationLink {
            LessonDetailView(store: store, lesson: lesson)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Lesson \(lesson.order)")
                            .font(OVTheme.body(12))
                            .foregroundStyle(OVTheme.ink.opacity(0.56))
                        Text(lesson.title)
                            .font(OVTheme.heading(18))
                            .foregroundStyle(OVTheme.ink)
                    }

                    Spacer()

                    Text(statusLabel(unlocked: unlocked, progress: progress))
                        .font(OVTheme.body(12))
                        .foregroundStyle(statusColor(unlocked: unlocked, progress: progress))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.95))
                        .clipShape(Capsule())
                }

                Text(lesson.sourceName)
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.midnight)

                Text(lesson.summary)
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.72))
                    .lineLimit(3)

                Text("\(lesson.slides.count) guided slides + checkpoint + quest")
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.ink.opacity(0.62))

                if !unlocked {
                    Text("Complete and pass the previous lesson quest to unlock.")
                        .font(OVTheme.body(12))
                        .foregroundStyle(OVTheme.ink.opacity(0.56))
                }
            }
            .padding(16)
            .background(unlocked ? OVTheme.lemon.opacity(0.4) : OVTheme.smoke)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(unlocked ? .clear : OVTheme.ink.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(!unlocked)
        .opacity(unlocked ? 1 : 0.7)
    }

    private func statusLabel(unlocked: Bool, progress: LessonProgress) -> String {
        guard unlocked else { return "Locked" }
        if progress.quizPassed { return "Passed" }
        if progress.lessonCompleted { return "Quest Ready" }
        return "Start"
    }

    private func statusColor(unlocked: Bool, progress: LessonProgress) -> Color {
        guard unlocked else { return OVTheme.ink.opacity(0.55) }
        if progress.quizPassed { return .green }
        if progress.lessonCompleted { return OVTheme.midnight }
        return OVTheme.midnight
    }

    private func trackerField(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.72))

            TextEditor(text: text)
                .font(OVTheme.body(14))
                .frame(minHeight: 70)
                .padding(8)
                .background(OVTheme.smoke)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private func requirementRow(_ text: String, met: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: met ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(met ? .green : OVTheme.ink.opacity(0.45))
            Text(text)
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.78))
        }
    }
}

private struct ActivityMonthCalendarView: View {
    @ObservedObject var store: SoulJourneyStore
    @State private var displayedMonth = Date()

    private var calendar: Calendar { Calendar.current }
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            monthNavigation

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(OVTheme.body(11))
                        .foregroundStyle(OVTheme.ink.opacity(0.55))
                        .frame(maxWidth: .infinity)
                }

                ForEach(Array(dayGrid.enumerated()), id: \.offset) { _, date in
                    if let date {
                        dayCell(date)
                    } else {
                        Color.clear
                            .frame(height: 30)
                    }
                }
            }

            Text("\(activeDaysInDisplayedMonth) active day(s) in \(monthTitle(for: displayedMonth)).")
                .font(OVTheme.body(12))
                .foregroundStyle(OVTheme.ink.opacity(0.66))
        }
    }

    private var monthNavigation: some View {
        HStack(spacing: 8) {
            Button {
                shiftMonth(-1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(OVTheme.midnight)
                    .frame(width: 28, height: 28)
                    .background(.white.opacity(0.95))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Activity Calendar")
                .font(OVTheme.heading(14))
                .foregroundStyle(OVTheme.ink.opacity(0.65))

            Spacer()

            Text(monthTitle(for: displayedMonth))
                .font(OVTheme.heading(14))
                .foregroundStyle(OVTheme.ink)

            Button {
                shiftMonth(1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(OVTheme.midnight)
                    .frame(width: 28, height: 28)
                    .background(.white.opacity(0.95))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let shift = max(0, min(6, calendar.firstWeekday - 1))
        return Array(symbols[shift...]) + Array(symbols[..<shift])
    }

    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private var dayGrid: [Date?] {
        guard let monthRange = calendar.dateInterval(of: .month, for: displayedMonth) else { return [] }
        let firstDay = monthRange.start
        guard let dayCount = calendar.range(of: .day, in: .month, for: firstDay)?.count else { return [] }

        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let leadingSlots = (firstWeekday - calendar.firstWeekday + 7) % 7

        var values = Array(repeating: Date?.none, count: leadingSlots)
        for offset in 0..<dayCount {
            if let date = calendar.date(byAdding: .day, value: offset, to: firstDay) {
                values.append(date)
            }
        }
        return values
    }

    private var activeDaysInDisplayedMonth: Int {
        dayGrid.compactMap { $0 }.filter { store.isActive(on: $0) }.count
    }

    private func shiftMonth(_ offset: Int) {
        guard let moved = calendar.date(byAdding: .month, value: offset, to: displayedMonth) else { return }
        displayedMonth = moved
    }

    private func dayCell(_ date: Date) -> some View {
        let today = calendar.startOfDay(for: .now)
        let normalized = calendar.startOfDay(for: date)
        let isFuture = normalized > today
        let active = store.isActive(on: date)
        let isToday = calendar.isDateInToday(date)

        return Text("\(calendar.component(.day, from: date))")
            .font(OVTheme.body(12))
            .foregroundStyle(active ? .white : OVTheme.ink.opacity(isFuture ? 0.35 : (isToday ? 0.95 : 0.68)))
            .frame(maxWidth: .infinity, minHeight: 30)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(active ? OVTheme.midnight : (isToday ? OVTheme.sky.opacity(0.35) : .white.opacity(isFuture ? 0.4 : 0.75)))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(isToday ? OVTheme.midnight.opacity(0.2) : .clear, lineWidth: 1)
            )
    }
}

struct StreakCalendarSheetView: View {
    @ObservedObject var store: SoulJourneyStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Activity calendar")
                    .font(OVTheme.heading(24))
                    .foregroundStyle(OVTheme.ink)
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .font(OVTheme.heading(14))
                .foregroundStyle(OVTheme.midnight)
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Current streak")
                        .font(OVTheme.body(13))
                        .foregroundStyle(OVTheme.ink.opacity(0.65))
                    Text(store.didUseAppToday ? "Active today" : "No activity logged today")
                        .font(OVTheme.body(12))
                        .foregroundStyle(store.didUseAppToday ? .green : OVTheme.ink.opacity(0.58))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(store.currentStreak)")
                        .font(OVTheme.display(46))
                        .foregroundStyle(.black)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.24), value: store.currentStreak)

                    Text("Total active days: \(store.totalActiveDays)")
                        .font(OVTheme.body(12))
                        .foregroundStyle(OVTheme.ink.opacity(0.62))
                }
            }

            Text(store.currentStreak == 0 ? "You are not on a streak right now. Open the app tomorrow to start the fire again." : "Do not break your streak. If you miss a full day, it resets and starts again from 1.")
                .font(OVTheme.body(12))
                .foregroundStyle(OVTheme.ink.opacity(0.58))

            ActivityMonthCalendarView(store: store)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
        .padding(.bottom, 16)
        .background(OVTheme.mainBackground.ignoresSafeArea())
    }
}

private struct QuickSessionView: View {
    @ObservedObject var store: SoulJourneyStore
    let lesson: WisdomLesson

    private var quickSlide: LessonSlide? {
        lesson.slides.first
    }

    private var insight: VerseInsight? {
        guard let quickSlide else { return nil }
        return VerseInsightLibrary.insight(for: quickSlide.supportVerse)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Quick 3 min session")
                    .font(OVTheme.display(34))
                    .foregroundStyle(OVTheme.midnight)

                Text("For days when you need a reset fast.")
                    .font(OVTheme.body(15))
                    .foregroundStyle(OVTheme.ink.opacity(0.72))

                if let insight {
                    quickBlock("Verse", detail: insight.reference)
                    quickBlock("Truth", detail: insight.summary)
                }

                if let quickSlide {
                    quickBlock("Action", detail: quickSlide.reflectionPrompt)
                }

                NavigationLink {
                    LessonDetailView(store: store, lesson: lesson)
                } label: {
                    HStack {
                        Text("Continue your walk")
                            .font(OVTheme.heading(15))
                            .foregroundStyle(.white)
                        Spacer()
                        Image(systemName: "arrow.right")
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(OVTheme.midnight)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle("Quick Session")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func quickBlock(_ title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(OVTheme.heading(14))
                .foregroundStyle(OVTheme.gold)
            Text(detail)
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.82))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct WisdomFolderView: View {
    @ObservedObject var store: SoulJourneyStore
    let course: WisdomCourse

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header
                outcomesCard
                lessonsSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle(course.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                AppInfoButton()
            }
        }
    }

    private var header: some View {
        let currentLesson = store.currentLesson(in: course)
        let progress = store.progress(for: currentLesson)

        return VStack(alignment: .leading, spacing: 10) {
            Text("Your path")
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.midnight.opacity(0.7))

            Text(course.title)
                .font(OVTheme.display(34))
                .foregroundStyle(OVTheme.midnight)

            Text(course.subtitle)
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.7))
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            HStack(spacing: 10) {
                chip("Lessons", "\(store.completedLessonsCount(for: course))/\(store.lessons(for: course).count)")
                chip("Quests", "\(store.passedQuestsCount(for: course))/\(store.lessons(for: course).count)")
                chip("Points", "\(store.wisdomPoints)")
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("You're on")
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.ink.opacity(0.6))

                Text("Lesson \(currentLesson.order): \(currentLesson.title)")
                    .font(OVTheme.heading(16))
                    .foregroundStyle(OVTheme.ink)
                    .lineLimit(2)

                Text(currentLessonSummary(for: currentLesson, progress: progress))
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.ink.opacity(0.7))
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Course Completion")
                        .font(OVTheme.heading(14))
                        .foregroundStyle(OVTheme.ink)
                    Spacer()
                    Text("\(store.courseCompletionPercent(for: course))%")
                        .font(OVTheme.heading(14))
                        .foregroundStyle(OVTheme.midnight)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.24), value: store.courseCompletionPercent(for: course))
                }

                ProgressView(value: Double(store.courseCompletionPercent(for: course)), total: 100)
                    .tint(OVTheme.midnight)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func currentLessonSummary(for lesson: WisdomLesson, progress: LessonProgress) -> String {
        if store.courseCompletionPercent(for: course) == 100 {
            return "Every lesson and quest is complete."
        }
        if progress.lessonCompleted && !progress.quizPassed {
            return "Lesson complete. Take the quest next."
        }
        if progress.quizPassed {
            return "Lesson complete. Move into the next unlocked lesson."
        }
        return "This is the next lesson to finish."
    }

    private func chip(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(label.uppercased())
                .font(OVTheme.body(10))
                .foregroundStyle(OVTheme.ink.opacity(0.55))
            Text(value)
                .font(OVTheme.heading(14))
                .foregroundStyle(OVTheme.midnight)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var outcomesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What you'll become")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            ForEach(transformationalOutcomes, id: \.self) { outcome in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(OVTheme.gold)
                    Text(outcome)
                        .font(OVTheme.body(15))
                        .foregroundStyle(OVTheme.ink.opacity(0.76))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var transformationalOutcomes: [String] {
        if course.id == store.course.id {
            return [
                "Make better decisions before pressure makes them for you.",
                "Guard your heart, thoughts, words, and habits with Proverbs-shaped wisdom.",
                "Trade passive scrolling for disciplined daily growth.",
                "Turn chapter-by-chapter truth into practical obedience."
            ]
        }

        return [
            "See wisdom across all of Scripture instead of only one book.",
            "Strengthen memory through checkpoints that force real recall.",
            "Learn to recognize God's voice, priorities, and patterns more clearly.",
            "Grow into steadier discernment in hard real-life situations."
        ]
    }

    private var lessonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lessons (unlock in order)")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            ForEach(store.lessons(for: course)) { lesson in
                lessonCard(lesson)
            }
        }
    }

    private func lessonCard(_ lesson: WisdomLesson) -> some View {
        let unlocked = store.isLessonUnlocked(lesson)
        let progress = store.progress(for: lesson)

        return NavigationLink {
            LessonDetailView(store: store, lesson: lesson)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Lesson \(lesson.order)")
                            .font(OVTheme.body(12))
                            .foregroundStyle(OVTheme.ink.opacity(0.56))
                        Text(lesson.title)
                            .font(OVTheme.heading(18))
                            .foregroundStyle(OVTheme.ink)
                    }

                    Spacer()

                    Text(statusLabel(unlocked: unlocked, progress: progress))
                        .font(OVTheme.body(12))
                        .foregroundStyle(statusColor(unlocked: unlocked, progress: progress))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.95))
                        .clipShape(Capsule())
                }

                Text(lesson.sourceName)
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.midnight)

                Text(lesson.summary)
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.72))
                    .lineLimit(3)

                Text("\(lesson.slides.count) guided slides + checkpoint + quest")
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.ink.opacity(0.62))

                if !unlocked {
                    Text("Complete and pass the previous lesson quest to unlock.")
                        .font(OVTheme.body(12))
                        .foregroundStyle(OVTheme.ink.opacity(0.56))
                }
            }
            .padding(16)
            .background(unlocked ? OVTheme.lemon.opacity(0.4) : OVTheme.smoke)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(unlocked ? .clear : OVTheme.ink.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(!unlocked)
        .opacity(unlocked ? 1 : 0.7)
    }

    private func statusLabel(unlocked: Bool, progress: LessonProgress) -> String {
        guard unlocked else { return "Locked" }
        if progress.quizPassed { return "Passed" }
        if progress.lessonCompleted { return "Quest Ready" }
        return "Start"
    }

    private func statusColor(unlocked: Bool, progress: LessonProgress) -> Color {
        guard unlocked else { return OVTheme.ink.opacity(0.55) }
        if progress.quizPassed { return .green }
        if progress.lessonCompleted { return OVTheme.midnight }
        return OVTheme.midnight
    }
}

private struct ComingSoonFolderView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Coming soon")
                    .font(OVTheme.display(36))
                    .foregroundStyle(OVTheme.midnight)

                Text("Next learning folders")
                    .font(OVTheme.heading(30))
                    .foregroundStyle(OVTheme.ink)

                Text("More bite-sized Christian learning tracks are being prepared.")
                    .font(OVTheme.body(15))
                    .foregroundStyle(OVTheme.ink.opacity(0.7))

                comingSoonCard("Psalms for Anxiety and Peace", "Prayer-focused emotional formation.")
                comingSoonCard("Jesus' Parables", "Interpretation + practical obedience.")
                comingSoonCard("Biblical Relationships", "Conflict, forgiveness, and love in action.")
                comingSoonCard("Doctrine in Daily Life", "Core beliefs translated into habits.")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle("Coming Soon")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func comingSoonCard(_ title: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(OVTheme.heading(18))
                .foregroundStyle(OVTheme.ink)
            Text(detail)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))
            Text("Planned")
                .font(OVTheme.body(11))
                .foregroundStyle(OVTheme.midnight)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(OVTheme.sky.opacity(0.4))
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct LessonDetailView: View {
    @ObservedObject var store: SoulJourneyStore
    let lesson: WisdomLesson

    @State private var step: Int
    @State private var checkpointQuestion: WisdomQuestion
    @State private var checkpointSelection: Int?
    @State private var checkpointPassed = false
    @State private var checkpointFeedback = ""
    @State private var notesTemplate: LessonNoteTemplate
    @State private var startQuest = false
    @State private var savedNoteAt: Date?
    @State private var noteSaveFeedback = ""
    @State private var showNotesPanel = false

    private let checkpointStep = 3

    init(store: SoulJourneyStore, lesson: WisdomLesson) {
        self.store = store
        self.lesson = lesson

        let fallback = WisdomQuestion(
            id: "\(lesson.id)-checkpoint-fallback",
            prompt: "What is the best next step after learning biblical wisdom?",
            options: [
                "Ignore it until a crisis",
                "Apply it with prayer and obedience",
                "Debate others online",
                "Wait for perfect conditions"
            ],
            correctIndex: 1,
            explanation: "Biblical wisdom matures through prayerful application."
        )

        let maxStep = max(0, lesson.slides.count)
        let initialStep = min(max(0, store.lessonStudyStep(for: lesson)), maxStep)
        _step = State(initialValue: initialStep)
        _checkpointQuestion = State(initialValue: lesson.assessmentQuest.questions.randomElement() ?? fallback)
        _notesTemplate = State(initialValue: store.noteTemplate(for: lesson))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header
                progressBar
                lessonCard
                notesPanelSection
                flowButtons
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle("Lesson \(lesson.order)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $startQuest) {
            QuestTakeView(store: store, lesson: lesson)
        }
        .onAppear {
            if store.progress(for: lesson).lessonCompleted {
                let lastStep = max(0, totalSteps - 1)
                if step < lastStep {
                    step = lastStep
                }
            }
        }
        .onChange(of: step) { _, newValue in
            store.saveLessonStudyStep(for: lesson, step: newValue)
        }
    }

    private var totalSteps: Int {
        lesson.slides.count + 1
    }

    private var isCheckpointStep: Bool {
        step == checkpointStep
    }

    private var isLastStep: Bool {
        step == totalSteps - 1
    }

    private var assessmentQuest: WisdomQuest {
        lesson.assessmentQuest
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(lesson.title)
                .font(OVTheme.heading(30))
                .foregroundStyle(OVTheme.ink)

            if let sourceURL = URL(string: lesson.sourceURL) {
                Link(destination: sourceURL) {
                    Text("Source: \(lesson.sourceName)")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.midnight)
                        .underline()
                }
            }

            Text("Step \(step + 1) of \(totalSteps)")
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.64))
        }
    }

    private var progressBar: some View {
        ProgressView(value: Double(step + 1), total: Double(totalSteps))
            .tint(OVTheme.midnight)
    }

    @ViewBuilder
    private var lessonCard: some View {
        if isCheckpointStep {
            checkpointCard
        } else if let slide = currentSlide {
            slideCard(slide)
        }
    }

    private var currentSlide: LessonSlide? {
        let index: Int
        if step < checkpointStep {
            index = step
        } else {
            index = step - 1
        }

        guard index >= 0 && index < lesson.slides.count else { return nil }
        return lesson.slides[index]
    }

    private func slideCard(_ slide: LessonSlide) -> some View {
        let insight = VerseInsightLibrary.insight(for: slide.supportVerse)

        return VStack(alignment: .leading, spacing: 12) {
            Text(slide.title)
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text(slide.body)
                .font(OVTheme.body(16))
                .foregroundStyle(OVTheme.ink.opacity(0.78))

            ForEach(slide.bullets, id: \.self) { bullet in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle")
                        .foregroundStyle(OVTheme.midnight)
                    Text(bullet)
                        .font(OVTheme.body(15))
                        .foregroundStyle(OVTheme.ink.opacity(0.78))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Reflection")
                    .font(OVTheme.heading(14))
                    .foregroundStyle(OVTheme.midnight)
                Text(slide.reflectionPrompt)
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.7))
            }
            .padding(10)
            .background(OVTheme.sky.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text("Bible Verse Support")
                    .font(OVTheme.heading(14))
                    .foregroundStyle(OVTheme.midnight)
                Text(insight.reference)
                    .font(OVTheme.heading(14))
                    .foregroundStyle(OVTheme.ink)

                Divider()

                Text("Written about")
                    .font(OVTheme.heading(13))
                    .foregroundStyle(OVTheme.midnight)
                Text(insight.writtenAbout)
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.85))

                Text("Summary")
                    .font(OVTheme.heading(13))
                    .foregroundStyle(OVTheme.midnight)
                Text(insight.summary)
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.85))

                Text("Deeper meaning")
                    .font(OVTheme.heading(13))
                    .foregroundStyle(OVTheme.midnight)
                Text(insight.deeperMeaning)
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.85))
            }
            .padding(10)
            .background(OVTheme.lemon.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var checkpointCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Checkpoint Question")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text("Answer this before you continue the lesson.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.65))

            Text(checkpointQuestion.prompt)
                .font(OVTheme.heading(16))
                .foregroundStyle(OVTheme.ink)

            ForEach(Array(checkpointQuestion.options.enumerated()), id: \.offset) { option in
                Button {
                    checkpointSelection = option.offset
                    checkpointPassed = false
                    checkpointFeedback = ""
                } label: {
                    HStack {
                        Image(systemName: checkpointSelection == option.offset ? "largecircle.fill.circle" : "circle")
                            .foregroundStyle(OVTheme.midnight)
                        Text(option.element)
                            .font(OVTheme.body(14))
                            .foregroundStyle(OVTheme.ink.opacity(0.78))
                        Spacer()
                    }
                    .padding(10)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
            }

            Button {
                validateCheckpoint()
            } label: {
                Text("Submit Checkpoint")
                    .font(OVTheme.heading(14))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(OVTheme.midnight)
                    .clipShape(Capsule())
            }
            .disabled(checkpointSelection == nil)
            .opacity(checkpointSelection == nil ? 0.4 : 1)

            if !checkpointFeedback.isEmpty {
                Text(checkpointFeedback)
                    .font(OVTheme.body(13))
                    .foregroundStyle(checkpointPassed ? .green : .orange)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var notesPanelSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showNotesPanel.toggle()
                }
            } label: {
                HStack {
                    Text(showNotesPanel ? "Close Notes" : "Open Notes")
                        .font(OVTheme.heading(15))
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: showNotesPanel ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(OVTheme.midnight)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            if showNotesPanel {
                notesCard
            }
        }
    }

    private var notesCard: some View {
        let hasSavedNote = store.noteTemplate(for: lesson) != .empty

        return VStack(alignment: .leading, spacing: 10) {
            Text("Lesson Notes Template")
                .font(OVTheme.heading(21))
                .foregroundStyle(OVTheme.ink)

            Text("Use this structure so notes are searchable later in Profile > Notes.")
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.68))

            Group {
                noteField("Key truth learned", text: $notesTemplate.keyTruth, minHeight: 78)
                TextField("Key verse", text: $notesTemplate.keyVerse)
                    .textFieldStyle(.roundedBorder)
                noteField("How I will apply this today", text: $notesTemplate.applicationToday, minHeight: 78)
                noteField("Prayer response", text: $notesTemplate.prayerResponse, minHeight: 78)
            }

            Button {
                let result = store.saveLessonNote(for: lesson, template: notesTemplate)
                if result.saved {
                    savedNoteAt = .now
                    if result.pointsEarned > 0 {
                        noteSaveFeedback = "Saved. +\(result.pointsEarned) points awarded for this lesson note."
                    } else {
                        noteSaveFeedback = "Saved. Note updated. Points are only awarded once per lesson."
                    }
                } else {
                    noteSaveFeedback = "Add at least one note field before saving."
                }
            } label: {
                Text(hasSavedNote ? "Update Notes" : "Save Notes (+15 points once)")
                    .font(OVTheme.heading(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(OVTheme.midnight)
                    .clipShape(Capsule())
            }

            if !noteSaveFeedback.isEmpty {
                Text(noteSaveFeedback)
                    .font(OVTheme.body(12))
                    .foregroundStyle(noteSaveFeedback.contains("+") ? .green : OVTheme.ink.opacity(0.65))
            }

            if let savedNoteAt {
                Text("Saved \(relativeDate(savedNoteAt)). Find this in Profile > Saved notes.")
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.ink.opacity(0.62))
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var flowButtons: some View {
        VStack(spacing: 10) {
            if isLastStep {
                Button {
                    store.markLessonCompleted(lesson)
                    startQuest = true
                } label: {
                    Text("Take Lesson Quest")
                        .font(OVTheme.heading(16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(OVTheme.midnight)
                        .clipShape(Capsule())
                }

                Text("You will need at least \(assessmentQuest.passingScore)% to unlock the next lesson.")
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.ink.opacity(0.62))
            } else {
                HStack(spacing: 10) {
                    Button {
                        if step > 0 {
                            step -= 1
                        }
                    } label: {
                        Text("Back")
                            .font(OVTheme.heading(15))
                            .foregroundStyle(OVTheme.midnight)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(.white)
                            .clipShape(Capsule())
                    }
                    .disabled(step == 0)
                    .opacity(step == 0 ? 0.35 : 1)

                    Button {
                        moveForward()
                    } label: {
                        Text(isCheckpointStep ? "Continue" : "Next")
                            .font(OVTheme.heading(15))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(OVTheme.midnight)
                            .clipShape(Capsule())
                    }
                    .disabled(isCheckpointStep && !checkpointPassed)
                    .opacity(isCheckpointStep && !checkpointPassed ? 0.35 : 1)
                }
            }
        }
    }

    private func moveForward() {
        guard step < totalSteps - 1 else { return }
        step += 1
    }

    private func validateCheckpoint() {
        guard let selection = checkpointSelection else { return }

        if selection == checkpointQuestion.correctIndex {
            checkpointPassed = true
            checkpointFeedback = "Correct. \(checkpointQuestion.explanation)"
        } else {
            checkpointPassed = false
            checkpointFeedback = "Not yet. \(checkpointQuestion.explanation)"
        }
    }

    private func noteField(_ title: String, text: Binding<String>, minHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.75))

            TextEditor(text: text)
                .font(OVTheme.body(14))
                .frame(minHeight: minHeight)
                .padding(8)
                .background(OVTheme.smoke)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: .now)
    }
}

struct CourseView_Previews: PreviewProvider {
    static var previews: some View {
        CourseView(store: SoulJourneyStore())
    }
}
