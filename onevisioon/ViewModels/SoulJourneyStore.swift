import Foundation
import Combine

@MainActor
final class SoulJourneyStore: ObservableObject {
    private enum DefaultsKey {
        static let onboardingCompleted = "ov_onboarding_completed"
        static let onboardingProfile = "ov_onboarding_profile"
        static let publicProfileSettings = "ov_public_profile_settings"
        static let wisdomPoints = "ov_wisdom_points"
        static let lessonProgressMap = "ov_lesson_progress_map"
        static let questAttempts = "ov_quest_attempts"
        static let lessonNotes = "ov_lesson_notes"
        static let chapterReflections = "ov_chapter_reflections"
        static let lessonStudyStepMap = "ov_lesson_study_step_map"
        static let prayerFeedPosts = "ov_prayer_feed_posts"
        static let dailyGrowthEntries = "ov_daily_growth_entries"
        static let activityDayKeys = "ov_activity_day_keys"
        static let purchasedStoreItemIDs = "ov_purchased_store_item_ids"
        static let likedBibleVerseReferences = "ov_liked_bible_verse_references"
        static let highlightedBibleVerseReferences = "ov_highlighted_bible_verse_references"
        static let bibleVerseHighlights = "ov_bible_verse_highlights"
        static let bibleVerseNotes = "ov_bible_verse_notes"
        static let onboardingLeadSheet = "ov_onboarding_lead_sheet"
        static let lastReadBibleLocation = "ov_last_read_bible_location"
        static let onboardingResetMarker = "ov_onboarding_reset_marker"
        static let creativeCheckIns = "ov_creative_check_ins"
        static let creationFeedPosts = "ov_creation_feed_posts"
        static let resetChallengeProgress = "ov_reset_challenge_progress"
    }

    private static let onboardingResetToken = "2026-04-02-onboarding-reset-1"

    private let defaults = UserDefaults.standard

    @Published var onboardingCompleted: Bool {
        didSet { defaults.set(onboardingCompleted, forKey: DefaultsKey.onboardingCompleted) }
    }

    @Published var onboardingProfile: OnboardingAnswerSet {
        didSet { persist(onboardingProfile, key: DefaultsKey.onboardingProfile) }
    }

    @Published var publicProfileSettings: PublicProfileSettings {
        didSet { persist(publicProfileSettings, key: DefaultsKey.publicProfileSettings) }
    }

    @Published var wisdomPoints: Int {
        didSet { defaults.set(wisdomPoints, forKey: DefaultsKey.wisdomPoints) }
    }

    @Published var lessonProgressMap: [String: LessonProgress] {
        didSet { persist(lessonProgressMap, key: DefaultsKey.lessonProgressMap) }
    }

    @Published var questAttempts: [QuestAttempt] {
        didSet { persist(questAttempts, key: DefaultsKey.questAttempts) }
    }

    @Published var lessonNotes: [LessonNote] {
        didSet { persist(lessonNotes, key: DefaultsKey.lessonNotes) }
    }

    @Published var chapterReflections: [ChapterReflection] {
        didSet { persist(chapterReflections, key: DefaultsKey.chapterReflections) }
    }

    @Published var lessonStudyStepMap: [String: Int] {
        didSet { persist(lessonStudyStepMap, key: DefaultsKey.lessonStudyStepMap) }
    }

    @Published var prayerFeedPosts: [PrayerFeedPost] {
        didSet { persist(prayerFeedPosts, key: DefaultsKey.prayerFeedPosts) }
    }

    @Published var dailyGrowthEntries: [DailyGrowthEntry] {
        didSet { persist(dailyGrowthEntries, key: DefaultsKey.dailyGrowthEntries) }
    }

    @Published var activityDayKeys: [String] {
        didSet { persist(activityDayKeys, key: DefaultsKey.activityDayKeys) }
    }

    @Published var purchasedStoreItemIDs: Set<String> {
        didSet { persist(Array(purchasedStoreItemIDs).sorted(), key: DefaultsKey.purchasedStoreItemIDs) }
    }

    @Published var likedBibleVerseReferences: Set<String> {
        didSet { persist(Array(likedBibleVerseReferences).sorted(), key: DefaultsKey.likedBibleVerseReferences) }
    }

    @Published var bibleVerseHighlights: [BibleVerseHighlight] {
        didSet {
            persist(
                Self.normalizedBibleVerseHighlights(bibleVerseHighlights),
                key: DefaultsKey.bibleVerseHighlights
            )
        }
    }

    @Published var bibleVerseNotes: [BibleVerseNote] {
        didSet { persist(bibleVerseNotes, key: DefaultsKey.bibleVerseNotes) }
    }

    @Published var onboardingLeadSheet: [OnboardingLeadRecord] {
        didSet { persist(onboardingLeadSheet, key: DefaultsKey.onboardingLeadSheet) }
    }

    @Published var creativeCheckIns: [CreativeCheckIn] {
        didSet { persist(creativeCheckIns, key: DefaultsKey.creativeCheckIns) }
    }

    @Published var creationFeedPosts: [CreationFeedPost] {
        didSet { persist(creationFeedPosts, key: DefaultsKey.creationFeedPosts) }
    }

    @Published var resetChallengeProgress: ResetChallengeProgress {
        didSet { persist(resetChallengeProgress.normalized, key: DefaultsKey.resetChallengeProgress) }
    }

    @Published var lastReadBibleLocation: BibleLocation? {
        didSet {
            if let lastReadBibleLocation {
                persist(lastReadBibleLocation, key: DefaultsKey.lastReadBibleLocation)
            } else {
                defaults.removeObject(forKey: DefaultsKey.lastReadBibleLocation)
            }
        }
    }

    struct LeaderboardEntry: Identifiable, Hashable {
        let id: String
        let displayName: String
        let handle: String
        let lessonsCompleted: Int
        let points: Int
        let isCurrentUser: Bool

        var wisdomLevel: Int {
            max(1, (points / 300) + 1)
        }

        var growthTier: String {
            let score = points + (lessonsCompleted * 45)
            switch score {
            case ..<500:
                return "Seeker"
            case ..<1100:
                return "Disciple"
            case ..<1900:
                return "Warrior"
            case ..<2800:
                return "Leader"
            default:
                return "Mentor"
            }
        }
    }

    let course = WisdomCourse.jamesBibleSchool
    let legacyCourse = WisdomCourse.proverbsWisdomPath
    let yearCourse = WisdomCourse.bibleInAYearSchool
    let wisdomV2Course = WisdomCourse.biblicalWisdomV2

