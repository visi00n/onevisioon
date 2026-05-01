import Foundation

struct OnboardingLeadRecord: Identifiable, Codable, Hashable {
    let id: UUID
    var fullName: String
    var username: String
    var email: String
    var faithStage: String
    var selectedVersion: String
    var selectedPremiumPlan: String
    var currentStreak: Int
    var totalActiveDays: Int
    var completedLessons: Int
    var lastReadReference: String
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        fullName: String,
        username: String,
        email: String,
        faithStage: String,
        selectedVersion: String,
        selectedPremiumPlan: String,
        currentStreak: Int,
        totalActiveDays: Int,
        completedLessons: Int,
        lastReadReference: String,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.fullName = fullName
        self.username = username
        self.email = email
        self.faithStage = faithStage
        self.selectedVersion = selectedVersion
        self.selectedPremiumPlan = selectedPremiumPlan
        self.currentStreak = currentStreak
        self.totalActiveDays = totalActiveDays
        self.completedLessons = completedLessons
        self.lastReadReference = lastReadReference
        self.updatedAt = updatedAt
    }
}
