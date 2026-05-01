import SwiftUI
import UIKit

struct LessonLibraryView: View {
    @ObservedObject var store: SoulJourneyStore
    @ObservedObject var accessManager: SubscriptionAccessManager

    private var studyFolders: [WisdomCourse] {
        store.allCourses.filter { $0.id != store.yearCourse.id }
    }

    private var featuredCourse: WisdomCourse {
        store.course
    }

    private var yearCourse: WisdomCourse {
        store.yearCourse
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    featuredFolder
                    yearPathSpotlight
                    folderSection

                    if !accessManager.hasAccess {
                        premiumInviteCard
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("Lessons")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AppInfoButton()
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Bible school, one chapter at a time")
                .font(OVTheme.display(34))
                .foregroundStyle(OVTheme.midnight)

            Text("Read. Understand. Reflect. Apply. Every folder keeps the chapter flow, guided teaching, and next steps calm and easy to follow.")
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.76))

            HStack(spacing: 8) {
                lessonChip("Read")
                lessonChip("Reflect")
                lessonChip("Grow")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var yearPathSpotlight: some View {
        let course = yearCourse
        let currentLesson = store.currentLesson(in: course)
        let completed = store.completedLessonsCount(for: course)
        let total = store.lessons(for: course).count

        return NavigationLink {
            CourseLessonFolderView(store: store, accessManager: accessManager, course: course)
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bible School year path")
                            .font(OVTheme.body(11))
                            .foregroundStyle(OVTheme.gold)

                        Text("Bible in a Year")
                            .font(OVTheme.display(34))
                            .foregroundStyle(OVTheme.midnight)

                        Text("A guided year path through the full KJV Bible with clear monthly checkpoints, storyline clarity, and Bible School depth when you want it.")
                            .font(OVTheme.body(14))
                            .foregroundStyle(OVTheme.ink.opacity(0.74))
                    }

                    Spacer(minLength: 12)

                    VStack(spacing: 8) {
                        lessonStat(value: "\(total)", label: "months")
                        lessonStat(value: "\(completed)/\(total)", label: "complete")
                    }
                }

                HStack(spacing: 8) {
                    lessonChip("Full Bible")
                    lessonChip("Guided year")
                    lessonChip("Bible School")
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Open \(currentLesson.title)")
                            .font(OVTheme.heading(16))
                            .foregroundStyle(.white)

                        Text("Keep the whole-Bible storyline readable with one steady structure instead of losing your place halfway through.")
                            .font(OVTheme.body(12))
                            .foregroundStyle(.white.opacity(0.84))
                    }

                    Spacer()

                    Image(systemName: "arrow.right")
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(OVTheme.midnight)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .padding(22)
            .background(
                LinearGradient(
                    colors: [OVTheme.lemon.opacity(0.32), OVTheme.coral.opacity(0.15), .white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(OVTheme.gold.opacity(0.4), lineWidth: 1)
            )
            .shadow(color: OVTheme.lemon.opacity(0.22), radius: 18, y: 10)
        }
        .buttonStyle(.plain)
    }

    private var featuredFolder: some View {
        let course = featuredCourse
        let currentLesson = store.currentLesson(in: course)
        let completed = store.completedLessonsCount(for: course)
        let total = store.lessons(for: course).count

        return NavigationLink {
            CourseLessonFolderView(store: store, accessManager: accessManager, course: course)
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Launch folder")
                            .font(OVTheme.body(11))
                            .foregroundStyle(OVTheme.gold)

                        Text(course.title)
                            .font(OVTheme.display(34))
                            .foregroundStyle(OVTheme.midnight)

                        Text("Start with the cleanest launch book in the app and move chapter by chapter through practical obedience, wisdom, humility, and prayer.")
                            .font(OVTheme.body(14))
                            .foregroundStyle(OVTheme.ink.opacity(0.72))
                    }

                    Spacer(minLength: 12)

                    VStack(spacing: 8) {
                        lessonStat(value: "\(total)", label: "chapters")
                        lessonStat(value: "\(completed)/\(total)", label: "complete")
                    }
                }

                HStack(spacing: 8) {
                    lessonChip("Practical")
                    lessonChip("Fast start")
                    lessonChip("Best launch book")
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Continue \(currentLesson.studyReference)")
                            .font(OVTheme.heading(16))
                            .foregroundStyle(.white)

                        Text(accessManager.hasAccess ? "Open the full chapter flow with deeper teaching, history, Scripture links, and quests." : "Open the free reading and reflection flow first, with Bible School ready when you want guided depth.")
                            .font(OVTheme.body(12))
                            .foregroundStyle(.white.opacity(0.82))
                    }

                    Spacer()

                    Image(systemName: "arrow.right")
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(OVTheme.midnight)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .padding(22)
            .background(OVTheme.elevatedCard)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(OVTheme.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var folderSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Study folders")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text("Each folder keeps the overview, chapter flow, reflection, and Bible School depth for that path in one place.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))