    init() {
        onboardingCompleted = defaults.bool(forKey: DefaultsKey.onboardingCompleted)
        onboardingProfile = Self.loadValue(defaults, key: DefaultsKey.onboardingProfile, as: OnboardingAnswerSet.self) ?? .empty
        publicProfileSettings = Self.loadValue(defaults, key: DefaultsKey.publicProfileSettings, as: PublicProfileSettings.self) ?? .empty
        wisdomPoints = defaults.object(forKey: DefaultsKey.wisdomPoints) == nil ? 0 : defaults.integer(forKey: DefaultsKey.wisdomPoints)
        lessonProgressMap = Self.loadValue(defaults, key: DefaultsKey.lessonProgressMap, as: [String: LessonProgress].self) ?? [:]
        questAttempts = Self.loadValue(defaults, key: DefaultsKey.questAttempts, as: [QuestAttempt].self) ?? []
        lessonNotes = Self.loadValue(defaults, key: DefaultsKey.lessonNotes, as: [LessonNote].self) ?? []
        chapterReflections = Self.loadValue(defaults, key: DefaultsKey.chapterReflections, as: [ChapterReflection].self) ?? []
        lessonStudyStepMap = Self.loadValue(defaults, key: DefaultsKey.lessonStudyStepMap, as: [String: Int].self) ?? [:]
        prayerFeedPosts = Self.loadValue(defaults, key: DefaultsKey.prayerFeedPosts, as: [PrayerFeedPost].self) ?? []
        dailyGrowthEntries = Self.loadValue(defaults, key: DefaultsKey.dailyGrowthEntries, as: [DailyGrowthEntry].self) ?? []
        activityDayKeys = Self.loadValue(defaults, key: DefaultsKey.activityDayKeys, as: [String].self) ?? []
        purchasedStoreItemIDs = Set(Self.loadValue(defaults, key: DefaultsKey.purchasedStoreItemIDs, as: [String].self) ?? [])
        likedBibleVerseReferences = Set(Self.loadValue(defaults, key: DefaultsKey.likedBibleVerseReferences, as: [String].self) ?? [])
        let savedBibleVerseHighlights = Self.loadValue(defaults, key: DefaultsKey.bibleVerseHighlights, as: [BibleVerseHighlight].self)
        let legacyHighlightedReferences = Self.loadValue(defaults, key: DefaultsKey.highlightedBibleVerseReferences, as: [String].self) ?? []
        bibleVerseHighlights = Self.normalizedBibleVerseHighlights(
            savedBibleVerseHighlights ?? legacyHighlightedReferences.map {
                BibleVerseHighlight(reference: $0, style: .butter)
            }
        )
        bibleVerseNotes = Self.loadValue(defaults, key: DefaultsKey.bibleVerseNotes, as: [BibleVerseNote].self) ?? []
        onboardingLeadSheet = Self.loadValue(defaults, key: DefaultsKey.onboardingLeadSheet, as: [OnboardingLeadRecord].self) ?? []
        creativeCheckIns = Self.loadValue(defaults, key: DefaultsKey.creativeCheckIns, as: [CreativeCheckIn].self) ?? []
        creationFeedPosts = Self.loadValue(defaults, key: DefaultsKey.creationFeedPosts, as: [CreationFeedPost].self) ?? []
        resetChallengeProgress = (
            Self.loadValue(defaults, key: DefaultsKey.resetChallengeProgress, as: ResetChallengeProgress.self)
            ?? .empty
        ).normalized
        lastReadBibleLocation = Self.loadValue(defaults, key: DefaultsKey.lastReadBibleLocation, as: BibleLocation.self)

        normalizeLessonStudySteps()
        normalizeActivityKeys()
        applyOneTimeOnboardingResetIfNeeded()

        if prayerFeedPosts.isEmpty {
            prayerFeedPosts = Self.seedPrayerFeedPosts
        }
        if creationFeedPosts.isEmpty {
            creationFeedPosts = Self.seedCreationFeedPosts
        }
    }

    var lessons: [WisdomLesson] {
        lessons(for: course)
    }

    var allCourses: [WisdomCourse] {
        [course, legacyCourse, yearCourse]
    }

    var allLessons: [WisdomLesson] {
        allCourses.flatMap { lessons(for: $0) }
    }

    func lessons(for course: WisdomCourse) -> [WisdomLesson] {
        course.lessons.sorted(by: { $0.order < $1.order })
    }

    var completedLessonsCount: Int {
        completedLessonsCount(for: course)
    }

    var passedQuestsCount: Int {
        passedQuestsCount(for: course)
    }

    var courseCompletionPercent: Int {
        courseCompletionPercent(for: course)
    }

    func completedLessonsCount(for course: WisdomCourse) -> Int {
        lessons(for: course).filter { progress(for: $0).lessonCompleted }.count
    }

    func passedQuestsCount(for course: WisdomCourse) -> Int {
        lessons(for: course).filter { progress(for: $0).quizPassed }.count
    }

    func courseCompletionPercent(for course: WisdomCourse) -> Int {
        let courseLessons = lessons(for: course)
        guard !courseLessons.isEmpty else { return 0 }
        return Int((Double(completedLessonsCount(for: course)) / Double(courseLessons.count)) * 100.0)
    }

    var wisdomLevel: Int {
        max(1, (wisdomPoints / 300) + 1)
    }

    var pointsToNextLevel: Int {
        max(0, (wisdomLevel * 300) - wisdomPoints)
    }

    var progressToNextLevel: Double {
        let pointsIntoCurrentLevel = wisdomPoints % 300
        return Double(pointsIntoCurrentLevel) / 300.0
    }

    var recentQuestAttempts: [QuestAttempt] {
        Array(questAttempts.sorted(by: { $0.attemptedAt > $1.attemptedAt }).prefix(8))
    }

    var sortedPrayerFeedPosts: [PrayerFeedPost] {
        prayerFeedPosts.sorted(by: { $0.createdAt > $1.createdAt })
    }

    var recentDailyGrowthEntries: [DailyGrowthEntry] {
        dailyGrowthEntries.sorted(by: { $0.createdAt > $1.createdAt })
    }

    var sortedLessonNotes: [LessonNote] {
        lessonNotes.sorted(by: { $0.updatedAt > $1.updatedAt })
    }

