import Foundation

struct UserProgressSyncSnapshot: Codable, Hashable {
    let schemaVersion: Int
    let exportedAt: Date
    let onboardingCompleted: Bool
    let onboardingProfile: OnboardingAnswerSet
    let publicProfileSettings: PublicProfileSettings
    let wisdomPoints: Int
    let lessonProgressMap: [String: LessonProgress]
    let questAttempts: [QuestAttempt]
    let lessonNotes: [LessonNote]
    let chapterReflections: [ChapterReflection]
    let lessonStudyStepMap: [String: Int]
    let dailyGrowthEntries: [DailyGrowthEntry]
    let activityDayKeys: [String]
    let purchasedStoreItemIDs: [String]
    let selectedBibleVersion: String?
    let likedBibleVerseReferences: [String]
    let bibleVerseHighlights: [BibleVerseHighlight]
    let bibleVerseNotes: [BibleVerseNote]
    let creativeCheckIns: [CreativeCheckIn]
    let creationFeedPosts: [CreationFeedPost]
    let giftDiscoveryProfile: GiftDiscoveryProfile?
    let giftTrainingCheckIns: [GiftTrainingCheckIn]?
    let glorifyReminderSettings: GlorifyReminderSettings?
    let resetChallengeProgress: ResetChallengeProgress?
    let lastReadBibleLocation: BibleLocation?

    static let currentSchemaVersion = 5
}