            LazyVStack(spacing: 12) {
                ForEach(studyFolders) { course in
                    NavigationLink {
                        CourseLessonFolderView(store: store, accessManager: accessManager, course: course)
                    } label: {
                        folderCard(for: course)
                    }
                    .buttonStyle(.plain)
                }
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

    private func folderCard(for course: WisdomCourse) -> some View {
        let lessons = store.lessons(for: course)
        let completed = store.completedLessonsCount(for: course)
        let nextLesson = store.currentLesson(in: course)
        let accent = folderAccent(for: course)

        return HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(accent)
                    .frame(width: 58, height: 58)

                Image(systemName: folderIcon(for: course))
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(OVTheme.midnight)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(folderKind(for: course))
                        .font(OVTheme.body(10))
                        .foregroundStyle(OVTheme.gold)

                    Text("\(completed)/\(lessons.count) complete")
                        .font(OVTheme.body(10))
                        .foregroundStyle(OVTheme.ink.opacity(0.55))
                }

                Text(folderTitle(for: course))
                    .font(OVTheme.heading(22))
                    .foregroundStyle(OVTheme.midnight)

                Text(folderSubtitle(for: course))
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.72))

                HStack(spacing: 8) {
                    metaPill("\(lessons.count) lessons")
                    metaPill(accessManager.hasAccess ? "Bible School on" : "Study path + School")
                }

                HStack {
                    Text("Open folder")
                        .font(OVTheme.heading(14))
                        .foregroundStyle(OVTheme.midnight)

                    Spacer()

                    Text(nextLesson.studyReference)
                        .font(OVTheme.body(12))
                        .foregroundStyle(OVTheme.ink.opacity(0.62))

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

    private func folderTitle(for course: WisdomCourse) -> String {
        switch course.id {
        case store.course.id:
            return "James"
        case store.legacyCourse.id:
            return "Proverbs"
        case store.yearCourse.id:
            return "Bible in a Year"
        default:
            return course.title
        }
    }

    private func folderSubtitle(for course: WisdomCourse) -> String {
        switch course.id {
        case store.course.id:
            return "A five-chapter path through James with practical obedience, wisdom, humility, and prayer."
        case store.legacyCourse.id:
            return "A full thirty-one chapter Proverbs folder with daily wisdom, discernment, and Bible School depth."
        case store.yearCourse.id:
            return "A 12-month Bible School path that guides the full KJV Bible with anchor chapters, storyline clarity, and deeper context."
        default:
            return course.subtitle
        }
    }

    private func folderKind(for course: WisdomCourse) -> String {
        switch course.id {
        case store.course.id, store.legacyCourse.id:
            return "BOOK FOLDER"
        case store.yearCourse.id:
            return "YEAR PATH"
        default:
            return "STUDY FOLDER"
        }
    }

    private func folderIcon(for course: WisdomCourse) -> String {
        switch course.id {
        case store.course.id:
            return "folder.fill.badge.person.crop"
        case store.legacyCourse.id:
            return "folder.fill.badge.questionmark"
        case store.yearCourse.id:
            return "folder.fill.badge.clock"
        default:
            return "folder.fill"
        }
    }

    private func folderAccent(for course: WisdomCourse) -> Color {
        switch course.id {
        case store.course.id:
            return OVTheme.lemon.opacity(0.5)
        case store.legacyCourse.id:
            return OVTheme.sky.opacity(0.58)
        case store.yearCourse.id:
            return OVTheme.coral.opacity(0.26)
        default:
            return OVTheme.mint.opacity(0.72)
        }
    }

    private var premiumInviteCard: some View {
        NavigationLink {
            SubscriptionGateView(accessManager: accessManager)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Text("Bible School")
                    .font(OVTheme.heading(22))
                    .foregroundStyle(OVTheme.ink)

                Text("God's Word stays free. Bible School adds the full chapter-teaching deck, historical context, Scripture links, and chapter quests inside every folder.")
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.74))

                Text("20% of profits are used to help people in need.")
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.gold)

                HStack {
                    Text("See Bible School")
                        .font(OVTheme.heading(15))
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(OVTheme.midnight)
                .clipShape(Capsule())
            }
            .padding(22)
            .background(
                LinearGradient(
                    colors: [OVTheme.lemon.opacity(0.3), .white],
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

    private func metaPill(_ label: String) -> some View {
        Text(label)
            .font(OVTheme.body(11))
            .foregroundStyle(OVTheme.midnight)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(.white.opacity(0.95))
            .clipShape(Capsule())
    }

    private func lessonChip(_ label: String) -> some View {
        Text(label)
            .font(OVTheme.body(12))
            .foregroundStyle(OVTheme.midnight)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.white.opacity(0.92))
            .clipShape(Capsule())
    }

    private func lessonStat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(OVTheme.heading(18))
                .foregroundStyle(OVTheme.midnight)

            Text(label.uppercased())
                .font(OVTheme.body(10))
                .foregroundStyle(OVTheme.ink.opacity(0.55))
        }
        .frame(minWidth: 78)
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(.white.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct CourseLessonFolderView: View {
    @ObservedObject var store: SoulJourneyStore
    @ObservedObject var accessManager: SubscriptionAccessManager
    let course: WisdomCourse

    private var lessons: [WisdomLesson] {
        store.lessons(for: course)
    }

    private var currentLesson: WisdomLesson {
        store.currentLesson(in: course)
    }

    private var completedCount: Int {
        store.completedLessonsCount(for: course)
    }

    private var totalVerses: Int {
        lessons.reduce(0) { partial, lesson in
            partial + chapterVerseCount(for: lesson)
        }
    }

    private var isYearCourse: Bool {
        course.id == store.yearCourse.id
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                summaryCard
                chapterSection

                if !accessManager.hasAccess {
                    premiumInviteCard
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle(folderTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(folderKind)
                        .font(OVTheme.body(11))
                        .foregroundStyle(OVTheme.gold)

                    Text(folderTitle)
                        .font(OVTheme.display(32))
                        .foregroundStyle(OVTheme.midnight)

                    Text(folderSubtitle)
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.ink.opacity(0.72))
                }

                Spacer(minLength: 12)

                VStack(spacing: 8) {
                    lessonStat(value: "\(lessons.count)", label: "chapters")
                    lessonStat(value: "\(completedCount)/\(lessons.count)", label: "complete")
                }
            }

            HStack(spacing: 8) {
                metaPill(isYearCourse ? "\(lessons.count) guided months" : "\(totalVerses) verses")
                metaPill(accessManager.hasAccess ? "Bible School on" : "Study path + School")
                metaPill("\(store.passedQuestsCount(for: course)) quests passed")
            }

            NavigationLink {
                ChapterStudyView(
                    store: store,
                    lesson: currentLesson,
                    hasPremiumAccess: accessManager.hasAccess
                )
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.progress(for: currentLesson).lessonCompleted ? "Review \(currentLesson.studyReference)" : "Continue \(currentLesson.studyReference)")
                            .font(OVTheme.heading(16))
                            .foregroundStyle(.white)

                        Text(accessManager.hasAccess ? "Open the full Bible School lesson deck and chapter quest." : "Open the Studying the Bible deck and keep your chapter progress moving.")
                            .font(OVTheme.body(12))
                            .foregroundStyle(.white.opacity(0.82))
                    }

                    Spacer()

                    Image(systemName: "arrow.right")
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(OVTheme.midnight)
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

    private var chapterSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(isYearCourse ? "Monthly checkpoints" : "Chapter lessons")
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text(isYearCourse ? "Each month gives you an anchor chapter, a reading span, and Bible School guidance so the full-year path stays readable and clear." : "Every chapter in this folder stays together here, so the reading flow, reflection, and Bible School teaching all stay easy to scan.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))

            VStack(spacing: 12) {
                ForEach(lessons) { lesson in
                    lessonRow(for: lesson)
                }
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

    private var premiumInviteCard: some View {
        NavigationLink {
            SubscriptionGateView(accessManager: accessManager)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Text("Bible School")
                    .font(OVTheme.heading(22))
                    .foregroundStyle(OVTheme.ink)

                Text("God's Word stays free. Bible School adds detailed teaching, history, Scripture links, and chapter quests for every chapter in this folder.")
                    .font(OVTheme.body(14))
                    .foregroundStyle(OVTheme.ink.opacity(0.74))

                HStack {
                    Text("See Bible School")
                        .font(OVTheme.heading(15))
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(OVTheme.midnight)
                .clipShape(Capsule())
            }
            .padding(22)
            .background(
                LinearGradient(
                    colors: [OVTheme.sky.opacity(0.34), .white],
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

    @ViewBuilder
    private func lessonRow(for lesson: WisdomLesson) -> some View {
        let progress = store.progress(for: lesson)
        let unlocked = store.isLessonUnlocked(lesson)
        let isCurrent = currentLesson.id == lesson.id && !progress.lessonCompleted
        let guide = ChapterLessonGuide.guide(for: lesson)
        let isYearLesson = lesson.id.hasPrefix("bible-year-")

        let card = VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text((isYearLesson ? "MONTH \(lesson.order)" : lesson.studyReference.uppercased()))
                        .font(OVTheme.body(10))
                        .foregroundStyle(OVTheme.gold)

                    Text(guide?.libraryTitle ?? shortLessonTitle(for: lesson))
                        .font(OVTheme.heading(20))
                        .foregroundStyle(OVTheme.midnight)
                }

                Spacer()

                Text(statusLabel(for: progress, isCurrent: isCurrent, unlocked: unlocked))
                    .font(OVTheme.body(11))
                    .foregroundStyle(statusColor(for: progress, isCurrent: isCurrent, unlocked: unlocked))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(OVTheme.paper)
                    .clipShape(Capsule())
            }

            Text(guide?.libraryDetail ?? lesson.summary)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.74))
                .lineLimit(3)

            HStack(spacing: 8) {
                metaPill(isYearLesson ? "Anchor: \(lesson.studyReference)" : "\(chapterVerseCount(for: lesson)) verses")
                metaPill(accessManager.hasAccess ? "7-slide school" : "3-slide study")
                if progress.quizPassed {
                    metaPill("Quest passed")
                }
            }

            HStack {
                Text(unlocked ? (progress.lessonCompleted ? "Review lesson" : "Open lesson") : (isYearLesson ? "Finish the previous month first" : "Finish the previous chapter first"))
                    .font(OVTheme.heading(14))
                    .foregroundStyle(unlocked ? OVTheme.midnight : OVTheme.ink.opacity(0.48))

                Spacer()

                Image(systemName: unlocked ? "arrow.right" : "lock")
                    .foregroundStyle(unlocked ? OVTheme.midnight : OVTheme.ink.opacity(0.48))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(unlocked ? OVTheme.paper.opacity(0.96) : OVTheme.smoke.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isCurrent ? OVTheme.midnight.opacity(0.16) : OVTheme.line, lineWidth: 1)
        )

        if unlocked {
            NavigationLink {
                ChapterStudyView(
                    store: store,
                    lesson: lesson,
                    hasPremiumAccess: accessManager.hasAccess
                )
            } label: {
                card
            }
            .buttonStyle(.plain)
        } else {
            card
                .opacity(0.78)
        }
    }

    private var folderTitle: String {
        switch course.id {
        case store.course.id:
            return "James"
        case store.legacyCourse.id:
            return "Proverbs"
        case store.yearCourse.id:
            return "Bible in a Year"
        default:
            return course.title
        }
    }

    private var folderSubtitle: String {
        switch course.id {
        case store.course.id:
            return "A five-chapter Bible-school folder through James with wisdom, obedience, humility, and steady faith."
        case store.legacyCourse.id:
            return "A thirty-one chapter Bible School folder through Proverbs with wise speech, integrity, humility, justice, and fear of the Lord."
        case store.yearCourse.id:
            return "A premium 12-month path through the full KJV Bible with anchor chapters, storyline guidance, and deeper Bible School teaching."
        default:
            return course.subtitle
        }
    }

    private var folderKind: String {
        switch course.id {
        case store.course.id, store.legacyCourse.id:
            return "BOOK FOLDER"
        case store.yearCourse.id:
            return "YEAR PATH"
        default:
            return "STUDY FOLDER"
        }
    }

    private func shortLessonTitle(for lesson: WisdomLesson) -> String {
        guard let shortTitle = lesson.title.split(separator: ":").dropFirst().first else {
            return lesson.title
        }
        return shortTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func chapterVerseCount(for lesson: WisdomLesson) -> Int {
        guard let target = BibleDataProvider.resolveReference(from: lesson.studyReference) else {
            return 0
        }
        return BibleDataProvider.chapter(at: target.location)?.verseCount ?? 0
    }

    private func statusLabel(for progress: LessonProgress, isCurrent: Bool, unlocked: Bool) -> String {
        if progress.lessonCompleted { return "Completed" }
        if isCurrent { return "Next up" }
        if unlocked { return "Unlocked" }
        return "Locked"
    }

    private func statusColor(for progress: LessonProgress, isCurrent: Bool, unlocked: Bool) -> Color {
        if progress.lessonCompleted { return .green }
        if isCurrent { return OVTheme.midnight }
        if unlocked { return OVTheme.ink.opacity(0.66) }
        return OVTheme.ink.opacity(0.48)
    }

    private func metaPill(_ label: String) -> some View {
        Text(label)
            .font(OVTheme.body(11))
            .foregroundStyle(OVTheme.midnight)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(.white.opacity(0.95))
            .clipShape(Capsule())
    }

    private func lessonStat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(OVTheme.heading(18))
                .foregroundStyle(OVTheme.midnight)

            Text(label.uppercased())
                .font(OVTheme.body(10))
                .foregroundStyle(OVTheme.ink.opacity(0.55))
        }
        .frame(minWidth: 78)
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(.white.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct ChapterStudyView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var store: SoulJourneyStore
    let lesson: WisdomLesson
    let hasPremiumAccess: Bool

    @State private var step: Int
    @State private var reflectionDraft: ChapterReflectionDraft
    @State private var selectedHighlights: Set<String>
    @State private var feedbackMessage = ""
    @State private var feedbackIsError = false
    @State private var startQuest = false
    @State private var nextLessonToOpen: WisdomLesson?
    @State private var showChallengeShareSheet = false
    @State private var challengeShareURL: URL?
    @State private var challengeShareFallbackText = ""

    init(store: SoulJourneyStore, lesson: WisdomLesson, hasPremiumAccess: Bool) {
        self.store = store
        self.lesson = lesson
        self.hasPremiumAccess = hasPremiumAccess

        let phases = LessonDeckPhase.deck(hasPremiumAccess: hasPremiumAccess)
        let savedDraft = store.chapterReflectionDraft(for: lesson)
        let savedStep = store.lessonStudyStep(for: lesson)

        _step = State(initialValue: min(savedStep, max(0, phases.count - 1)))
        _reflectionDraft = State(initialValue: savedDraft)
        _selectedHighlights = State(initialValue: Set(savedDraft.highlightedVerses))
    }

    private var phases: [LessonDeckPhase] {
        LessonDeckPhase.deck(hasPremiumAccess: hasPremiumAccess)
    }

    private var currentPhase: LessonDeckPhase {
        phases[step]
    }

    private var referenceTarget: BibleReferenceTarget? {
        BibleDataProvider.resolveReference(from: lesson.studyReference)
    }

    private var chapter: BibleChapter? {
        referenceTarget.flatMap { BibleDataProvider.chapter(at: $0.location) }
    }

    private var lessonProgress: LessonProgress {
        store.progress(for: lesson)
    }

    private var chapterGuide: ChapterLessonGuide? {
        ChapterLessonGuide.guide(for: lesson)
    }

    private var sortedSelectedVerseReferences: [String] {
        Array(selectedHighlights).sorted { lhs, rhs in
            let left = BibleDataProvider.resolveReference(from: lhs)
            let right = BibleDataProvider.resolveReference(from: rhs)

            let leftBook = left.flatMap { BibleDataProvider.canonicalBookOrder.firstIndex(of: $0.location.book) } ?? .max
            let rightBook = right.flatMap { BibleDataProvider.canonicalBookOrder.firstIndex(of: $0.location.book) } ?? .max

            if leftBook != rightBook { return leftBook < rightBook }

            let leftChapter = left?.location.chapter ?? .max
            let rightChapter = right?.location.chapter ?? .max
            if leftChapter != rightChapter { return leftChapter < rightChapter }

            return (left?.verse ?? .max) < (right?.verse ?? .max)
        }
    }

    private var overviewHighlights: [String] {
        let guideHighlights = chapterGuide?.overviewHighlights ?? []
        if !guideHighlights.isEmpty {
            return guideHighlights
        }
        return Array(lesson.keyIdeas.prefix(3))
    }

    private var shareText: String {
        ChapterReflection(
            lessonID: lesson.id,
            lessonOrder: lesson.order,
            lessonTitle: lesson.title,
            highlightedVerses: Array(selectedHighlights).sorted(),
            stoodOut: reflectionDraft.stoodOut.trimmed,
            godMessage: reflectionDraft.godMessage.trimmed,
            application: reflectionDraft.application.trimmed,
            learned: reflectionDraft.learned.trimmed,
            questions: reflectionDraft.questions.trimmed
        )
        .shareText(reference: lesson.studyReference)
    }

    private var challengeVerseReference: String {
        sortedSelectedVerseReferences.first ?? lesson.keyVerses.first ?? lesson.studyReference
    }

    private var challengeVerseBody: String {
        verseText(for: challengeVerseReference) ?? lesson.summary
    }

    private var challengeTakeaway: String {
        [
            reflectionDraft.stoodOut.trimmed,
            reflectionDraft.godMessage.trimmed,
            reflectionDraft.application.trimmed,
            chapterGuide?.libraryDetail ?? "",
            lesson.summary
        ].first(where: { !$0.isEmpty }) ?? lesson.summary
    }

    private var challengeInviteTitle: String {
        "Join me in \(lesson.studyReference) today"
    }

    private var challengeShareItems: [Any] {
        if let challengeShareURL {
            return [challengeShareURL]
        }
        return [challengeShareFallbackText]
    }

    private var chapterMoments: [StudyMoment] {
        if let chapterGuide {
            return chapterGuide.chapterMoments
        }

        return lesson.keyIdeas.enumerated().map { index, idea in
            StudyMoment(
                label: "Movement \(index + 1)",
                title: "Core idea \(index + 1)",
                detail: idea
            )
        }
    }

    private var scriptureConnections: [StudyConnection] {
        if let chapterGuide {
            return chapterGuide.scriptureConnections
        }

        return lesson.keyVerses.map {
            StudyConnection(
                reference: $0,
                explanation: "Use this verse to compare how Scripture reinforces the chapter's central message."
            )
        }
    }

    private var practiceSteps: [String] {
        if let chapterGuide {
            return chapterGuide.practiceSteps
        }

        return [
            "Name the truth you do not want to lose this week.",
            "Connect one key verse to one real decision.",
            "Take one obedient step before the day ends."
        ]
    }

    private var primaryButtonTitle: String {
        switch currentPhase {
        case .reflection:
            if hasPremiumAccess {
                return lessonProgress.lessonCompleted ? "Update + continue" : "Save + continue"
            }
            return "Complete"
        case .practice:
            return "Open quest"
        default:
            return "Next slide"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                compactHeader
                phaseRail

                Group {
                    switch currentPhase {
                    case .overview:
                        overviewSlide
                    case .chapter:
                        chapterSlide
                    case .reflection:
                        reflectionSlide
                    case .teachingLens:
                        teachingLensSlide
                    case .scriptureConnections:
                        scriptureConnectionsSlide
                    case .historicalSetting:
                        historicalSettingSlide
                    case .practice:
                        practiceSlide
                    }
                }
                .id(currentPhase.id)
                .transition(.opacity.combined(with: .scale(scale: 0.98)))

                if !hasPremiumAccess {
                    premiumPreviewCard
                }

                footerButtons
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle(lesson.studyReference)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $startQuest) {
            QuestTakeView(store: store, lesson: lesson)
        }
        .navigationDestination(item: $nextLessonToOpen) { nextLesson in
            ChapterStudyView(
                store: store,
                lesson: nextLesson,
                hasPremiumAccess: hasPremiumAccess
            )
        }
        .sheet(isPresented: $showChallengeShareSheet) {
            LessonActivityShareSheet(activityItems: challengeShareItems)
        }
        .overlay(alignment: .top) {
            if !feedbackMessage.isEmpty {
                Text(feedbackMessage)
                    .font(OVTheme.body(13))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(feedbackIsError ? OVTheme.coral : OVTheme.midnight)
                    .clipShape(Capsule())
                    .padding(.top, 10)
            }
        }
        .animation(.spring(response: 0.36, dampingFraction: 0.88), value: step)
        .onChange(of: step) { _, newValue in
            store.saveLessonStudyStep(for: lesson, step: newValue)
        }
    }

    private var compactHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(hasPremiumAccess ? "Bible School" : "Studying the Bible")
                    .font(OVTheme.body(11))
                    .foregroundStyle(hasPremiumAccess ? OVTheme.gold : OVTheme.midnight)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(.white.opacity(0.92))
                    .clipShape(Capsule())

                Text("Slide \(step + 1) of \(phases.count)")
                    .font(OVTheme.body(11))
                    .foregroundStyle(OVTheme.ink.opacity(0.62))

                Spacer()

                if lessonProgress.lessonCompleted {
                    Text("Completed")
                        .font(OVTheme.body(11))
                        .foregroundStyle(.green)
                }
            }

            Text(lesson.studyReference)
                .font(OVTheme.display(34))
                .foregroundStyle(OVTheme.midnight)

            Text(lesson.summary)
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.74))
                .lineLimit(3)

            HStack(spacing: 8) {
                metaBadge("\(chapter?.verseCount ?? 0) verses")
                metaBadge(hasPremiumAccess ? "7-slide school flow" : "3-slide study flow")
                metaBadge("KJV")
            }
        }
    }

    private var phaseRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(phases.enumerated()), id: \.element.id) { index, phase in
                    Button {
                        step = index
                    } label: {
                        Text(phase.shortTitle)
                            .font(OVTheme.heading(13))
                            .lineLimit(1)
                        .foregroundStyle(step == index ? .white : OVTheme.midnight)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(step == index ? OVTheme.midnight : OVTheme.elevatedCard)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(step == index ? OVTheme.midnight : OVTheme.line, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 1)
        }
    }

    private var overviewSlide: some View {
        lessonCanvas {
            slideTitle(
                eyebrow: "Summary",
                title: "Chapter overview",
                detail: "Start with the shape of the chapter before you move into the text."
            )

            LessonSectionCard(title: "What this chapter is teaching") {
                VStack(alignment: .leading, spacing: 14) {
                    Text(lesson.summary)
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.ink.opacity(0.76))

                    ForEach(chapterMoments) { moment in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(moment.label)
                                .font(OVTheme.body(11))
                                .foregroundStyle(OVTheme.gold)

                            Text(moment.title)
                                .font(OVTheme.heading(15))
                                .foregroundStyle(OVTheme.midnight)

                            Text(moment.detail)
                                .font(OVTheme.body(13))
                                .foregroundStyle(OVTheme.ink.opacity(0.72))
                        }
                    }

                    Divider()
                        .overlay(OVTheme.line)

                    ForEach(overviewHighlights, id: \.self) { point in
                        bulletRow(point)
                    }
                }
            }
        }
    }

    private var chapterSlide: some View {
        lessonCanvas {
            slideTitle(
                eyebrow: "Full chapter",
                title: "Read the chapter",
                detail: "Tap verses that stand out. They will carry straight into reflection."
            )

            if let referenceTarget {
                NavigationLink {
                    BibleChapterReaderView(store: store, target: referenceTarget)
                } label: {
                    HStack(spacing: 6) {
                        Text("Open in Bible reader")
                            .font(OVTheme.heading(14))
                        Image(systemName: "arrow.up.right")
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

            LessonSectionCard(title: "Reading map") {
                VStack(spacing: 8) {
                    ForEach(chapterMoments) { moment in
                        HStack {
                            Text(moment.label)
                                .font(OVTheme.body(11))
                                .foregroundStyle(OVTheme.gold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(OVTheme.sand)
                                .clipShape(Capsule())

                            Text(moment.title)
                                .font(OVTheme.body(13))
                                .foregroundStyle(OVTheme.ink.opacity(0.76))

                            Spacer()
                        }
                    }
                }
            }

            if let chapter {
                LessonSectionCard(title: chapter.title) {
                    VStack(spacing: 0) {
                        ForEach(chapter.verses) { verse in
                            let reference = lessonVerseReference(for: verse)
                            let isSelected = selectedHighlights.contains(reference)

                            HStack(alignment: .top, spacing: 12) {
                                Text("\(verse.verse)")
                                    .font(OVTheme.heading(12))
                                    .foregroundStyle(isSelected ? OVTheme.midnight : OVTheme.gold)
                                    .frame(width: 24, alignment: .leading)

                                Text(verse.text)
                                    .font(OVTheme.body(15))
                                    .foregroundStyle(OVTheme.ink.opacity(0.84))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineSpacing(2)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(isSelected ? OVTheme.lemon.opacity(0.34) : .clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(isSelected ? OVTheme.gold.opacity(0.6) : .clear, lineWidth: 1)
                            )
                            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .onTapGesture {
                                toggleHighlight(reference)
                            }

                            if verse.verse != chapter.verses.last?.verse {
                                Divider()
                                    .overlay(OVTheme.line.opacity(0.7))
                                    .padding(.vertical, 4)
                            }
                        }
                    }
                }

                if !sortedSelectedVerseReferences.isEmpty {
                    Text("\(sortedSelectedVerseReferences.count) verse\(sortedSelectedVerseReferences.count == 1 ? "" : "s") selected for reflection")
                        .font(OVTheme.body(12))
                        .foregroundStyle(OVTheme.ink.opacity(0.62))
                }
            } else {
                LessonSectionCard(title: "Chapter unavailable") {
                    Text("The Bible lesson could not load this chapter. Open the Bible tab to verify the reference.")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.ink.opacity(0.74))
                }
            }
        }
    }

    private var reflectionSlide: some View {
        lessonCanvas {
            slideTitle(
                eyebrow: "Reflection",
                title: "Turn the chapter into something lived",
                detail: "The verses you selected during reading are carried here so reflection stays anchored in the text."
            )

            if sortedSelectedVerseReferences.isEmpty {
                LessonSectionCard(title: "Selected verses") {
                    Text("Tap verses in the chapter slide and they will appear here with their text.")
                        .font(OVTheme.body(13))
                        .foregroundStyle(OVTheme.ink.opacity(0.68))
                }
            } else {
                LessonSectionCard(title: "Selected verses") {
                    VStack(spacing: 10) {
                        ForEach(sortedSelectedVerseReferences, id: \.self) { reference in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(reference)
                                        .font(OVTheme.heading(14))
                                        .foregroundStyle(OVTheme.midnight)

                                    Spacer()

                                    Button {
                                        toggleHighlight(reference)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(OVTheme.ink.opacity(0.4))
                                    }
                                    .buttonStyle(.plain)
                                }

                                Text(verseText(for: reference) ?? "Verse text unavailable.")
                                    .font(OVTheme.body(13))
                                    .foregroundStyle(OVTheme.ink.opacity(0.74))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(OVTheme.paper)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }
                }
            }

            LessonSectionCard(title: "Reflection notebook") {
                VStack(spacing: 12) {
                    reflectionField("What stood out to you?*", text: $reflectionDraft.stoodOut, minHeight: 84)
                    reflectionField("What do you think God is speaking here?*", text: $reflectionDraft.godMessage, minHeight: 92)
                    reflectionField("How will you apply this chapter to your life?*", text: $reflectionDraft.application, minHeight: 92)
                    reflectionField("What did you learn?", text: $reflectionDraft.learned, minHeight: 76)
                    reflectionField("What questions do you have?", text: $reflectionDraft.questions, minHeight: 76)
                }
            }

            LessonSectionCard(title: "Community") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Share your chapter challenge with one selected verse and one takeaway, then keep the conversation going in Discord.")
                        .font(OVTheme.body(13))
                        .foregroundStyle(OVTheme.ink.opacity(0.72))

                    VStack(alignment: .leading, spacing: 8) {
                        Text(challengeInviteTitle)
                            .font(OVTheme.heading(15))
                            .foregroundStyle(OVTheme.midnight)

                        Text("\(challengeVerseReference) • \(challengeTakeaway)")
                            .font(OVTheme.body(13))
                            .foregroundStyle(OVTheme.ink.opacity(0.72))
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(OVTheme.paper)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    HStack(spacing: 10) {
                        Button {
                            UIPasteboard.general.string = shareText
                            showFeedback("Reflection copied for Discord")
                        } label: {
                            Text("Copy")
                                .font(OVTheme.heading(14))
                                .foregroundStyle(OVTheme.midnight)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(OVTheme.sand)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)

                        Button {
                            Task { @MainActor in
                                shareChapterChallenge()
                            }
                        } label: {
                            Text("Share challenge")
                                .font(OVTheme.heading(14))
                                .foregroundStyle(OVTheme.midnight)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 999, style: .continuous)
                                        .stroke(OVTheme.line, lineWidth: 1)
                                )
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }

                    if let discordURL = URL(string: "https://discord.gg/W7M4zGPtqV") {
                        Link(destination: discordURL) {
                            Text("Open Discord")
                                .font(OVTheme.body(13))
                                .foregroundStyle(OVTheme.midnight)
                        }
                    }
                }
            }
        }
    }

    private var teachingLensSlide: some View {
        lessonCanvas {
            slideTitle(
                eyebrow: "Guided depth",
                title: "How \(lesson.studyReference) teaches the chapter",
                detail: "This Bible School pass slows the chapter down like a teacher would and explains what each movement is doing."
            )

            ForEach(teachingLensSections, id: \.title) { section in
                LessonSectionCard(title: section.title) {
                    Text(section.detail)
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.ink.opacity(0.76))
                }
            }
        }
    }

    private var scriptureConnectionsSlide: some View {
        lessonCanvas {
            slideTitle(
                eyebrow: "Scripture links",
                title: "Scripture interpreting Scripture",
                detail: "These verses deepen the chapter by showing how the same themes appear across the Bible."
            )

            ForEach(scriptureConnections) { connection in
                LessonSectionCard(title: connection.reference) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(verseText(for: connection.reference) ?? "Verse text unavailable in the current lookup.")
                            .font(OVTheme.body(14))
                            .foregroundStyle(OVTheme.midnight)
                            .textSelection(.enabled)

                        Text(connection.explanation)
                            .font(OVTheme.body(13))
                            .foregroundStyle(OVTheme.ink.opacity(0.72))
                    }
                }
            }
        }
    }

    private var historicalSettingSlide: some View {
        lessonCanvas {
            slideTitle(
                eyebrow: "History",
                title: "Historical setting",
                detail: "This gives the pressure, audience, and pastoral setting behind \(lesson.studyReference) so the chapter lands more clearly."
            )

            LessonSectionCard(title: "Setting") {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        ForEach(historyTags, id: \.self) { tag in
                            metaBadge(tag)
                        }
                    }

                    Text(historyText)
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.ink.opacity(0.76))
                }
            }

            LessonSectionCard(title: "Why that matters for reading the chapter") {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(historyTakeaways, id: \.self) { point in
                        bulletRow(point)
                    }
                }
            }
        }
    }

    private var practiceSlide: some View {
        lessonCanvas {
            slideTitle(
                eyebrow: "Practice",
                title: "Take \(lesson.studyReference) into the week",
                detail: "The lesson should end with a clear next step, then move naturally into the Bible School quest."
            )

            LessonSectionCard(title: "This week's action plan") {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(practiceSteps, id: \.self) { step in
                        bulletRow(step)
                    }
                }
            }

            LessonSectionCard(title: "Bible School quest") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("The Bible School quest checks whether you understood the chapter's meaning, historical setting, and practical movement well enough to explain it clearly.")
                        .font(OVTheme.body(14))
                        .foregroundStyle(OVTheme.ink.opacity(0.74))

                    Text("Passing score: \(lesson.quest.passingScore)%")
                        .font(OVTheme.heading(14))
                        .foregroundStyle(OVTheme.midnight)
                }
            }
        }
    }

    private var premiumPreviewCard: some View {
        LessonSectionCard(title: "Bible School adds four more teaching sections") {
            VStack(alignment: .leading, spacing: 10) {
                ForEach([
                    "Guided depth that breaks the chapter into teacher-style sections.",
                    "Scripture connections that explain why related verses matter.",
                    "Historical setting that gives the chapter context without becoming heavy.",
                    "A final practice pass that keeps the lesson actionable."
                ], id: \.self) { point in
                    bulletRow(point)
                }
            }
        }
    }

    private var footerButtons: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button {
                    guard step > 0 else { return }
                    step -= 1
                } label: {
                    Text("Previous")
                        .font(OVTheme.heading(15))
                        .foregroundStyle(OVTheme.midnight)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.white.opacity(0.98))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(step == 0)
                .opacity(step == 0 ? 0.35 : 1)

                Button {
                    handlePrimaryAction()
                } label: {
                    Text(primaryButtonTitle)
                        .font(OVTheme.heading(15))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(OVTheme.midnight)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            if currentPhase == .reflection {
                Text("The first three reflection prompts are required before the chapter can be completed.")
                    .font(OVTheme.body(12))
                    .foregroundStyle(OVTheme.ink.opacity(0.62))
            }
        }
    }

    private func handlePrimaryAction() {
        switch currentPhase {
        case .reflection:
            if hasPremiumAccess {
                if saveReflection(markComplete: false), step < phases.count - 1 {
                    step += 1
                }
            } else {
                if saveReflection(markComplete: true) {
                    openNextFreeLesson()
                }
            }
        case .practice:
            if saveReflection(markComplete: true) {
                startQuest = true
            }
        default:
            guard step < phases.count - 1 else { return }
            step += 1
        }
    }

    private func reflectionField(_ title: String, text: Binding<String>, minHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.76))

            TextEditor(text: text)
                .font(OVTheme.body(14))
                .frame(minHeight: minHeight)
                .padding(8)
                .background(OVTheme.smoke)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private func toggleHighlight(_ verse: String) {
        if selectedHighlights.contains(verse) {
            selectedHighlights.remove(verse)
        } else {
            selectedHighlights.insert(verse)
        }
        reflectionDraft.highlightedVerses = Array(selectedHighlights).sorted()
    }

    @discardableResult
    private func saveReflection(markComplete: Bool) -> Bool {
        reflectionDraft.highlightedVerses = Array(selectedHighlights).sorted()
        let result = store.saveChapterReflection(for: lesson, draft: reflectionDraft)

        guard result.saved else {
            showFeedback("Fill the first three reflection prompts first", isError: true)
            return false
        }

        if markComplete {
            store.markLessonCompleted(lesson)
        }

        showFeedback(result.pointsEarned > 0 ? "Reflection saved" : "Reflection updated")
        return true
    }

    private func openNextFreeLesson() {
        if let nextLesson = store.nextLesson(after: lesson) {
            nextLessonToOpen = nextLesson
        } else {
            dismiss()
        }
    }

    private func showFeedback(_ message: String, isError: Bool = false) {
        feedbackMessage = message
        feedbackIsError = isError

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            if feedbackMessage == message {
                feedbackMessage = ""
                feedbackIsError = false
            }
        }
    }

    @MainActor
    private func shareChapterChallenge() {
        challengeShareFallbackText = """
        \(challengeInviteTitle)

        \(challengeVerseReference)
        \(challengeVerseBody)

        My takeaway:
        \(challengeTakeaway)

        Read \(lesson.studyReference) in One Visioon and post your reflection when you finish.
        """

        let renderer = ImageRenderer(
            content: ChapterChallengeShareGraphic(
                chapterReference: lesson.studyReference,
                verseReference: challengeVerseReference,
                verseText: challengeVerseBody,
                takeaway: challengeTakeaway
            )
            .frame(width: 360, height: 560)
        )
        renderer.scale = 3

        guard let image = renderer.uiImage, let data = image.pngData() else {
            challengeShareURL = nil
            showChallengeShareSheet = true
            return
        }

        let filename = [
            "onevisioon-chapter-challenge",
            lesson.studyReference
                .lowercased()
                .replacingOccurrences(of: " ", with: "-")
                .replacingOccurrences(of: ":", with: "-")
        ].joined(separator: "-") + ".png"

        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        do {
            try data.write(to: url, options: .atomic)
            challengeShareURL = url
        } catch {
            challengeShareURL = nil
        }

        showChallengeShareSheet = true
    }

    private func verseText(for reference: String) -> String? {
        guard let target = BibleDataProvider.resolveReference(from: reference),
              let chapter = BibleDataProvider.chapter(at: target.location),
              let verseNumber = target.verse,
              let verse = chapter.verses.first(where: { $0.verse == verseNumber }) else {
            return nil
        }

        return verse.text
    }

    private func lessonVerseReference(for verse: BibleVerse) -> String {
        if let location = referenceTarget?.location {
            return "\(location.book) \(location.chapter):\(verse.verse)"
        }

        return "\(lesson.studyReference):\(verse.verse)"
    }

    private var teachingLensSections: [(title: String, detail: String)] {
        if let chapterGuide {
            return chapterGuide.teachingLensSections
        }

        return lesson.keyIdeas.enumerated().map { index, idea in
            ("Focus \(index + 1)", idea)
        }
    }

    private var historyTags: [String] {
        chapterGuide?.historyTags ?? ["Biblical setting", "Pastoral context", "Practical letter"]
    }

    private var historyText: String {
        if let chapterGuide {
            return chapterGuide.historyText
        }

        return "This chapter sits inside a larger biblical context that shapes how its commands, warnings, and promises should be heard."
    }

    private var historyTakeaways: [String] {
        if let chapterGuide {
            return chapterGuide.historyTakeaways
        }

        return [
            "Read the chapter as part of a real historical situation, not as detached sayings."
        ]
    }

    @ViewBuilder
    private func lessonCanvas<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            content()
        }
    }

    private func slideTitle(eyebrow: String, title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(eyebrow.uppercased())
                .font(OVTheme.body(11))
                .foregroundStyle(OVTheme.gold)

            Text(title)
                .font(OVTheme.heading(22))
                .foregroundStyle(OVTheme.ink)

            Text(detail)
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.72))
        }
    }

    private func metaBadge(_ label: String) -> some View {
        Text(label)
            .font(OVTheme.body(11))
            .foregroundStyle(OVTheme.midnight)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(.white.opacity(0.92))
            .clipShape(Capsule())
    }

    private func bulletRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(OVTheme.midnight)
                .frame(width: 6, height: 6)
                .padding(.top, 6)

            Text(text)
                .font(OVTheme.body(13))
                .foregroundStyle(OVTheme.ink.opacity(0.74))
        }
    }
}