    var sortedChapterReflections: [ChapterReflection] {
        chapterReflections.sorted(by: { $0.updatedAt > $1.updatedAt })
    }

    var sortedBibleVerseNotes: [BibleVerseNote] {
        bibleVerseNotes.sorted(by: { $0.updatedAt > $1.updatedAt })
    }

    var sortedCreativeCheckIns: [CreativeCheckIn] {
        creativeCheckIns.sorted(by: { $0.dayKey > $1.dayKey })
    }

    var sortedCreationFeedPosts: [CreationFeedPost] {
        creationFeedPosts.sorted(by: { $0.createdAt > $1.createdAt })
    }

    var storeItems: [WisdomStoreItem] {
        WisdomStoreCatalog.items
    }

    var didUseAppToday: Bool {
        activityDaySet.contains(dayKey(for: .now))
    }

    var totalActiveDays: Int {
        activityDaySet.count
    }

    var currentStreak: Int {
        consecutiveDayStreak(for: activityDaySet)
    }

    var hasCompletedLessonToday: Bool {
        allLessons.contains { lesson in
            guard let completedAt = progress(for: lesson).completedAt else { return false }
            return calendar.isDateInToday(completedAt)
        }
    }

    var canUseDailyCheckIn: Bool {
        hasCompletedLessonToday
    }

    var hasSubmittedDailyGrowthToday: Bool {
        dailyGrowthEntries.contains(where: { calendar.isDateInToday($0.createdAt) })
    }

    var currentCourseLesson: WisdomLesson {
        currentLesson(in: course)
    }

    var defaultBibleLocation: BibleLocation {
        BibleLocation(book: "Genesis", chapter: 1)
    }

    var continueBibleLocation: BibleLocation {
        lastReadBibleLocation ?? defaultBibleLocation
    }

    var currentGrowthTier: String {
        leaderboardEntries.first(where: { $0.isCurrentUser })?.growthTier ?? "Seeker"
    }

    var creativeStreak: Int {
        consecutiveDayStreak(
            for: Set(
                creativeCheckIns
                    .filter(\.hasMeaningfulProgress)
                    .map(\.dayKey)
            )
        )
    }

    var reflectionCount: Int {
        chapterReflections.count
    }

    var currentReflectionStreak: Int {
        consecutiveDayStreak(for: reflectionDaySet)
    }

    var completedLessonsAcrossAllCourses: Int {
        allLessons.filter { progress(for: $0).lessonCompleted }.count
    }

    var resetChallengeCompletedCount: Int {
        resetChallengeDaySet.count
    }

    var hasStartedResetChallenge: Bool {
        resetChallengeProgress.startedAt != nil || !resetChallengeDaySet.isEmpty
    }

    var hasCompletedResetChallenge: Bool {
        resetChallengeCompletedCount >= 7
    }

    var nextResetChallengeDayNumber: Int? {
        guard !hasCompletedResetChallenge else { return nil }
        return (1...7).first(where: { !resetChallengeDaySet.contains($0) }) ?? 1
    }

    func currentLesson(in course: WisdomCourse) -> WisdomLesson {
        let courseLessons = lessons(for: course)
        return courseLessons.first(where: { lesson in
            isLessonUnlocked(lesson) && !progress(for: lesson).lessonCompleted
        }) ?? courseLessons.last ?? course.lessons[0]
    }

    var leaderboardEntries: [LeaderboardEntry] {
        var entries = Self.seedLeaderboardEntries
        let learnerName = onboardingProfile.fullName.trimmed.isEmpty ? "You" : onboardingProfile.fullName.trimmed

        let currentUserEntry = LeaderboardEntry(
            id: "current-user",
            displayName: learnerName,
            handle: usernameHandle,
            lessonsCompleted: completedLessonsCount,
            points: wisdomPoints,
            isCurrentUser: true
        )

        if let existing = entries.firstIndex(where: { $0.handle.lowercased() == currentUserEntry.handle.lowercased() }) {
            entries[existing] = currentUserEntry
        } else {
            entries.append(currentUserEntry)
        }

        return entries.sorted { lhs, rhs in
            if lhs.points != rhs.points {
                return lhs.points > rhs.points
            }
            if lhs.lessonsCompleted != rhs.lessonsCompleted {
                return lhs.lessonsCompleted > rhs.lessonsCompleted
            }
            return lhs.displayName.localizedCaseInsensitiveCompare(rhs.displayName) == .orderedAscending
        }
    }

    func completeOnboarding(profile: OnboardingAnswerSet) {
        onboardingProfile = profile
        onboardingCompleted = true
        upsertOnboardingLeadRecord(using: profile)
    }

    func applyAuthenticatedIdentity(displayName: String, email: String) {
        var profile = onboardingProfile
        var didChange = false

        if profile.fullName.trimmed.isEmpty && !displayName.trimmed.isEmpty {
            profile.fullName = displayName.trimmed
            didChange = true
        }

        if profile.email.trimmed.isEmpty && !email.trimmed.isEmpty {
            profile.email = email.trimmed
            didChange = true
        }

        guard didChange else { return }

        onboardingProfile = profile
        upsertOnboardingLeadRecord(using: profile)
    }

    func isLessonUnlocked(_ lesson: WisdomLesson) -> Bool {
        if lesson.order == 1 { return true }

        let courseLessons = lessons(containing: lesson)

        guard let previousLesson = courseLessons.first(where: { $0.order == lesson.order - 1 }) else {
            return false
        }

        let previousProgress = progress(for: previousLesson)
        return previousProgress.lessonCompleted
    }

    func progress(for lesson: WisdomLesson) -> LessonProgress {
        lessonProgressMap[lesson.id] ?? .empty
    }

    func lesson(for lessonID: String) -> WisdomLesson? {
        allLessons.first(where: { $0.id == lessonID })
    }

    func nextLesson(after lesson: WisdomLesson) -> WisdomLesson? {
        lessons(containing: lesson).first(where: { $0.order == lesson.order + 1 })
    }

