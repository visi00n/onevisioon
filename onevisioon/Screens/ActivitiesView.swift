import SwiftUI

struct QuestCenterView: View {
    @ObservedObject var store: SoulJourneyStore
    @ObservedObject var accessManager: SubscriptionAccessManager
    @State private var showContent = false

    private var totalPassedActions: Int {
        store.allCourses.reduce(0) { partial, course in
            partial + store.passedQuestsCount(for: course)
        }
    }

    private var totalLessons: Int {
        store.allCourses.reduce(0) { partial, course in
            partial + store.lessons(for: course).count
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    header
                        .stagedReveal(showContent, delay: 0.02)

                    folderSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(OVTheme.mainBackground.ignoresSafeArea())
            .navigationTitle("Quests")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AppInfoButton()
                }
            }
            .onAppear {
                guard !showContent else { return }
                showContent = true
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quest folders")
                .font(OVTheme.display(30))
                .foregroundStyle(OVTheme.midnight)

            Text("Bible School chapter checks")
                .font(OVTheme.heading(30))
                .foregroundStyle(OVTheme.ink)

            Text("Quests now mirror your lesson folders, so each book keeps its own chapter checks in one place.")
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink.opacity(0.68))

            HStack(spacing: 10) {
                statChip("Passed", "\(totalPassedActions)/\(totalLessons)")
                statChip("Attempts", "\(store.questAttempts.count)")
                statChip("Points", "\(store.wisdomPoints)")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var folderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(store.allCourses.enumerated()), id: \.element.id) { index, course in
                NavigationLink {
                    CourseQuestFolderView(store: store, accessManager: accessManager, course: course)
                } label: {
                    folderCard(for: course)
                }
                .buttonStyle(.plain)
                .stagedReveal(showContent, delay: 0.1 + (Double(index) * 0.04))
            }
        }
    }

    private func folderCard(for course: WisdomCourse) -> some View {
        let passed = store.passedQuestsCount(for: course)
        let total = store.lessons(for: course).count

        return HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(folderAccent(for: course))
                    .frame(width: 58, height: 58)

                Image(systemName: "folder.fill.badge.checkmark")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(OVTheme.midnight)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(folderKind(for: course))
                        .font(OVTheme.body(10))
                        .foregroundStyle(OVTheme.gold)

                    Text("\(passed)/\(total) passed")
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
                    statPill("\(total) chapter quests")
                    statPill("Bible School open")
                }

                HStack {
                    Text("Open quest folder")
                        .font(OVTheme.heading(14))
                        .foregroundStyle(OVTheme.midnight)

                    Spacer()

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

    private func statChip(_ title: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(title.uppercased())
                .font(OVTheme.body(10))
                .foregroundStyle(OVTheme.ink.opacity(0.56))
            Text(value)
                .font(OVTheme.heading(14))
                .foregroundStyle(OVTheme.midnight)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func statPill(_ title: String) -> some View {
        Text(title)
            .font(OVTheme.body(11))
            .foregroundStyle(OVTheme.midnight)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(.white.opacity(0.95))
            .clipShape(Capsule())
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
            return "Chapter quests for James with meaning, history, and application checks."
        case store.legacyCourse.id:
            return "Quest your way through Proverbs chapter by chapter with deeper wisdom, history, and chapter-meaning questions."
        case store.yearCourse.id:
            return "Monthly Bible School checkpoints that keep the full-year reading path clear, historical, and anchored in Scripture."
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
}

private struct CourseQuestFolderView: View {
    @ObservedObject var store: SoulJourneyStore
    @ObservedObject var accessManager: SubscriptionAccessManager
    let course: WisdomCourse

    private var isYearCourse: Bool {
        course.id == store.yearCourse.id
    }

    private var lessons: [WisdomLesson] {
        store.lessons(for: course)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                ForEach(lessons) { lesson in
                    questCard(for: lesson)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle("\(folderTitle) Quests")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bible School quest folder")
                .font(OVTheme.body(11))
                .foregroundStyle(OVTheme.gold)

            Text(folderTitle)
                .font(OVTheme.display(30))
                .foregroundStyle(OVTheme.midnight)

            Text(isYearCourse ? "Each monthly checkpoint in this folder tests whether the full-year reading is staying clear, rooted in Scripture, and connected to the wider biblical storyline." : "Each chapter quest in this folder checks historical setting, key ideas, and whether the chapter’s movement is actually making sense to the learner.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))

            HStack(spacing: 8) {
                statPill("\(store.passedQuestsCount(for: course))/\(lessons.count) passed")
                statPill("Bible School")
                statPill(isYearCourse ? "Storyline + meaning" : "History + meaning")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(OVTheme.elevatedCard)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
    }

    private func questCard(for lesson: WisdomLesson) -> some View {
        let unlocked = store.isLessonUnlocked(lesson)
        let progress = store.progress(for: lesson)
        let canTakeQuest = store.canTakeQuest(for: lesson)

        return NavigationLink {
            QuestTakeView(store: store, lesson: lesson)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(isYearCourse ? "Month \(lesson.order) Quest" : "Chapter \(lesson.order) Quest")
                        .font(OVTheme.heading(17))
                        .foregroundStyle(OVTheme.ink)
                    Spacer()
                    Text(statusText(unlocked: unlocked, progress: progress))
                        .font(OVTheme.body(12))
                        .foregroundStyle(statusColor(unlocked: unlocked, progress: progress))
                }

                Text(lesson.title)
                    .font(OVTheme.body(15))
                    .foregroundStyle(OVTheme.ink.opacity(0.75))

                if progress.quizAttempts > 0 {
                    Text("Best score: \(progress.bestQuizScore)% • Attempts: \(progress.quizAttempts)")
                        .font(OVTheme.body(12))
                        .foregroundStyle(OVTheme.ink.opacity(0.6))
                }

                if canTakeQuest {
                    Text(progress.quizPassed ? "Retake quest" : "Start quest")
                        .font(OVTheme.heading(14))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(OVTheme.midnight)
                        .clipShape(Capsule())
                } else if !unlocked {
                    Text("Locked: finish the previous chapter lesson first.")
                        .font(OVTheme.body(12))
                        .foregroundStyle(OVTheme.ink.opacity(0.55))
                } else {
                    Text("Finish the lesson deck first.")
                        .font(OVTheme.body(12))
                        .foregroundStyle(OVTheme.ink.opacity(0.55))
                }
            }
            .padding(16)
            .background(unlocked ? .white : OVTheme.smoke)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(unlocked ? OVTheme.midnight.opacity(0.08) : OVTheme.ink.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(!canTakeQuest)
        .opacity(canTakeQuest ? 1 : 0.75)
    }

    private func statusText(unlocked: Bool, progress: LessonProgress) -> String {
        guard unlocked else { return "Locked" }
        if progress.quizPassed { return "Passed" }
        if progress.lessonCompleted { return "Ready" }
        return "Lesson Needed"
    }

    private func statusColor(unlocked: Bool, progress: LessonProgress) -> Color {
        guard unlocked else { return OVTheme.ink.opacity(0.55) }
        return progress.quizPassed ? .green : OVTheme.midnight
    }

    private func statPill(_ title: String) -> some View {
        Text(title)
            .font(OVTheme.body(11))
            .foregroundStyle(OVTheme.midnight)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(.white.opacity(0.95))
            .clipShape(Capsule())
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
}

struct QuestTakeView: View {
    @ObservedObject var store: SoulJourneyStore
    let lesson: WisdomLesson

    @State private var answers: [String: Int] = [:]
    @State private var submission: QuestSubmissionResult?
    @State private var showQuestions = false

    private var assessmentQuest: WisdomQuest {
        lesson.assessmentQuest
    }

    private var chapterReference: String {
        lesson.sourceName.replacingOccurrences(of: "Bible: ", with: "")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                headerCard

                ForEach(Array(assessmentQuest.questions.enumerated()), id: \.element.id) { index, question in
                    questionCard(number: index + 1, question: question)
                        .stagedReveal(showQuestions, delay: 0.03 + (Double(index) * 0.03))
                }

                if let submission {
                    resultCard(submission)
                }

                actionButtons
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(OVTheme.mainBackground.ignoresSafeArea())
        .navigationTitle("Lesson \(lesson.order) Quest")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard !showQuestions else { return }
            showQuestions = true
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Bible School quest")
                    .font(OVTheme.body(11))
                    .foregroundStyle(OVTheme.gold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.95))
                    .clipShape(Capsule())

                Spacer()

                Text("\(assessmentQuest.questions.count) questions")
                    .font(OVTheme.body(11))
                    .foregroundStyle(OVTheme.ink.opacity(0.62))
            }

            Text(chapterReference)
                .font(OVTheme.display(30))
                .foregroundStyle(OVTheme.midnight)

            Text("These questions press into chapter meaning, historical setting, and the core movement of the lesson, not just recognition of familiar phrases.")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.ink.opacity(0.72))

            HStack(spacing: 8) {
                questMetaPill("Pass \(assessmentQuest.passingScore)%")
                questMetaPill("Chapter depth")
                questMetaPill("History + context")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(OVTheme.paper.opacity(0.98))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(OVTheme.line, lineWidth: 1)
        )
    }

    private func questionCard(number: Int, question: WisdomQuestion) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Question \(number)")
                .font(OVTheme.body(11))
                .foregroundStyle(OVTheme.gold)

            Text(question.prompt)
                .font(OVTheme.heading(17))
                .foregroundStyle(OVTheme.ink)

            ForEach(Array(question.options.enumerated()), id: \.offset) { option in
                let selected = answers[question.id] == option.offset
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                        answers[question.id] = option.offset
                    }
                } label: {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                            .foregroundStyle(selected ? OVTheme.midnight : OVTheme.ink.opacity(0.55))
                        Text(option.element)
                            .font(OVTheme.body(15))
                            .foregroundStyle(OVTheme.ink.opacity(0.78))
                        Spacer()
                    }
                    .padding(10)
                    .background(selected ? OVTheme.sky.opacity(0.38) : .white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(selected ? OVTheme.midnight.opacity(0.22) : .clear, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .scaleEffect(selected ? 1 : 0.996)
                    .animation(.spring(response: 0.28, dampingFraction: 0.86), value: selected)
                }
                .buttonStyle(.plain)
            }

            if submission != nil {
                Text(question.explanation)
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.ink.opacity(0.65))
            }
        }
        .padding(14)
        .background(.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func resultCard(_ result: QuestSubmissionResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(result.passed ? "Quest Passed" : "Quest Not Passed")
                .font(OVTheme.heading(20))
                .foregroundStyle(result.passed ? .green : .orange)

            Text("Score: \(result.score)% (\(result.correctAnswers)/\(result.totalQuestions))")
                .font(OVTheme.body(15))
                .foregroundStyle(OVTheme.ink)

            Text("Points earned: +\(result.pointsEarned)")
                .font(OVTheme.body(14))
                .foregroundStyle(OVTheme.midnight)

            if !result.passed {
                Text("Review the lesson, slow down, and try the quest again.")
                    .font(OVTheme.body(13))
                    .foregroundStyle(OVTheme.ink.opacity(0.66))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(OVTheme.lemon.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func questMetaPill(_ label: String) -> some View {
        Text(label)
            .font(OVTheme.body(11))
            .foregroundStyle(OVTheme.midnight)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(.white.opacity(0.96))
            .clipShape(Capsule())
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                submission = store.submitQuest(for: lesson, answers: answers)
            } label: {
                Text("Submit Quest")
                    .font(OVTheme.heading(16))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(OVTheme.midnight)
                    .clipShape(Capsule())
            }
            .disabled(answers.count != assessmentQuest.questions.count)
            .opacity(answers.count == assessmentQuest.questions.count ? 1 : 0.45)

            if submission != nil {
                Button {
                    answers = [:]
                    submission = nil
                } label: {
                    Text("Retake with fresh answers")
                        .font(OVTheme.heading(15))
                        .foregroundStyle(OVTheme.midnight)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(.white)
                        .clipShape(Capsule())
                }
            }

            if let submission, submission.passed, let nextLesson = store.nextLesson(after: lesson) {
                NavigationLink {
                    ChapterStudyView(store: store, lesson: nextLesson, hasPremiumAccess: true)
                } label: {
                    Text("Continue to \(nextLesson.sourceName.replacingOccurrences(of: "Bible: ", with: ""))")
                        .font(OVTheme.heading(15))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(.green)
                        .clipShape(Capsule())
                }
            }

            if let submission, submission.passed, store.nextLesson(after: lesson) == nil {
                Text("You completed every quest in this course. New paths can be added next.")
                    .font(OVTheme.body(13))
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct QuestCenterView_Previews: PreviewProvider {
    static var previews: some View {
        QuestCenterView(
            store: SoulJourneyStore(),
            accessManager: SubscriptionAccessManager()
        )
    }
}