private struct LessonSectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(OVTheme.heading(16))
                .foregroundStyle(OVTheme.midnight)

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(OVTheme.paper.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(OVTheme.line.opacity(0.85), lineWidth: 1)
        )
    }
}

private struct StudyMoment: Identifiable {
    let label: String
    let title: String
    let detail: String

    var id: String { "\(label)-\(title)" }
}

private struct StudyConnection: Identifiable {
    let reference: String
    let explanation: String

    var id: String { reference }
}

private typealias ChapterLessonGuide = JamesLessonGuide

private struct JamesLessonGuide {
    let reference: String
    let libraryTitle: String
    let libraryDetail: String
    let overviewHighlights: [String]
    let chapterMoments: [StudyMoment]
    let scriptureConnections: [StudyConnection]
    let teachingLensSections: [(title: String, detail: String)]
    let historyTags: [String]
    let historyText: String
    let historyTakeaways: [String]
    let practiceSteps: [String]

    static func guide(for reference: String) -> JamesLessonGuide? {
        guides[reference]
    }

    static func guide(for lesson: WisdomLesson) -> JamesLessonGuide? {
        if let guide = guides[lesson.studyReference] {
            return guide
        }

        if lesson.studyReference.hasPrefix("Proverbs ") {
            return proverbsGuide(for: lesson)
        }

        if lesson.id.hasPrefix("bible-year-") {
            return bibleYearGuide(for: lesson)
        }

        return nil
    }