    func exportSyncSnapshot() -> UserProgressSyncSnapshot {
        UserProgressSyncSnapshot(
            schemaVersion: UserProgressSyncSnapshot.currentSchemaVersion,
            exportedAt: .now,
            onboardingCompleted: onboardingCompleted,
            onboardingProfile: onboardingProfile,
            publicProfileSettings: publicProfileSettings,
            wisdomPoints: wisdomPoints,
            lessonProgressMap: lessonProgressMap,
            questAttempts: questAttempts,
            lessonNotes: lessonNotes,
            chapterReflections: chapterReflections,
            lessonStudyStepMap: lessonStudyStepMap,
            dailyGrowthEntries: dailyGrowthEntries,
            activityDayKeys: activityDayKeys,
            purchasedStoreItemIDs: Array(purchasedStoreItemIDs).sorted(),
            likedBibleVerseReferences: Array(likedBibleVerseReferences).sorted(),
            bibleVerseHighlights: bibleVerseHighlights,
            bibleVerseNotes: bibleVerseNotes,
            creativeCheckIns: creativeCheckIns,
            creationFeedPosts: creationFeedPosts,
            resetChallengeProgress: resetChallengeProgress,
            lastReadBibleLocation: lastReadBibleLocation
        )
    }

    func applySyncSnapshot(_ snapshot: UserProgressSyncSnapshot) {
        onboardingCompleted = snapshot.onboardingCompleted
        onboardingProfile = snapshot.onboardingProfile
        publicProfileSettings = snapshot.publicProfileSettings
        wisdomPoints = snapshot.wisdomPoints
        lessonProgressMap = snapshot.lessonProgressMap
        questAttempts = snapshot.questAttempts
        lessonNotes = snapshot.lessonNotes
        chapterReflections = snapshot.chapterReflections
        lessonStudyStepMap = snapshot.lessonStudyStepMap
        dailyGrowthEntries = snapshot.dailyGrowthEntries
        activityDayKeys = snapshot.activityDayKeys
        purchasedStoreItemIDs = Set(snapshot.purchasedStoreItemIDs)
        likedBibleVerseReferences = Set(snapshot.likedBibleVerseReferences)
        bibleVerseHighlights = Self.normalizedBibleVerseHighlights(snapshot.bibleVerseHighlights)
        bibleVerseNotes = snapshot.bibleVerseNotes
        creativeCheckIns = snapshot.creativeCheckIns
        creationFeedPosts = snapshot.creationFeedPosts
        resetChallengeProgress = snapshot.resetChallengeProgress ?? .empty
        lastReadBibleLocation = snapshot.lastReadBibleLocation
        upsertOnboardingLeadRecord(using: snapshot.onboardingProfile)
    }

    func markLessonCompleted(_ lesson: WisdomLesson) {
        guard isLessonUnlocked(lesson) else { return }
        markActiveToday()

        var state = progress(for: lesson)
        if !state.lessonCompleted {
            state.lessonCompleted = true
            state.completedAt = Date()
            lessonProgressMap[lesson.id] = state
            saveLessonStudyStep(for: lesson, step: lesson.slides.count)
            wisdomPoints += 40
            upsertOnboardingLeadRecord()
        }
    }

    func canTakeQuest(for lesson: WisdomLesson) -> Bool {
        let state = progress(for: lesson)
        return isLessonUnlocked(lesson) && state.lessonCompleted
    }

    @discardableResult
    func submitQuest(for lesson: WisdomLesson, answers: [String: Int]) -> QuestSubmissionResult {
        markActiveToday()
        let assessmentQuest = lesson.assessmentQuest
        let questions = assessmentQuest.questions
        let total = questions.count

        let correctCount = questions.reduce(0) { partial, question in
            let selected = answers[question.id]
            return partial + (selected == question.correctIndex ? 1 : 0)
        }

        let score = total == 0 ? 0 : Int((Double(correctCount) / Double(total)) * 100.0)
        let passed = score >= assessmentQuest.passingScore

        var state = progress(for: lesson)
        let alreadyPassed = state.quizPassed
        let previousBest = state.bestQuizScore

        state.quizAttempts += 1
        state.lastQuizScore = score
        state.bestQuizScore = max(state.bestQuizScore, score)

        var pointsEarned = 0

        if passed {
            state.quizPassed = true
            state.passedAt = Date()
            saveLessonStudyStep(for: lesson, step: lesson.slides.count)

            if !alreadyPassed {
                pointsEarned = 100
            } else if score > previousBest {
                pointsEarned = 20
            } else {
                pointsEarned = 10
            }
        } else {
            pointsEarned = 5
        }

        lessonProgressMap[lesson.id] = state
        wisdomPoints += pointsEarned

        questAttempts.insert(
            QuestAttempt(lessonID: lesson.id, score: score, passed: passed),
            at: 0
        )

        return QuestSubmissionResult(
            score: score,
            passed: passed,
            pointsEarned: pointsEarned,
            correctAnswers: correctCount,
            totalQuestions: total
        )
    }

    @discardableResult
    func saveLessonNote(for lesson: WisdomLesson, template: LessonNoteTemplate) -> NoteSaveResult {
        markActiveToday()
        let trimmedTruth = template.keyTruth.trimmed
        let trimmedVerse = template.keyVerse.trimmed
        let trimmedApplication = template.applicationToday.trimmed
        let trimmedPrayer = template.prayerResponse.trimmed

        guard !trimmedTruth.isEmpty || !trimmedVerse.isEmpty || !trimmedApplication.isEmpty || !trimmedPrayer.isEmpty else {
            return NoteSaveResult(saved: false, pointsEarned: 0)
        }

        if let existingIndex = lessonNotes.firstIndex(where: { $0.lessonID == lesson.id }) {
            lessonNotes[existingIndex].keyTruth = trimmedTruth
            lessonNotes[existingIndex].keyVerse = trimmedVerse
            lessonNotes[existingIndex].applicationToday = trimmedApplication
            lessonNotes[existingIndex].prayerResponse = trimmedPrayer
            lessonNotes[existingIndex].updatedAt = .now
            return NoteSaveResult(saved: true, pointsEarned: 0)
        } else {
            lessonNotes.append(
                LessonNote(
                    lessonID: lesson.id,
                    lessonOrder: lesson.order,
                    lessonTitle: lesson.title,
                    keyTruth: trimmedTruth,
                    keyVerse: trimmedVerse,
                    applicationToday: trimmedApplication,
                    prayerResponse: trimmedPrayer
                )
            )
            wisdomPoints += 15
            return NoteSaveResult(saved: true, pointsEarned: 15)
        }
    }

    func noteTemplate(for lesson: WisdomLesson) -> LessonNoteTemplate {
        guard let note = lessonNotes.first(where: { $0.lessonID == lesson.id }) else {
            return .empty
        }

        return LessonNoteTemplate(
            keyTruth: note.keyTruth,
            keyVerse: note.keyVerse,
            applicationToday: note.applicationToday,
            prayerResponse: note.prayerResponse
        )
    }

    @discardableResult
    func saveChapterReflection(for lesson: WisdomLesson, draft: ChapterReflectionDraft) -> ReflectionSaveResult {
        markActiveToday()

        var seenHighlights = Set<String>()
        let cleanedHighlights = draft.highlightedVerses
            .map(\.trimmed)
            .filter { !$0.isEmpty }
            .filter { seenHighlights.insert($0).inserted }
        let cleanedDraft = ChapterReflectionDraft(
            highlightedVerses: cleanedHighlights,
            stoodOut: draft.stoodOut.trimmed,
            godMessage: draft.godMessage.trimmed,
            application: draft.application.trimmed,
            learned: draft.learned.trimmed,
            questions: draft.questions.trimmed
        )

        guard cleanedDraft.hasRequiredFields else {
            return ReflectionSaveResult(saved: false, pointsEarned: 0)
        }

        if let existingIndex = chapterReflections.firstIndex(where: { $0.lessonID == lesson.id }) {
            chapterReflections[existingIndex].highlightedVerses = cleanedDraft.highlightedVerses
            chapterReflections[existingIndex].stoodOut = cleanedDraft.stoodOut
            chapterReflections[existingIndex].godMessage = cleanedDraft.godMessage
            chapterReflections[existingIndex].application = cleanedDraft.application
            chapterReflections[existingIndex].learned = cleanedDraft.learned
            chapterReflections[existingIndex].questions = cleanedDraft.questions
            chapterReflections[existingIndex].updatedAt = .now
            return ReflectionSaveResult(saved: true, pointsEarned: 0)
        } else {
            chapterReflections.append(
                ChapterReflection(
                    lessonID: lesson.id,
                    lessonOrder: lesson.order,
                    lessonTitle: lesson.title,
                    highlightedVerses: cleanedDraft.highlightedVerses,
                    stoodOut: cleanedDraft.stoodOut,
                    godMessage: cleanedDraft.godMessage,
                    application: cleanedDraft.application,
                    learned: cleanedDraft.learned,
                    questions: cleanedDraft.questions
                )
            )
            wisdomPoints += 20
            return ReflectionSaveResult(saved: true, pointsEarned: 20)
        }
    }

    func chapterReflectionDraft(for lesson: WisdomLesson) -> ChapterReflectionDraft {
        guard let reflection = chapterReflections.first(where: { $0.lessonID == lesson.id }) else {
            return .empty
        }

        return ChapterReflectionDraft(
            highlightedVerses: reflection.highlightedVerses,
            stoodOut: reflection.stoodOut,
            godMessage: reflection.godMessage,
            application: reflection.application,
            learned: reflection.learned,
            questions: reflection.questions
        )
    }

    func chapterReflections(matching query: String) -> [ChapterReflection] {
        let cleaned = query.trimmed.lowercased()
        guard !cleaned.isEmpty else { return sortedChapterReflections }
        return sortedChapterReflections.filter { $0.searchableText.contains(cleaned) }
    }

    func lessonStudyStep(for lesson: WisdomLesson) -> Int {
        let maxStep = max(0, lesson.slides.count)
        let saved = lessonStudyStepMap[lesson.id] ?? 0
        return min(max(0, saved), maxStep)
    }

    func saveLessonStudyStep(for lesson: WisdomLesson, step: Int) {
        let maxStep = max(0, lesson.slides.count)
        let clamped = min(max(0, step), maxStep)
        if lessonStudyStepMap[lesson.id] != clamped {
            lessonStudyStepMap[lesson.id] = clamped
        }
    }

    func notes(matching query: String) -> [LessonNote] {
        let cleaned = query.trimmed.lowercased()
        guard !cleaned.isEmpty else { return sortedLessonNotes }
        return sortedLessonNotes.filter { $0.searchableText.contains(cleaned) }
    }

    func addPrayerPost(topic: String, message: String) {
        markActiveToday()
        let cleanedTopic = topic.trimmed
        let cleanedMessage = message.trimmed
        guard !cleanedTopic.isEmpty && !cleanedMessage.isEmpty else { return }

        let displayName = onboardingProfile.fullName.trimmed.isEmpty ? "One Visioon User" : onboardingProfile.fullName.trimmed
        let handle = usernameHandle

        let post = PrayerFeedPost(
            authorName: displayName,
            handle: handle,
            prayerTopic: cleanedTopic,
            message: cleanedMessage,
            createdAt: .now,
            amens: Int.random(in: 0...3),
            didAmen: false
        )

        prayerFeedPosts.insert(post, at: 0)
        wisdomPoints += 10
    }

    func creativeCheckIn(for date: Date = .now) -> CreativeCheckIn {
        let key = dayKey(for: date)
        return creativeCheckIns.first(where: { $0.dayKey == key }) ?? CreativeCheckIn(dayKey: key)
    }

    func toggleCreativeHabit(_ habit: CreativeHabit, on date: Date = .now) {
        markActiveToday()
        var checkIn = creativeCheckIn(for: date)
        var habits = Set(checkIn.completedHabits)

        if habits.contains(habit) {
            habits.remove(habit)
        } else {
            habits.insert(habit)
        }

        checkIn.completedHabits = habits.sorted(by: { $0.rawValue < $1.rawValue })
        checkIn.updatedAt = .now
        upsertCreativeCheckIn(checkIn)
    }

    @discardableResult
    func saveCreativeReflection(_ text: String, on date: Date = .now) -> Bool {
        let cleaned = text.trimmed
        guard !cleaned.isEmpty else { return false }
        markActiveToday()

        var checkIn = creativeCheckIn(for: date)
        checkIn.reflection = cleaned
        checkIn.updatedAt = .now
        upsertCreativeCheckIn(checkIn)
        return true
    }

    @discardableResult
    func addCreationFeedPost(
        kind: CreationPostKind,
        caption: String,
        scriptureReference: String,
        imageDataItems: [Data]
    ) -> Bool {
        let cleanedCaption = caption.trimmed
        let cleanedReference = scriptureReference.trimmed
        guard !cleanedCaption.isEmpty else { return false }

        markActiveToday()

        let displayName = onboardingProfile.fullName.trimmed.isEmpty ? "One Visioon Creator" : onboardingProfile.fullName.trimmed
        let attachments = saveCreationAttachments(imageDataItems.prefix(3).map { $0 })

        creationFeedPosts.insert(
            CreationFeedPost(
                authorName: displayName,
                handle: usernameHandle,
                kind: kind,
                caption: cleanedCaption,
                scriptureReference: cleanedReference,
                createdAt: .now,
                hearts: Int.random(in: 8...36),
                didHeart: false,
                comments: [],
                attachmentFileNames: attachments
            ),
            at: 0
        )

        wisdomPoints += 12
        return true
    }