    private static let guides: [String: JamesLessonGuide] = [
        "James 1": JamesLessonGuide(
            reference: "James 1",
            libraryTitle: "Wisdom in Trials",
            libraryDetail: "Ask God for wisdom, endure pressure faithfully, and become a doer of the Word.",
            overviewHighlights: [
                "Wisdom is needed most when life feels unstable and faith is under pressure.",
                "James exposes temptation and divided motives instead of leaving discipleship vague.",
                "The chapter moves toward obedience, mercy, and restrained speech, not mere agreement."
            ],
            chapterMoments: [
                StudyMoment(
                    label: "Verses 1-8",
                    title: "Pressure exposes what faith is leaning on",
                    detail: "James opens with trials, endurance, and the need to ask God for wisdom without a divided heart."
                ),
                StudyMoment(
                    label: "Verses 9-18",
                    title: "Temptation grows from desire, not from God",
                    detail: "The chapter confronts blame-shifting and shows God's character as steady, generous, and good."
                ),
                StudyMoment(
                    label: "Verses 19-27",
                    title: "Real maturity obeys what it hears",
                    detail: "James closes by redefining spiritual seriousness as bridled speech, mercy, and doing the Word."
                )
            ],
            scriptureConnections: [
                StudyConnection(
                    reference: "Proverbs 3:5-6",
                    explanation: "James pushes the reader away from self-reliance and back into trusting God for direction."
                ),
                StudyConnection(
                    reference: "Matthew 7:24",
                    explanation: "Jesus and James agree that hearing is incomplete until obedience becomes visible."
                ),
                StudyConnection(
                    reference: "Romans 12:2",
                    explanation: "A renewed mind discerns God's will instead of reacting only from pressure or impulse."
                ),
                StudyConnection(
                    reference: "1 Peter 1:6-7",
                    explanation: "Trials refine faith rather than proving God has stepped away."
                )
            ],
            teachingLensSections: [
                (
                    title: "1. Trials expose the condition of faith",
                    detail: "James does not romanticize pain. He treats trials as moments that expose whether faith is sturdy enough to endure without collapsing into panic, resentment, or divided loyalty. The command to count it joy is not a command to enjoy pain, but to recognize that God can produce maturity through it."
                ),
                (
                    title: "2. Wisdom is guidance for endurance",
                    detail: "When James says to ask God for wisdom, he is not talking about spiritual trivia or hidden information. He is talking about the God-given clarity needed to remain faithful under strain, to judge a situation rightly, and to respond without double-mindedness."
                ),
                (
                    title: "3. James refuses to blame God for temptation",
                    detail: "The middle of the chapter is morally searching. James traces temptation inward toward desire, which means mature discipleship includes honest self-examination. The chapter will not let the reader stay vague, passive, or self-excusing."
                ),
                (
                    title: "4. The chapter ends with obedience, not mood",
                    detail: "James will not measure maturity by hearing, language, or private agreement alone. The closing movement drives toward action, mercy, restraint, and visible obedience. In James 1, the mature listener becomes a doer."
                )
            ],
            historyTags: ["Early church", "Scattered believers", "Endurance letter"],
            historyText: "James is commonly understood as an early New Testament letter written to Jewish Christians scattered beyond Jerusalem. That means the audience is living with pressure, instability, and social strain. The chapter is pastoral more than abstract. James is writing to believers who need endurance, clarity, and obedience in ordinary life, not a polished theological system detached from hardship.",
            historyTakeaways: [
                "The scattered audience helps explain why trials, endurance, poverty, speech, and practical obedience all sit close together.",
                "James sounds urgent because he is shepherding people under real pressure, not writing a detached classroom essay.",
                "This setting makes the chapter's call to ask God for wisdom feel intensely practical, not decorative."
            ],
            practiceSteps: [
                "Ask God directly for wisdom before your next hard conversation or decision.",
                "Name one pressure point where you are tempted to react instead of endure faithfully.",
                "Choose one concrete act of obedience today so the chapter becomes practiced, not admired."
            ]
        ),
        "James 2": JamesLessonGuide(
            reference: "James 2",
            libraryTitle: "Faith That Works",
            libraryDetail: "Reject favoritism, love your neighbor, and see how living faith becomes visible in action.",
            overviewHighlights: [
                "James rebukes favoritism because gospel-shaped churches do not measure people by wealth or status.",
                "The royal law of love turns partiality into a serious contradiction, not a small social flaw.",
                "Living faith becomes visible through action, mercy, and costly obedience."
            ],
            chapterMoments: [
                StudyMoment(
                    label: "Verses 1-13",
                    title: "The gathered church must not rank people by status",
                    detail: "James uses the scene of rich and poor visitors to expose how quickly community can drift into worldly honor systems."
                ),
                StudyMoment(
                    label: "Verses 14-20",
                    title: "Empty profession is not living faith",
                    detail: "James presses the reader to see that verbal faith without visible obedience is dead and unable to help."
                ),
                StudyMoment(
                    label: "Verses 21-26",
                    title: "Abraham and Rahab prove faith acts",
                    detail: "The chapter closes by showing that genuine trust in God becomes concrete through costly action."
                )
            ],
            scriptureConnections: [
                StudyConnection(
                    reference: "Leviticus 19:18",
                    explanation: "James calls the command to love your neighbor the royal law because partiality violates this basic covenant demand."
                ),
                StudyConnection(
                    reference: "Matthew 22:39",
                    explanation: "Jesus and James both place love of neighbor near the center of faithful obedience."
                ),
                StudyConnection(
                    reference: "Ephesians 2:8-10",
                    explanation: "Paul and James are not enemies here. Grace saves, and the saved are created for good works."
                ),
                StudyConnection(
                    reference: "Micah 6:8",
                    explanation: "James 2 fits a larger biblical pattern where real faith shows up in justice, mercy, and humble obedience."
                )
            ],
            teachingLensSections: [
                (
                    title: "1. Partiality is a gospel failure",
                    detail: "James does not treat favoritism as bad manners. He treats it as a church-level betrayal of the faith because it imports worldly honor codes into the assembly and dishonors the poor whom God has not overlooked."
                ),
                (
                    title: "2. The royal law makes love measurable",
                    detail: "By centering love of neighbor, James turns the chapter away from vague spirituality. The issue is not whether believers can explain love, but whether they actually practice it when class, comfort, and convenience are involved."
                ),
                (
                    title: "3. Dead faith is verbal faith without embodiment",
                    detail: "James is not attacking grace. He is attacking hollow profession. The chapter refuses to accept a form of faith that says the right things while refusing costly obedience."
                ),
                (
                    title: "4. Abraham and Rahab widen the application",
                    detail: "James chooses two very different figures to show that living faith acts across backgrounds, statuses, and situations. The point is not similarity of biography, but the visibility of trust."
                )
            ],
            historyTags: ["House churches", "Rich and poor", "Mercy and works"],
            historyText: "James 2 likely reflects early Christian gatherings where rich and poor believers met in the same assemblies while living in a world deeply shaped by wealth, patronage, and honor. In that setting, giving special treatment to the wealthy would have felt normal socially, which is exactly why James attacks it so sharply. The chapter is forcing the church to become a visibly different kind of community.",
            historyTakeaways: [
                "The rich-and-poor assembly scene is not random. It reflects real social pressures inside early Christian gatherings.",
                "James treats favoritism as a theological issue because status systems can reshape church life before people notice it.",
                "The historical setting makes the chapter's stress on mercy and visible faith far more concrete."
            ],
            practiceSteps: [
                "Notice where you instinctively assign more value to people with more status, influence, or polish.",
                "Choose one act of practical mercy that costs you convenience this week.",
                "Ask whether your faith is mostly spoken or increasingly visible in action."
            ]
        ),
        "James 3": JamesLessonGuide(
            reference: "James 3",
            libraryTitle: "Wisdom From Above",
            libraryDetail: "Let speech, motives, and relationships reveal whether earthly or heavenly wisdom is shaping you.",
            overviewHighlights: [
                "James treats speech as a spiritual diagnostic tool because words reveal the heart and shape community.",
                "Earthly wisdom can look strategic and strong while actually feeding rivalry and disorder.",
                "Wisdom from above is morally pure, relationally peaceable, teachable, and full of mercy."
            ],
            chapterMoments: [
                StudyMoment(
                    label: "Verses 1-4",
                    title: "Teachers and words carry real weight",
                    detail: "James opens by warning that speech and influence are serious because they can direct entire lives."
                ),
                StudyMoment(
                    label: "Verses 5-12",
                    title: "The tongue reveals and can ruin",
                    detail: "Through vivid images, James shows how small speech can direct, stain, inflame, and contradict worship."
                ),
                StudyMoment(
                    label: "Verses 13-18",
                    title: "Two kinds of wisdom produce two kinds of communities",
                    detail: "The chapter ends by distinguishing selfish, disorder-producing wisdom from the gentle, peaceable wisdom from above."
                )
            ],
            scriptureConnections: [
                StudyConnection(
                    reference: "Proverbs 15:1",
                    explanation: "James stands inside a long biblical tradition that treats speech as spiritually formative and relationally powerful."
                ),
                StudyConnection(
                    reference: "Matthew 12:34",
                    explanation: "Jesus and James both connect words to the heart rather than treating speech as accidental overflow."
                ),
                StudyConnection(
                    reference: "Galatians 5:22-23",
                    explanation: "The fruit of the Spirit helps explain why wisdom from above is marked by gentleness, peace, and self-control."
                ),
                StudyConnection(
                    reference: "Colossians 4:6",
                    explanation: "James 3 is not only a warning chapter. It also prepares believers to speak with grace and wisdom."
                )
            ],
            teachingLensSections: [
                (
                    title: "1. James begins with teachers because influence matters",
                    detail: "The opening warning about teachers is not a random aside. James begins there because the chapter is about the moral and communal power of speech. Words direct people, and teachers multiply that power."
                ),
                (
                    title: "2. Speech is a diagnostic tool for the heart",
                    detail: "The tongue is small, but James refuses to call it insignificant. Speech reveals the inner life, and that means a believer's words can expose whether the heart is being governed by peace, pride, bitterness, or ambition."
                ),
                (
                    title: "3. Earthly wisdom is exposed by its fruit",
                    detail: "James dismantles any version of wisdom that looks impressive but leaves jealousy, rivalry, and confusion in its wake. If the fruit is disorder, the wisdom is not from above."
                ),
                (
                    title: "4. Heavenly wisdom is relationally recognizable",
                    detail: "James 3:17 is concrete. Wisdom from above is not mystical branding. It is recognizable in purity, peace, gentleness, teachability, mercy, and sincerity."
                )
            ],
            historyTags: ["Teachers", "Speech ethics", "Community peace"],
            historyText: "In the early church, teaching carried visible influence, and scattered congregations depended heavily on spoken instruction. That helps explain why James treats teachers, speech, and communal peace as tightly connected. He is addressing communities where careless words, prideful leadership, and rivalry could damage real people quickly.",
            historyTakeaways: [
                "James 3 is not abstract advice about words. It is pastoral care for communities shaped by speech and leadership.",
                "The teacher warning makes sense because public words carried real authority in early Christian gatherings.",
                "The chapter's contrast between two wisdoms is really a contrast between two kinds of communal fruit."
            ],
            practiceSteps: [
                "Listen to your speech for one day as a window into the condition of your heart.",
                "Name one conversation where gentleness and teachability would look more like wisdom from above.",
                "Refuse one rivalry-producing response and replace it with a peace-making one."
            ]
        ),
        "James 4": JamesLessonGuide(
            reference: "James 4",
            libraryTitle: "Humble Yourself",
            libraryDetail: "Trace conflict back to rival desires, resist worldly loyalties, and hold your plans under God's will.",
            overviewHighlights: [
                "James locates conflict inside disordered desires before he addresses it outside in behavior.",
                "Friendship with the world means divided loyalty, not merely outward worldliness.",
                "Humility before God changes prayer, repentance, judgment of others, and planning for the future."
            ],
            chapterMoments: [
                StudyMoment(
                    label: "Verses 1-10",
                    title: "Conflict grows from rival desires and proud resistance",
                    detail: "James diagnoses fights at the heart level, then calls believers to humble repentance and renewed nearness to God."
                ),
                StudyMoment(
                    label: "Verses 11-12",
                    title: "Pride also shows up in judging others",
                    detail: "The chapter narrows from conflict in general to the presumption of speaking against a brother."
                ),
                StudyMoment(
                    label: "Verses 13-17",
                    title: "Even planning can become boastful independence",
                    detail: "James ends by exposing the illusion of control and calling believers to plan in conscious dependence on the Lord."
                )
            ],
            scriptureConnections: [
                StudyConnection(
                    reference: "1 John 2:15-17",
                    explanation: "James and John both warn that worldliness is about rival loves and loyalties, not merely public image."
                ),
                StudyConnection(
                    reference: "Proverbs 27:1",
                    explanation: "Boasting about tomorrow is a long-standing biblical mark of human presumption."
                ),
                StudyConnection(
                    reference: "1 Peter 5:5-6",
                    explanation: "James and Peter both frame humility before God as the path to grace rather than self-exalting resistance."
                ),
                StudyConnection(
                    reference: "Jeremiah 17:9",
                    explanation: "James's diagnosis of inner conflict fits the larger biblical pattern of the heart needing searching and repentance."
                )
            ],
            teachingLensSections: [
                (
                    title: "1. James traces public conflict back into the heart",
                    detail: "James 4 does not begin with strategy for better arguments. It begins by asking what desires are driving the quarrels. That makes the chapter spiritually invasive in the best sense: it refuses surface-level diagnosis."
                ),
                (
                    title: "2. Worldliness is a loyalty problem",
                    detail: "Friendship with the world is not mainly aesthetic. It is about rival allegiance. James is exposing desires, ambitions, and values that want to sit on the throne instead of God."
                ),
                (
                    title: "3. Humility reshapes prayer and repentance",
                    detail: "James moves quickly from diagnosis to response: submit, resist, draw near, cleanse, humble yourselves. The chapter is not content to expose pride; it directs the reader toward repentance."
                ),
                (
                    title: "4. Even planning must pass through dependence",
                    detail: "The merchant example shows that pride can dress itself in competence and ambition. James is not condemning wise planning but exposing self-sufficient planning that forgets human fragility and divine rule."
                )
            ],
            historyTags: ["Rival desires", "Worldly friendship", "Dependent plans"],
            historyText: "James 4 reflects communities living in a world full of economic ambition, public rivalry, and unstable circumstances. In that setting, conflict, envy, and self-advancing plans would have felt normal. James confronts those patterns by calling believers to a radically God-centered humility that affects both relationships and future planning.",
            historyTakeaways: [
                "The chapter's strong language about worldliness makes more sense in a competitive, honor-shaped world.",
                "James is addressing believers who could easily baptize ambition, conflict, and self-advancing plans as normal life.",
                "The historical pressure behind the chapter sharpens its call to humble dependence on God."
            ],
            practiceSteps: [
                "Ask what desire is most shaping your current tension or disappointment.",
                "Repent one concrete form of pride instead of only feeling bad about it in general.",
                "Rewrite one future plan this week with explicit dependence on the Lord's will."
            ]
        ),
        "James 5": JamesLessonGuide(
            reference: "James 5",
            libraryTitle: "Patient Faith",
            libraryDetail: "Stand firm under injustice, practice prayerful endurance, and help restore those who drift.",
            overviewHighlights: [
                "James begins with a prophetic warning against wealth used unjustly and at the expense of others.",
                "Believers are called to patient endurance while waiting for the Lord rather than collapsing into bitterness.",
                "The chapter ends with a picture of church life shaped by prayer, confession, healing, and restoration."
            ],
            chapterMoments: [
                StudyMoment(
                    label: "Verses 1-6",
                    title: "Unjust wealth is exposed and judged",
                    detail: "James speaks like an Old Testament prophet, warning wealthy oppressors whose riches have been gathered by injustice."
                ),
                StudyMoment(
                    label: "Verses 7-12",
                    title: "Suffering believers are called to patient endurance",
                    detail: "The farmer, prophets, and Job show what steady faith looks like while waiting for the Lord's coming."
                ),
                StudyMoment(
                    label: "Verses 13-20",
                    title: "Prayer and restoration belong to ordinary church life",
                    detail: "James closes the letter with a community vision full of prayer, confession, care, and the pursuit of straying people."
                )
            ],
            scriptureConnections: [
                StudyConnection(
                    reference: "Amos 5:11-12",
                    explanation: "James's opening rebuke of unjust wealth sounds prophetic because it stands in continuity with Old Testament warnings against exploitation."
                ),
                StudyConnection(
                    reference: "Romans 12:12",
                    explanation: "Paul and James both call believers to patience in trouble and steadfastness in prayer."
                ),
                StudyConnection(
                    reference: "1 John 5:14",
                    explanation: "The confidence James shows in prayer fits a broader New Testament pattern of bold but God-dependent asking."
                ),
                StudyConnection(
                    reference: "Galatians 6:1",
                    explanation: "James's closing concern for restoring the wanderer matches the church's responsibility to pursue people gently back toward truth."
                )
            ],
            teachingLensSections: [
                (
                    title: "1. James begins with prophetic confrontation",
                    detail: "The opening section sounds like the prophets because James wants exploitation to be heard as a moral crisis before God, not just an unfortunate social pattern."
                ),
                (
                    title: "2. Endurance is a disciplined hope",
                    detail: "James does not tell suffering believers to deny pain. He teaches them to wait like a farmer, hold steady like the prophets, and see Job as proof that suffering does not have the final word."
                ),
                (
                    title: "3. Prayer is for the whole range of life",
                    detail: "James treats prayer as the normal response to suffering, sickness, joy, and sin. That means prayer is not a specialty practice for emergencies but a core rhythm of the believing community."
                ),
                (
                    title: "4. The letter ends with restoration, not isolation",
                    detail: "James closes by calling believers to pursue the one who wanders. The final note of the book is deeply pastoral: truth should move toward restoration."
                )
            ],
            historyTags: ["Prophetic warning", "Patient endurance", "Prayerful church"],
            historyText: "James 5 reflects the real social strain of early Christian life, where poor laborers could be mistreated, believers could suffer injustice, and churches had to learn how to endure without giving way to bitterness or passivity. That is why the chapter moves from prophetic denunciation to patient waiting to communal prayer and restoration.",
            historyTakeaways: [
                "The strong rebuke of the wealthy echoes the prophets because James is naming real injustice, not speaking in abstractions.",
                "Patient endurance is central because scattered believers were learning to live faithfully without quick relief.",
                "The closing vision of prayer and restoration shows how early churches were meant to carry one another through weakness and wandering."
            ],
            practiceSteps: [
                "Hold one unresolved burden before God with patient honesty instead of private resentment.",
                "Pray specifically for someone weak, suffering, or discouraged this week.",
                "If someone around you is drifting, move toward restoration rather than silent distance."
            ]
        )
    ]