    func toggleCreationHeart(for postID: UUID) {
        guard let index = creationFeedPosts.firstIndex(where: { $0.id == postID }) else { return }
        markActiveToday()

        if creationFeedPosts[index].didHeart {
            creationFeedPosts[index].didHeart = false
            creationFeedPosts[index].hearts = max(0, creationFeedPosts[index].hearts - 1)
        } else {
            creationFeedPosts[index].didHeart = true
            creationFeedPosts[index].hearts += 1
        }
    }

    @discardableResult
    func addCreationComment(to postID: UUID, text: String) -> Bool {
        let cleaned = text.trimmed
        guard !cleaned.isEmpty,
              let index = creationFeedPosts.firstIndex(where: { $0.id == postID }) else {
            return false
        }

        markActiveToday()

        let displayName = onboardingProfile.fullName.trimmed.isEmpty ? "One Visioon User" : onboardingProfile.fullName.trimmed
        creationFeedPosts[index].comments.append(
            CreationFeedComment(
                authorName: displayName,
                handle: usernameHandle,
                text: cleaned
            )
        )
        return true
    }

    func creationAttachmentURL(for fileName: String) -> URL? {
        let cleaned = fileName.trimmed
        guard !cleaned.isEmpty else { return nil }
        return creationFeedAttachmentsDirectory()?.appendingPathComponent(cleaned)
    }

    func isStoreItemOwned(_ item: WisdomStoreItem) -> Bool {
        purchasedStoreItemIDs.contains(item.id)
    }

    func canPurchaseStoreItem(_ item: WisdomStoreItem) -> Bool {
        !isStoreItemOwned(item) && wisdomPoints >= item.pointsCost
    }

    @discardableResult
    func purchaseStoreItem(_ item: WisdomStoreItem) -> Bool {
        markActiveToday()
        guard !isStoreItemOwned(item) else { return false }
        guard wisdomPoints >= item.pointsCost else { return false }

        wisdomPoints -= item.pointsCost
        purchasedStoreItemIDs.insert(item.id)
        return true
    }

    func toggleAmen(for postID: UUID) {
        guard let index = prayerFeedPosts.firstIndex(where: { $0.id == postID }) else { return }

        if prayerFeedPosts[index].didAmen {
            prayerFeedPosts[index].didAmen = false
            prayerFeedPosts[index].amens = max(0, prayerFeedPosts[index].amens - 1)
        } else {
            prayerFeedPosts[index].didAmen = true
            prayerFeedPosts[index].amens += 1
        }
    }

    var usernameHandle: String {
        let cleaned = normalizeUsername(onboardingProfile.username)
        if cleaned.isEmpty { return "@onevisioon" }
        return "@\(cleaned)"
    }

    func saveLastReadBibleLocation(_ location: BibleLocation) {
        lastReadBibleLocation = location
        upsertOnboardingLeadRecord()
    }

    func isResetChallengeDayCompleted(_ day: Int) -> Bool {
        resetChallengeDaySet.contains(day)
    }

    func completeResetChallengeDay(_ day: Int) {
        guard (1...7).contains(day) else { return }
        markActiveToday()

        var progress = resetChallengeProgress.normalized
        if progress.startedAt == nil {
            progress.startedAt = .now
        }

        guard !progress.completedDays.contains(day) else { return }

        progress.completedDays.append(day)
        resetChallengeProgress = progress.normalized
        wisdomPoints += 8
    }

    func toggleResetChallengeDay(_ day: Int) {
        guard (1...7).contains(day) else { return }
        markActiveToday()

        var progress = resetChallengeProgress.normalized
        if progress.completedDays.contains(day) {
            progress.completedDays.removeAll(where: { $0 == day })
            if progress.completedDays.isEmpty {
                progress.startedAt = nil
            }
            resetChallengeProgress = progress.normalized
        } else {
            completeResetChallengeDay(day)
        }
    }

    func restartResetChallenge() {
        markActiveToday()
        resetChallengeProgress = ResetChallengeProgress(startedAt: .now, completedDays: [])
    }

    func isBibleVerseLiked(_ reference: String) -> Bool {
        likedBibleVerseReferences.contains(reference)
    }

    func toggleBibleVerseLike(_ reference: String) {
        let cleaned = reference.trimmed
        guard !cleaned.isEmpty else { return }
        markActiveToday()

        if likedBibleVerseReferences.contains(cleaned) {
            likedBibleVerseReferences.remove(cleaned)
        } else {
            likedBibleVerseReferences.insert(cleaned)
        }
    }

    func isBibleVerseHighlighted(_ reference: String) -> Bool {
        bibleVerseHighlightStyle(for: reference) != nil
    }

    func bibleVerseHighlightStyle(for reference: String) -> BibleHighlightStyle? {
        let cleaned = reference.trimmed
        guard !cleaned.isEmpty else { return nil }
        return bibleVerseHighlights.first(where: { $0.reference == cleaned })?.style
    }

    func setBibleVerseHighlight(_ references: [String], style: BibleHighlightStyle) {
        let cleanedReferences = Array(
            Set(references.map(\.trimmed).filter { !$0.isEmpty })
        ).sorted()
        guard !cleanedReferences.isEmpty else { return }
        markActiveToday()

        for reference in cleanedReferences {
            if let existingIndex = bibleVerseHighlights.firstIndex(where: { $0.reference == reference }) {
                bibleVerseHighlights[existingIndex].style = style
            } else {
                bibleVerseHighlights.append(
                    BibleVerseHighlight(reference: reference, style: style)
                )
            }
        }

        bibleVerseHighlights = Self.normalizedBibleVerseHighlights(bibleVerseHighlights)
    }

    func clearBibleVerseHighlight(_ references: [String]) {
        let cleanedReferences = Set(
            references.map(\.trimmed).filter { !$0.isEmpty }
        )
        guard !cleanedReferences.isEmpty else { return }
        markActiveToday()

        bibleVerseHighlights.removeAll(where: { cleanedReferences.contains($0.reference) })
    }

    func addBibleVerseNote(references: [String], text: String) -> Bool {
        let cleanedText = text.trimmed
        let cleanedReferences = Array(
            Set(references.map(\.trimmed).filter { !$0.isEmpty })
        ).sorted()

        guard !cleanedText.isEmpty, !cleanedReferences.isEmpty else { return false }
        markActiveToday()

        bibleVerseNotes.insert(
            BibleVerseNote(references: cleanedReferences, text: cleanedText),
            at: 0
        )
        return true
    }

    func updateBibleVerseNote(id: UUID, text: String) -> Bool {
        let cleanedText = text.trimmed
        guard !cleanedText.isEmpty,
              let noteIndex = bibleVerseNotes.firstIndex(where: { $0.id == id }) else {
            return false
        }

        markActiveToday()
        bibleVerseNotes[noteIndex].text = cleanedText
        bibleVerseNotes[noteIndex].updatedAt = .now
        return true
    }

    func removeBibleVerseNote(id: UUID) {
        guard bibleVerseNotes.contains(where: { $0.id == id }) else { return }
        markActiveToday()
        bibleVerseNotes.removeAll(where: { $0.id == id })
    }

    func hasBibleVerseNote(for reference: String) -> Bool {
        let cleaned = reference.trimmed
        guard !cleaned.isEmpty else { return false }
        return bibleVerseNotes.contains(where: { $0.references.contains(cleaned) })
    }

    func markActiveToday() {
        let todayKey = dayKey(for: .now)
        guard !activityDaySet.contains(todayKey) else { return }
        activityDayKeys.append(todayKey)
        upsertOnboardingLeadRecord()
    }

    func isActive(on date: Date) -> Bool {
        activityDaySet.contains(dayKey(for: date))
    }

    @discardableResult
    func addDailyGrowthEntry(learnedToday: String, applicationPlan: String, prayerAction: String) -> Bool {
        markActiveToday()
        guard canUseDailyCheckIn else { return false }
        guard !hasSubmittedDailyGrowthToday else { return false }

        let learned = learnedToday.trimmed
        let plan = applicationPlan.trimmed
        let prayer = prayerAction.trimmed

        guard !learned.isEmpty && !plan.isEmpty && !prayer.isEmpty else { return false }

        dailyGrowthEntries.insert(
            DailyGrowthEntry(
                learnedToday: learned,
                applicationPlan: plan,
                prayerAction: prayer
            ),
            at: 0
        )

        wisdomPoints += 25
        return true
    }

    func resetCourseProgress() {
        lessonProgressMap = [:]
        questAttempts = []
        wisdomPoints = 0
        lessonStudyStepMap = [:]
        dailyGrowthEntries = []
        activityDayKeys = []
    }

    private func normalizeLessonStudySteps() {
        var normalized = lessonStudyStepMap
        for lesson in allLessons {
            guard let value = lessonStudyStepMap[lesson.id] else { continue }
            let clamped = min(max(0, value), lesson.slides.count)
            normalized[lesson.id] = clamped
        }

        if normalized != lessonStudyStepMap {
            lessonStudyStepMap = normalized
        }
    }

    private func normalizeActivityKeys() {
        let cleaned = Array(Set(activityDayKeys))
            .filter { keyToDate($0) != nil }
            .sorted()
        if cleaned != activityDayKeys {
            activityDayKeys = cleaned
        }
    }

    private func lessons(containing lesson: WisdomLesson) -> [WisdomLesson] {
        guard let course = course(for: lesson) else { return lessons }
        return lessons(for: course)
    }

    private func course(for lesson: WisdomLesson) -> WisdomCourse? {
        allCourses.first { course in
            course.lessons.contains(where: { $0.id == lesson.id })
        }
    }

    private func persist<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private func upsertCreativeCheckIn(_ checkIn: CreativeCheckIn) {
        if let existingIndex = creativeCheckIns.firstIndex(where: { $0.dayKey == checkIn.dayKey }) {
            creativeCheckIns[existingIndex] = checkIn
        } else {
            creativeCheckIns.append(checkIn)
        }
    }