    private struct ProverbsSectionDescriptor {
        let tags: [String]
        let historyText: String
        let takeaways: [String]
        let readingLens: String
    }

    private static func proverbsGuide(for lesson: WisdomLesson) -> JamesLessonGuide {
        let chapter = proverbsChapterNumber(from: lesson.studyReference)
        let title = shortTitle(from: lesson.title)
        let descriptor = proverbsDescriptor(for: chapter)
        let firstVerse = lesson.keyVerses[safe: 0] ?? "Proverbs \(chapter):1"
        let secondVerse = lesson.keyVerses[safe: 1] ?? firstVerse
        let thirdVerse = lesson.keyVerses[safe: 2] ?? secondVerse

        return JamesLessonGuide(
            reference: lesson.studyReference,
            libraryTitle: title,
            libraryDetail: lesson.summary,
            overviewHighlights: [
                "Proverbs \(chapter) trains everyday judgment, not just abstract agreement.",
                lesson.summary,
                descriptor.readingLens
            ],
            chapterMoments: proverbsMoments(for: chapter, title: title, summary: lesson.summary),
            scriptureConnections: [
                StudyConnection(
                    reference: firstVerse,
                    explanation: "This verse anchors one of the clearest wisdom lines in Proverbs \(chapter) and gives a stable entry point into the chapter."
                ),
                StudyConnection(
                    reference: secondVerse,
                    explanation: "This verse helps slow the chapter down so its warning or promise can be applied with discernment rather than rushed past."
                ),
                StudyConnection(
                    reference: thirdVerse,
                    explanation: "This verse helps connect the chapter's main idea to a concrete pattern of obedience in ordinary life."
                )
            ],
            teachingLensSections: [
                (
                    title: "1. What Proverbs \(chapter) is forming in the reader",
                    detail: "This chapter is not mainly asking to be admired. It is trying to shape judgment, instincts, and daily obedience. \(lesson.summary)"
                ),
                (
                    title: "2. How the chapter should be read",
                    detail: descriptor.readingLens
                ),
                (
                    title: "3. Where the warning or promise lands",
                    detail: "Proverbs \(chapter) keeps pressing wisdom into real life: speech, relationships, integrity, money, desire, diligence, correction, humility, or leadership. The chapter is meant to move from insight into practiced discernment."
                ),
                (
                    title: "4. What Bible School wants you to do with it",
                    detail: "Do not treat Proverbs \(chapter) like detached sayings. Trace the repeated theme, hold the key verses together, and then obey one part of the chapter concretely before the day ends."
                )
            ],
            historyTags: descriptor.tags,
            historyText: descriptor.historyText,
            historyTakeaways: descriptor.takeaways,
            practiceSteps: proverbsPracticeSteps(for: chapter, title: title)
        )
    }