    private func creationFeedAttachmentsDirectory() -> URL? {
        guard let root = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let directory = root.appendingPathComponent("CreationFeedAttachments", isDirectory: true)
        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    private func saveCreationAttachments(_ imageDataItems: [Data]) -> [String] {
        guard let directory = creationFeedAttachmentsDirectory() else { return [] }

        return imageDataItems.compactMap { data in
            let fileName = "\(UUID().uuidString).jpg"
            let url = directory.appendingPathComponent(fileName)
            do {
                try data.write(to: url, options: .atomic)
                return fileName
            } catch {
                return nil
            }
        }
    }

    private static func normalizedBibleVerseHighlights(_ value: [BibleVerseHighlight]) -> [BibleVerseHighlight] {
        var deduped: [String: BibleVerseHighlight] = [:]
        for highlight in value {
            let cleanedReference = highlight.reference.trimmed
            guard !cleanedReference.isEmpty else { continue }
            deduped[cleanedReference] = BibleVerseHighlight(
                reference: cleanedReference,
                style: highlight.style
            )
        }

        return deduped.values.sorted(by: { $0.reference < $1.reference })
    }

    private func upsertOnboardingLeadRecord(using profile: OnboardingAnswerSet? = nil) {
        let profile = profile ?? onboardingProfile
        let cleanedEmail = profile.email.trimmed.lowercased()
        let cleanedUsername = profile.username.trimmed.lowercased()

        guard !cleanedEmail.isEmpty || !cleanedUsername.isEmpty else { return }

        let record = OnboardingLeadRecord(
            id: onboardingLeadSheet.first(where: { existing in
                if !cleanedEmail.isEmpty, existing.email.lowercased() == cleanedEmail {
                    return true
                }
                return !cleanedUsername.isEmpty && existing.username.lowercased() == cleanedUsername
            })?.id ?? UUID(),
            fullName: profile.fullName.trimmed,
            username: profile.username.trimmed,
            email: profile.email.trimmed,
            faithStage: profile.faithStage,
            selectedVersion: profile.selectedVersion,
            selectedPremiumPlan: profile.selectedPremiumPlan,
            currentStreak: currentStreak,
            totalActiveDays: totalActiveDays,
            completedLessons: completedLessonsCount,
            lastReadReference: lastReadBibleLocation.map { "\($0.book) \($0.chapter)" } ?? "",
            updatedAt: .now
        )

        if let existingIndex = onboardingLeadSheet.firstIndex(where: { $0.id == record.id }) {
            onboardingLeadSheet[existingIndex] = record
        } else {
            onboardingLeadSheet.insert(record, at: 0)
        }
    }

    private func applyOneTimeOnboardingResetIfNeeded() {
        guard defaults.string(forKey: DefaultsKey.onboardingResetMarker) != Self.onboardingResetToken else { return }

        onboardingProfile = .empty
        onboardingCompleted = false
        defaults.set(Self.onboardingResetToken, forKey: DefaultsKey.onboardingResetMarker)
    }

    private static func loadValue<T: Decodable>(_ defaults: UserDefaults, key: String, as type: T.Type) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private func normalizeUsername(_ value: String) -> String {
        let lowered = value.trimmed.lowercased()
        let allowed = lowered.filter { $0.isLetter || $0.isNumber || $0 == "_" || $0 == "." }
        return allowed.replacingOccurrences(of: "@", with: "")
    }

    private var calendar: Calendar {
        Calendar.current
    }

    private var activityDaySet: Set<String> {
        Set(activityDayKeys)
    }

    private var reflectionDaySet: Set<String> {
        Set(chapterReflections.map { dayKey(for: $0.createdAt) })
    }

    private var resetChallengeDaySet: Set<Int> {
        Set(resetChallengeProgress.completedDays.filter { (1...7).contains($0) })
    }

    private var sortedActivityDates: [Date] {
        activityDaySet.compactMap(keyToDate).sorted()
    }

    private func consecutiveDayStreak(for dayKeys: Set<String>) -> Int {
        guard let lastDate = dayKeys.compactMap(keyToDate).sorted().last else { return 0 }

        let today = calendar.startOfDay(for: .now)
        let daysSinceLast = calendar.dateComponents([.day], from: lastDate, to: today).day ?? 0
        if daysSinceLast > 1 { return 0 }

        var streak = 1
        var cursor = lastDate

        while let previous = calendar.date(byAdding: .day, value: -1, to: cursor),
              dayKeys.contains(dayKey(for: previous)) {
            streak += 1
            cursor = previous
        }

        return streak
    }

    private func dayKey(for date: Date) -> String {
        let startOfDay = calendar.startOfDay(for: date)
        return activityFormatter.string(from: startOfDay)
    }

    private func keyToDate(_ key: String) -> Date? {
        activityFormatter.date(from: key)
    }

    private var activityFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    private static let seedPrayerFeedPosts: [PrayerFeedPost] = [
        PrayerFeedPost(
            authorName: "Maria Santos",
            handle: "@marias",
            prayerTopic: "Family Peace",
            message: "Pray for unity in my home this week. We are working through tension with grace.",
            createdAt: Date().addingTimeInterval(-3600 * 5),
            amens: 19,
            didAmen: false
        ),
        PrayerFeedPost(
            authorName: "Daniel Reed",
            handle: "@danielreed",
            prayerTopic: "Work Discernment",
            message: "I need wisdom for a big work decision tomorrow. Pray for courage and clarity.",
            createdAt: Date().addingTimeInterval(-3600 * 11),
            amens: 27,
            didAmen: false
        ),
        PrayerFeedPost(
            authorName: "Hope Church Group",
            handle: "@hopegroup",
            prayerTopic: "Community",
            message: "Praying for everyone in this feed to hunger for Scripture today. Share your verse of the day.",
            createdAt: Date().addingTimeInterval(-3600 * 22),
            amens: 31,
            didAmen: false
        )
    ]

    private static let seedCreationFeedPosts: [CreationFeedPost] = [
        CreationFeedPost(
            authorName: "Maya Lin",
            handle: "@maya.creates",
            kind: .artwork,
            caption: "Painted a sunrise after praying through Psalm 19. I wanted the piece to feel like creation itself was preaching that the Lord is glorious.",
            scriptureReference: "Psalm 19:1",
            createdAt: Date().addingTimeInterval(-3600 * 4),
            hearts: 184,
            didHeart: false,
            comments: [
                CreationFeedComment(
                    authorName: "Ari",
                    handle: "@aripraises",
                    text: "This makes me want to worship. The Scripture tie-in is beautiful.",
                    createdAt: Date().addingTimeInterval(-3600 * 3)
                )
            ]
        ),
        CreationFeedPost(
            authorName: "Noah Reed",
            handle: "@noahwrites",
            kind: .lyrics,
            caption: "Started writing a chorus from John 1 tonight. Trying to keep the words simple enough to sing, but full of truth about Jesus being the Light.",
            scriptureReference: "John 1:5",
            createdAt: Date().addingTimeInterval(-3600 * 11),
            hearts: 129,
            didHeart: false,
            comments: [
                CreationFeedComment(
                    authorName: "Grace C.",
                    handle: "@gracecreates",
                    text: "Love this direction. That verse carries so much hope.",
                    createdAt: Date().addingTimeInterval(-3600 * 10)
                )
            ]
        ),
        CreationFeedPost(
            authorName: "Risen Canvas",
            handle: "@risencanvas",
            kind: .design,
            caption: "Working on a Scripture poster series that keeps Jesus at the center. Today's focus was making the design feel peaceful without losing boldness.",
            scriptureReference: "Colossians 3:17",
            createdAt: Date().addingTimeInterval(-3600 * 20),
            hearts: 203,
            didHeart: false,
            comments: []
        )
    ]

    private static let seedLeaderboardEntries: [LeaderboardEntry] = [
        LeaderboardEntry(
            id: "lb-elijah",
            displayName: "Elijah K.",
            handle: "@elijahk",
            lessonsCompleted: 27,
            points: 2240,
            isCurrentUser: false
        ),
        LeaderboardEntry(
            id: "lb-rachel",
            displayName: "Rachel M.",
            handle: "@rachelm",
            lessonsCompleted: 21,
            points: 1815,
            isCurrentUser: false
        ),
        LeaderboardEntry(
            id: "lb-jonas",
            displayName: "Jonas P.",
            handle: "@jonasp",
            lessonsCompleted: 18,
            points: 1490,
            isCurrentUser: false
        ),
        LeaderboardEntry(
            id: "lb-priya",
            displayName: "Priya S.",
            handle: "@priyas",
            lessonsCompleted: 14,
            points: 1210,
            isCurrentUser: false
        ),
        LeaderboardEntry(
            id: "lb-micah",
            displayName: "Micah T.",
            handle: "@micaht",
            lessonsCompleted: 11,
            points: 940,
            isCurrentUser: false
        )
    ]
}