    private static func proverbsChapterNumber(from reference: String) -> Int {
        Int(reference.replacingOccurrences(of: "Proverbs ", with: "")) ?? 1
    }

    private static func shortTitle(from lessonTitle: String) -> String {
        guard let shortTitle = lessonTitle.split(separator: ":").dropFirst().first else {
            return lessonTitle
        }
        return shortTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func proverbsDescriptor(for chapter: Int) -> ProverbsSectionDescriptor {
        switch chapter {
        case 1...9:
            return ProverbsSectionDescriptor(
                tags: ["Solomon", "Fatherly instruction", "Wisdom invitation"],
                historyText: "Proverbs 1-9 functions like an opening school of wisdom. These chapters are longer father-to-son discourses that frame the whole book before the short saying collections begin. They repeatedly present wisdom and folly as rival voices calling for allegiance, which means the reader is being formed before he or she is given rapid-fire sayings to apply.",
                takeaways: [
                    "Read the chapter as formative instruction, not as detached moral slogans.",
                    "The repeated appeals, warnings, and invitations are shaping loyalty before behavior.",
                    "This part of Proverbs slows the learner down so wisdom is received as a way of life."
                ],
                readingLens: "Read this chapter as a sustained call to choose wisdom's voice over rival desires, shortcuts, and seductions."
            )
        case 10...21:
            return ProverbsSectionDescriptor(
                tags: ["Solomonic sayings", "Daily discernment", "Character formation"],
                historyText: "From Proverbs 10 onward, the book shifts into shorter Solomonic sayings. The goal is not to provide one long argument but to train recognition: the righteous and the foolish speak, work, plan, and respond differently. The chapter should be read by watching themes collect and repeat until a pattern of godly judgment becomes visible.",
                takeaways: [
                    "Short sayings still work together to form a moral pattern.",
                    "The chapter should be read for repeated themes, not for one modern soundbite.",
                    "This section trains instinctive discernment in ordinary life."
                ],
                readingLens: "Read this chapter by noticing recurring contrasts in speech, work, pride, generosity, restraint, and integrity."
            )
        case 22...24:
            return ProverbsSectionDescriptor(
                tags: ["Wise sayings", "Instruction", "Moral counsel"],
                historyText: "Proverbs 22-24 sits in a transitional wisdom section where direct instruction and clustered sayings stand closer together. The material sounds more like a teacher pressing counsel into the learner than a random pile of disconnected sentences. That makes these chapters especially useful for seeing how wisdom speaks into training, self-control, justice, and preparation.",
                takeaways: [
                    "These chapters often feel more instructional than the rapid contrasts in the middle of Proverbs.",
                    "The flow invites slower reading so counsel and warning can stay connected.",
                    "The historical shape helps the reader listen for formation, not just information."
                ],
                readingLens: "Read this chapter slowly as wisdom instruction meant to coach judgment, self-control, and responsible living."
            )
        case 25...29:
            return ProverbsSectionDescriptor(
                tags: ["Hezekiah collection", "Leadership", "Measured judgment"],
                historyText: "Proverbs 25-29 is introduced as Solomonic material copied by the men of Hezekiah. That historical note matters because these chapters often lean into rulership, restraint, speech, justice, and social order. The sayings still serve ordinary believers, but they also sharpen the book's concern for leadership, public responsibility, and measured judgment.",
                takeaways: [
                    "The Hezekiah note reminds the reader that Proverbs was preserved and arranged with care.",
                    "Leadership and public responsibility stand closer to the surface in this section.",
                    "These chapters reward patient reading because wisdom is often tied to restraint, timing, and justice."
                ],
                readingLens: "Read this chapter with an eye for restraint, timing, leadership, justice, and the public consequences of private character."
            )
        case 30:
            return ProverbsSectionDescriptor(
                tags: ["Agur", "Humility", "Measured life"],
                historyText: "Proverbs 30 shifts to the words of Agur and sounds distinct from the surrounding Solomonic collections. The chapter is marked by humility about human limits, reverence for God's pure word, and wise observation about life. That different voice is part of the chapter's power: wisdom begins with knowing you are not self-sufficient.",
                takeaways: [
                    "Agur's humility is central, not ornamental.",
                    "The chapter teaches dependence on God's word rather than confidence in human mastery.",
                    "Its numerical sayings train close observation and measured living."
                ],
                readingLens: "Read this chapter through the lens of humility, dependence, and careful observation under God's authority."
            )
        case 31:
            return ProverbsSectionDescriptor(
                tags: ["Lemuel", "Royal counsel", "Noble character"],
                historyText: "Proverbs 31 begins with royal instruction associated with Lemuel and ends with the poem about the virtuous woman. Together they show wisdom in leadership, justice, disciplined strength, generosity, household faithfulness, and the fear of the Lord. The chapter is not sentimental closing material; it is a strong finish to the book's vision of godly character.",
                takeaways: [
                    "The chapter joins leadership counsel with a portrait of durable covenant character.",
                    "Fear of the Lord remains the center even when the focus turns to work, household, and public praise.",
                    "The ending of Proverbs shows that wisdom is meant to become embodied and visible."
                ],
                readingLens: "Read this chapter as a final portrait of wisdom embodied in leadership, justice, disciplined strength, and fear of the Lord."
            )
        default:
            return ProverbsSectionDescriptor(
                tags: ["Wisdom literature", "Discernment", "Obedience"],
                historyText: "This chapter belongs to the wisdom tradition of Proverbs, where God's truth is pressed into ordinary choices, speech, relationships, work, and judgment.",
                takeaways: [
                    "Proverbs should be read for patterns of godly living.",
                    "Wisdom is meant to become practiced, not merely admired.",
                    "Short sayings still form a coherent moral vision."
                ],
                readingLens: "Read this chapter by tracing its repeated wisdom themes and turning them into one concrete act of obedience."
            )
        }
    }

    private static func proverbsMoments(for chapter: Int, title: String, summary: String) -> [StudyMoment] {
        switch chapter {
        case 1...9:
            return [
                StudyMoment(label: "Opening call", title: "Wisdom is addressing the reader directly", detail: "Proverbs \(chapter) opens like instruction meant to win the heart before it simply informs the mind."),
                StudyMoment(label: "Main burden", title: title, detail: summary),
                StudyMoment(label: "Living response", title: "Choose wisdom over the rival voice", detail: "The chapter presses toward a decision of loyalty, not only intellectual agreement.")
            ]
        case 30:
            return [
                StudyMoment(label: "Humble confession", title: "Human limits are acknowledged first", detail: "Agur begins by resisting self-importance and pointing the learner back toward dependence on God."),
                StudyMoment(label: "Pure word", title: "God's word sets the measure", detail: "The chapter treats God's word as pure, sufficient, and safe for those who trust Him."),
                StudyMoment(label: "Measured life", title: "Observation becomes wisdom", detail: "Agur's sayings train careful attention, restraint, and contentment.")
            ]
        case 31:
            return [
                StudyMoment(label: "Royal counsel", title: "Leadership must serve justice", detail: "The first movement warns against corrupting strength and calls rulers to defend the needy."),
                StudyMoment(label: "Embodied wisdom", title: "Noble character becomes visible", detail: "The chapter's portrait shows wisdom worked out in labor, generosity, foresight, and strength."),
                StudyMoment(label: "Final center", title: "Fear of the Lord remains the true beauty", detail: "The chapter ends where Proverbs has always aimed: reverent fear of the Lord above surface appearance.")
            ]
        default:
            return [
                StudyMoment(label: "Repeated theme", title: "Watch the chapter's pattern", detail: "Short proverbs work together by repetition and contrast, so look for the same wisdom line appearing from different angles."),
                StudyMoment(label: "Main burden", title: title, detail: summary),
                StudyMoment(label: "Daily response", title: "Turn the chapter into practiced discernment", detail: "The chapter is aiming at judgment, restraint, and obedience in ordinary life.")
            ]
        }
    }

    private static func proverbsPracticeSteps(for chapter: Int, title: String) -> [String] {
        switch chapter {
        case 1...9:
            return [
                "Read Proverbs \(chapter) again and name the competing voice the chapter is warning you about.",
                "Choose one key verse from the chapter and pray it before your next decision.",
                "Take one concrete step today that proves you are choosing wisdom's path over convenience."
            ]
        case 30:
            return [
                "Confess one place where you have been acting self-sufficient instead of dependent on God.",
                "Let one verse from Proverbs 30 shape the way you think about contentment today.",
                "Practice one quiet act of restraint that reflects humility before God."
            ]
        case 31:
            return [
                "Ask where strength, generosity, diligence, or justice needs to become more visible in your life.",
                "Honor someone whose faithful character has quietly strengthened others.",
                "Choose one act of wise service today that reflects fear of the Lord rather than image."
            ]
        default:
            return [
                "Read Proverbs \(chapter) again and mark the theme it repeats most often.",
                "Carry one key verse from this chapter into a real conversation or decision today.",
                "Choose one small act of obedience that makes the wisdom of this chapter visible before the day ends."
            ]
        }
    }

    private struct BibleYearDescriptor {
        let monthTitle: String
        let readingRange: String
        let tags: [String]
        let historyText: String
        let takeaways: [String]
        let readingLens: String
        let practiceSteps: [String]
    }

    private static func bibleYearGuide(for lesson: WisdomLesson) -> JamesLessonGuide {
        let descriptor = bibleYearDescriptor(for: lesson.order)
        let firstVerse = lesson.keyVerses[safe: 0] ?? lesson.studyReference
        let secondVerse = lesson.keyVerses[safe: 1] ?? firstVerse
        let thirdVerse = lesson.keyVerses[safe: 2] ?? secondVerse

        return JamesLessonGuide(
            reference: lesson.studyReference,
            libraryTitle: descriptor.monthTitle,
            libraryDetail: "Reading range: \(descriptor.readingRange). \(lesson.summary)",
            overviewHighlights: [
                "This month keeps the full reading plan tied to one central movement of Scripture.",
                descriptor.readingLens,
                lesson.keyIdeas[safe: 1] ?? lesson.summary
            ],
            chapterMoments: [
                StudyMoment(
                    label: "Anchor chapter",
                    title: "\(lesson.studyReference) keeps the month grounded",
                    detail: "The lesson uses \(lesson.studyReference) as the chapter lens that keeps this month's larger reading span from feeling scattered."
                ),
                StudyMoment(
                    label: "Reading scope",
                    title: descriptor.readingRange,
                    detail: "Do not stop at the anchor chapter. This checkpoint is here to guide the whole reading range and preserve the storyline."
                ),
                StudyMoment(
                    label: "Bible School move",
                    title: "Read for storyline, not only completion",
                    detail: descriptor.readingLens
                )
            ],
            scriptureConnections: [
                StudyConnection(
                    reference: firstVerse,
                    explanation: "This verse helps anchor the central movement of the month so the wider reading span stays coherent."
                ),
                StudyConnection(
                    reference: secondVerse,
                    explanation: "This verse slows the month down and makes the main lesson of the reading range easier to carry into prayer and reflection."
                ),
                StudyConnection(
                    reference: thirdVerse,
                    explanation: "This verse gives one more stable place to return when the full reading plan starts feeling broad or demanding."
                )
            ],
            teachingLensSections: [
                (
                    title: "1. Why this month matters in the whole Bible",
                    detail: lesson.summary
                ),
                (
                    title: "2. How to read this month well",
                    detail: descriptor.readingLens
                ),
                (
                    title: "3. What Bible School wants you to notice",
                    detail: lesson.keyIdeas[safe: 2] ?? "Use the anchor chapter to keep the larger reading span clear, prayerful, and rooted in obedience."
                ),
                (
                    title: "4. How to keep the year from becoming shallow",
                    detail: "Do not reduce the plan to streaks or speed. Let the monthly checkpoint keep the storyline, the character of God, and one concrete response visible while you continue reading."
                )
            ],
            historyTags: descriptor.tags,
            historyText: descriptor.historyText,
            historyTakeaways: descriptor.takeaways,
            practiceSteps: descriptor.practiceSteps
        )
    }

    private static func bibleYearDescriptor(for month: Int) -> BibleYearDescriptor {
        switch month {
        case 1:
            return BibleYearDescriptor(
                monthTitle: "Month 1: Beginnings and Promise",
                readingRange: "Genesis 1-50",
                tags: ["Beginnings", "Patriarchs", "Covenant promise"],
                historyText: "Genesis lays the foundation for the whole Bible by showing creation, rebellion, judgment, covenant promise, and the preserved family line through Abraham, Isaac, Jacob, and Joseph. If this month becomes blurry, the rest of the year often becomes blurry too, because the main categories of Scripture are being established here.",
                takeaways: [
                    "Read Genesis for beginnings, promises, and the preservation of God's purpose through broken people.",
                    "Do not rush past covenant language, because the rest of Scripture keeps building on it.",
                    "Joseph's ending reminds you that God's providence is already active before Israel becomes a nation."
                ],
                readingLens: "Read Genesis as the opening movement of the whole biblical story: God creates, people rebel, judgment comes, and covenant promise begins to move forward.",
                practiceSteps: [
                    "Track one promise God gives in Genesis and pray it back to Him this week.",
                    "Notice how early compromise or trust shapes everything that follows.",
                    "Carry the storyline forward instead of reading each chapter like an isolated moment."
                ]
            )
        case 2:
            return BibleYearDescriptor(
                monthTitle: "Month 2: Deliverance and Holiness",
                readingRange: "Exodus - Leviticus",
                tags: ["Deliverance", "Covenant worship", "Holiness"],
                historyText: "This month moves from rescue out of Egypt into covenant formation, tabernacle worship, priestly mediation, and holy living. Exodus and Leviticus are not separate moods of God; they show that the God who rescues also teaches His people how to live in His presence.",
                takeaways: [
                    "Redemption and holiness belong together in the biblical pattern.",
                    "The tabernacle and sacrifices prepare your eyes for later fulfillment in Christ.",
                    "Read laws and worship instructions as covenant formation, not empty religious detail."
                ],
                readingLens: "Read this month by holding deliverance and holiness together. God saves people for covenant life in His presence, not merely out of danger.",
                practiceSteps: [
                    "Ask how redemption should change your approach to obedience and worship.",
                    "Mark one place where God's holiness feels sharper after reading this month.",
                    "Let the rescue pattern deepen your gratitude instead of treating the laws as filler."
                ]
            )
        case 3:
            return BibleYearDescriptor(
                monthTitle: "Month 3: Wilderness and Renewal",
                readingRange: "Numbers - Deuteronomy",
                tags: ["Wilderness", "Testing", "Covenant renewal"],
                historyText: "Numbers and Deuteronomy show a covenant people under pressure in the wilderness, where complaint, fear, unbelief, leadership strain, and divine faithfulness all stay close together. Deuteronomy then re-preaches covenant truth to a new generation preparing to cross over.",
                takeaways: [
                    "The wilderness reveals the heart under pressure.",
                    "Memory is central, because covenant truth has to be remembered to be obeyed.",
                    "Moses' final sermons show that instruction and love belong together."
                ],
                readingLens: "Read this month as a prolonged test of trust. The main question is whether God's people will remember Him enough to obey Him.",
                practiceSteps: [
                    "Name one pressure point where complaint has started replacing trust.",
                    "Repeat one command from Deuteronomy until it becomes prayer and memory.",
                    "Read for patterns of remembrance, not only for events."
                ]
            )
        case 4:
            return BibleYearDescriptor(
                monthTitle: "Month 4: Land, Judges, and Mercy",
                readingRange: "Joshua - Ruth",
                tags: ["Inheritance", "Compromise", "Redemption"],
                historyText: "Joshua, Judges, and Ruth show the contrast between covenant faithfulness, cyclical rebellion, and God's mercy in unstable days. This month keeps together conquest, collapse, and quiet redemption so the reader sees that even dark periods are not outside God's providence.",
                takeaways: [
                    "Joshua and Judges should be read as covenant history, not only military or political history.",
                    "Compromise becomes normal long before people admit it openly.",
                    "Ruth keeps redemption visible inside ordinary faithfulness."
                ],
                readingLens: "Read this month by watching what happens when covenant memory is either obeyed, neglected, or quietly embodied in ordinary faithfulness.",
                practiceSteps: [
                    "Notice where small compromise in Judges mirrors modern spiritual drift.",
                    "Let Ruth teach you to value quiet faithfulness alongside dramatic moments.",
                    "Ask where obedience needs courage before it needs convenience."
                ]
            )
        case 5:
            return BibleYearDescriptor(
                monthTitle: "Month 5: Kingship and Covenant Line",
                readingRange: "1 Samuel - 2 Samuel",
                tags: ["Kingship", "David", "Heart and leadership"],
                historyText: "These books trace Israel's transition into monarchy and expose the difference between outward impressiveness and inward faithfulness. Saul and David become a major study in leadership, anointing, covenant promise, repentance, and the long shadow of sin.",
                takeaways: [
                    "God's evaluation of leadership reaches the heart before the surface.",
                    "David's story holds promise and failure together instead of flattening either one.",
                    "The covenant line becomes clearer without becoming simplistic."
                ],
                readingLens: "Read this month by asking what kind of leader or disciple God actually approves, and how covenant promise survives even human failure.",
                practiceSteps: [
                    "Let 1 and 2 Samuel expose any habit of measuring strength by appearance alone.",
                    "Trace where repentance actually appears in David's life and where it does not.",
                    "Read for covenant promise and moral warning at the same time."
                ]
            )
        case 6:
            return BibleYearDescriptor(
                monthTitle: "Month 6: Kings, Temple, and Division",
                readingRange: "1 Kings - 2 Chronicles",
                tags: ["Temple", "Kingdom division", "Reform and decline"],
                historyText: "This month carries the reader through Solomon, temple glory, divided kingdoms, prophetic rebuke, reform, and national collapse. It shows how worship, leadership, and covenant loyalty shape public life across generations.",
                takeaways: [
                    "Temple glory does not protect a people who later tolerate compromise.",
                    "Kings and Chronicles show public consequences growing from private spiritual drift.",
                    "Reform matters, but partial reform is not the same as lasting faithfulness."
                ],
                readingLens: "Read this month by tracing how worship and leadership shape a nation's direction over time, not only in isolated moments.",
                practiceSteps: [
                    "Watch what each king does with worship, not only with politics.",
                    "Notice how prophetic rebuke keeps mercy and warning together.",
                    "Ask what your own life begins to resemble when private drift goes uncorrected."
                ]
            )
        case 7:
            return BibleYearDescriptor(
                monthTitle: "Month 7: Return and Rebuilding",
                readingRange: "Ezra - Esther",
                tags: ["Return", "Rebuilding", "Providence"],
                historyText: "Ezra, Nehemiah, and Esther belong to the post-exilic world where restoration is real but still fragile. Worship has to be rebuilt, walls have to be rebuilt, and courage has to rise in settings where God often works with providential quietness rather than spectacle.",
                takeaways: [
                    "Restoration usually includes real rebuilding work, not only emotional renewal.",
                    "Providence may be quieter in Esther, but it is not weaker.",
                    "The post-exilic books keep repentance, courage, and perseverance together."
                ],
                readingLens: "Read this month as a study in restoration under pressure. God is rebuilding a people, and that rebuilding demands courage, repentance, and patient labor.",
                practiceSteps: [
                    "Choose one neglected place in your life that needs rebuilding instead of delay.",
                    "Let Esther train your courage in hidden or pressured spaces.",
                    "Read with an eye for providence even when God seems less verbally foregrounded."
                ]
            )
        case 8:
            return BibleYearDescriptor(
                monthTitle: "Month 8: Wisdom, Worship, and Longing",
                readingRange: "Job - Song of Solomon",
                tags: ["Wisdom", "Worship", "Longing"],
                historyText: "The wisdom books stretch the reader beyond narrative momentum and into prayer, poetry, suffering, discernment, fear of the Lord, meaning, and covenant love. This month is slower and more reflective by design, because it trains the heart as much as the mind.",
                takeaways: [
                    "Job teaches honest reverence under suffering and mystery.",
                    "Psalms gives language for worship, lament, confession, and hope.",
                    "Wisdom literature must be meditated on, not rushed through only for progress."
                ],
                readingLens: "Read this month slowly. Let Scripture teach you how to suffer, worship, discern, and long before God with a shaped inner life.",
                practiceSteps: [
                    "Use one psalm or wisdom verse as the language of your prayer each day.",
                    "Pause longer over poetry and wisdom instead of reading it like rapid narrative.",
                    "Let the fear of the Lord become a repeated theme, not a passing phrase."
                ]
            )
        case 9:
            return BibleYearDescriptor(
                monthTitle: "Month 9: Prophets of Warning and Hope",
                readingRange: "Isaiah - Lamentations",
                tags: ["Prophets", "Holiness", "Hope in judgment"],
                historyText: "Isaiah, Jeremiah, and Lamentations deepen the reader's understanding of God's holiness, covenant lawsuit, grief, and promised restoration. The prophets do not flatten God into anger alone or comfort alone; they press both warning and hope into the conscience.",
                takeaways: [
                    "Prophecy carries covenant weight, not only future prediction.",
                    "The prophets show that grief and hope can live in the same faithful voice.",
                    "Messianic hope grows brighter against the darkness of judgment."
                ],
                readingLens: "Read this month by asking what the prophets reveal about God's character, not only what events they announce.",
                practiceSteps: [
                    "Read for holiness and mercy together instead of separating them.",
                    "Notice how lament still stays in relationship with God.",
                    "Carry one prophetic promise forward into hope-filled prayer."
                ]
            )
        case 10:
            return BibleYearDescriptor(
                monthTitle: "Month 10: Exile, Return, and Final Expectation",
                readingRange: "Ezekiel - Malachi",
                tags: ["Exile", "Restoration", "Messianic expectation"],
                historyText: "Ezekiel, Daniel, and the Twelve take the reader through exile visions, sovereignty under foreign powers, repentance, future cleansing, and the final prophetic expectation before Christ. This month helps connect judgment, return, and hope without losing any of their weight.",
                takeaways: [
                    "Exile reveals both the seriousness of sin and the steadiness of God's rule.",
                    "The final prophets keep future hope attached to repentance and covenant faithfulness.",
                    "By the end of Malachi, the reader should feel the ache for the Lord's coming deliverance."
                ],
                readingLens: "Read this month as the final prophetic stretch that keeps preparing the reader for Christ through judgment, cleansing, and promised restoration.",
                practiceSteps: [
                    "Watch how exile never removes God's sovereignty.",
                    "Trace the repeated promises of cleansing, renewal, and coming visitation.",
                    "End the month asking how the prophets have increased your expectation for Jesus."
                ]
            )
        case 11:
            return BibleYearDescriptor(
                monthTitle: "Month 11: Jesus and the Kingdom",
                readingRange: "Matthew - John",
                tags: ["Gospels", "Jesus", "Kingdom"],
                historyText: "The four Gospels bring the whole biblical story into focus around Jesus Christ. Reading them together helps the learner hold kingdom teaching, signs, compassion, confrontation, crucifixion, resurrection, and identity in one Christ-centered frame.",
                takeaways: [
                    "The Gospels should be read slowly enough for Jesus Himself to stay central.",
                    "Each Gospel gives a faithful angle without changing the same Lord.",
                    "The ministry, death, and resurrection of Jesus interpret the whole Bible."
                ],
                readingLens: "Read this month by asking what each passage shows about Jesus, His kingdom, and the kind of disciples He is forming.",
                practiceSteps: [
                    "Keep one daily question in front of you: what does this show me about Jesus?",
                    "Let the Gospels correct any Christless way of reading the Bible.",
                    "Slow down at the cross and resurrection instead of treating them as familiar terrain."
                ]
            )
        default:
            return BibleYearDescriptor(
                monthTitle: "Month 12: Church, Mission, and Last Hope",
                readingRange: "Acts - Revelation",
                tags: ["Church", "Mission", "Final hope"],
                historyText: "Acts, the Epistles, and Revelation show what the risen Christ is doing through His church and where the whole biblical story is headed. Doctrine, mission, holiness, suffering, encouragement, and final hope are all held together in this closing month.",
                takeaways: [
                    "Acts shows the Spirit-driven spread of the gospel and the life of the early church.",
                    "The Epistles turn gospel truth into daily doctrine, practice, and endurance.",
                    "Revelation lifts the eyes of the church toward the final victory and presence of Christ."
                ],
                readingLens: "Read this month as the life of Christ extended through His church until the final restoration of all things.",
                practiceSteps: [
                    "Notice how doctrine and discipleship stay tied together in the letters.",
                    "Read Revelation for hope-filled worship, endurance, and the final triumph of Jesus.",
                    "Finish the year by naming the clearest change God has made in you through the whole Bible."
                ]
            )
        }
    }
}

private struct ChapterChallengeShareGraphic: View {
    let chapterReference: String
    let verseReference: String
    let verseText: String
    let takeaway: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [OVTheme.lemon.opacity(0.36), .white, OVTheme.mist.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("Chapter challenge")
                        .font(OVTheme.heading(16))
                        .foregroundStyle(OVTheme.midnight)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.9))
                        .clipShape(Capsule())

                    Spacer()

                    Text("KJV")
                        .font(OVTheme.heading(14))
                        .foregroundStyle(OVTheme.midnight.opacity(0.82))
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Join me in \(chapterReference) today")
                        .font(OVTheme.display(30))
                        .foregroundStyle(OVTheme.midnight)

                    Text(verseReference)
                        .font(OVTheme.heading(15))
                        .foregroundStyle(OVTheme.gold)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(verseText)
                        .font(OVTheme.body(21))
                        .foregroundStyle(OVTheme.ink.opacity(0.88))
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("My takeaway")
                            .font(OVTheme.body(11))
                            .foregroundStyle(OVTheme.gold)

                        Text(takeaway)
                            .font(OVTheme.body(16))
                            .foregroundStyle(OVTheme.ink.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white.opacity(0.82))
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                }

                Spacer(minLength: 0)

                HStack(alignment: .bottom) {
                    Text("Read the chapter. Reflect. Share.")
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

private struct LessonActivityShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private enum LessonDeckPhase: String, Identifiable {
    case overview
    case chapter
    case reflection
    case teachingLens
    case scriptureConnections
    case historicalSetting
    case practice

    var id: String { rawValue }

    var shortTitle: String {
        switch self {
        case .overview:
            return "Overview"
        case .chapter:
            return "Chapter"
        case .reflection:
            return "Reflect"
        case .teachingLens:
            return "Depth"
        case .scriptureConnections:
            return "Links"
        case .historicalSetting:
            return "History"
        case .practice:
            return "Practice"
        }
    }

    static func deck(hasPremiumAccess: Bool) -> [LessonDeckPhase] {
        if hasPremiumAccess {
            return [
                .overview,
                .chapter,
                .reflection,
                .teachingLens,
                .scriptureConnections,
                .historicalSetting,
                .practice
            ]
        }

        return [.overview, .chapter, .reflection]
    }
}

private extension WisdomLesson {
    var studyReference: String {
        sourceName.replacingOccurrences(of: "Bible: ", with: "")
    }
}

struct LessonLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LessonLibraryView(
            store: SoulJourneyStore(),
            accessManager: SubscriptionAccessManager()
        )
    }
}
