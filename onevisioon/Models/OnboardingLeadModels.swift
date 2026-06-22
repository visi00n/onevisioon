import Foundation

struct OnboardingLeadRecord: Identifiable, Codable, Hashable {
    let id: UUID
    var fullName: String
    var username: String
    var email: String
    var age: String
    var country: String
    var usaAreaCode: String
    var gender: String
    var faithStage: String
    var currentSeason: String
    var currentStruggles: [String]
    var lifeVision: String
    var desiredGrowth: String
    var behindArea: String
    var ifNothingChangesFeeling: String
    var futureStrength: String
    var supportNeed: String
    var spiritualStruggle: String
    var readinessResponse: String
    var wantsNotifications: Bool
    var referralCode: String
    var heardAboutSource: String
    var selectedMindsetGoal: String
    var selectedHealthGoal: String
    var selectedPurposeGoal: String
    var selectedCommunityGoal: String
    var onboardingPotentialScore: Int
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
        age: String,
        country: String,
        usaAreaCode: String,
        gender: String,
        faithStage: String,
        currentSeason: String,
        currentStruggles: [String],
        lifeVision: String,
        desiredGrowth: String,
        behindArea: String,
        ifNothingChangesFeeling: String,
        futureStrength: String,
        supportNeed: String,
        spiritualStruggle: String,
        readinessResponse: String,
        wantsNotifications: Bool,
        referralCode: String,
        heardAboutSource: String,
        selectedMindsetGoal: String,
        selectedHealthGoal: String,
        selectedPurposeGoal: String,
        selectedCommunityGoal: String,
        onboardingPotentialScore: Int,
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
        self.age = age
        self.country = country
        self.usaAreaCode = usaAreaCode
        self.gender = gender
        self.faithStage = faithStage
        self.currentSeason = currentSeason
        self.currentStruggles = currentStruggles
        self.lifeVision = lifeVision
        self.desiredGrowth = desiredGrowth
        self.behindArea = behindArea
        self.ifNothingChangesFeeling = ifNothingChangesFeeling
        self.futureStrength = futureStrength
        self.supportNeed = supportNeed
        self.spiritualStruggle = spiritualStruggle
        self.readinessResponse = readinessResponse
        self.wantsNotifications = wantsNotifications
        self.referralCode = referralCode
        self.heardAboutSource = heardAboutSource
        self.selectedMindsetGoal = selectedMindsetGoal
        self.selectedHealthGoal = selectedHealthGoal
        self.selectedPurposeGoal = selectedPurposeGoal
        self.selectedCommunityGoal = selectedCommunityGoal
        self.onboardingPotentialScore = onboardingPotentialScore
        self.selectedVersion = selectedVersion
        self.selectedPremiumPlan = selectedPremiumPlan
        self.currentStreak = currentStreak
        self.totalActiveDays = totalActiveDays
        self.completedLessons = completedLessons
        self.lastReadReference = lastReadReference
        self.updatedAt = updatedAt
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case fullName
        case username
        case email
        case age
        case country
        case usaAreaCode
        case gender
        case faithStage
        case currentSeason
        case currentStruggles
        case lifeVision
        case desiredGrowth
        case behindArea
        case ifNothingChangesFeeling
        case futureStrength
        case supportNeed
        case spiritualStruggle
        case readinessResponse
        case wantsNotifications
        case referralCode
        case heardAboutSource
        case selectedMindsetGoal
        case selectedHealthGoal
        case selectedPurposeGoal
        case selectedCommunityGoal
        case onboardingPotentialScore
        case selectedVersion
        case selectedPremiumPlan
        case currentStreak
        case totalActiveDays
        case completedLessons
        case lastReadReference
        case updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        fullName = try container.decodeIfPresent(String.self, forKey: .fullName) ?? ""
        username = try container.decodeIfPresent(String.self, forKey: .username) ?? ""
        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        age = try container.decodeIfPresent(String.self, forKey: .age) ?? ""
        country = try container.decodeIfPresent(String.self, forKey: .country) ?? ""
        usaAreaCode = try container.decodeIfPresent(String.self, forKey: .usaAreaCode) ?? ""
        gender = try container.decodeIfPresent(String.self, forKey: .gender) ?? ""
        faithStage = try container.decodeIfPresent(String.self, forKey: .faithStage) ?? ""
        currentSeason = try container.decodeIfPresent(String.self, forKey: .currentSeason) ?? ""
        currentStruggles = try container.decodeIfPresent([String].self, forKey: .currentStruggles) ?? []
        lifeVision = try container.decodeIfPresent(String.self, forKey: .lifeVision) ?? ""
        desiredGrowth = try container.decodeIfPresent(String.self, forKey: .desiredGrowth) ?? ""
        behindArea = try container.decodeIfPresent(String.self, forKey: .behindArea) ?? ""
        ifNothingChangesFeeling = try container.decodeIfPresent(String.self, forKey: .ifNothingChangesFeeling) ?? ""
        futureStrength = try container.decodeIfPresent(String.self, forKey: .futureStrength) ?? ""
        supportNeed = try container.decodeIfPresent(String.self, forKey: .supportNeed) ?? ""
        spiritualStruggle = try container.decodeIfPresent(String.self, forKey: .spiritualStruggle) ?? ""
        readinessResponse = try container.decodeIfPresent(String.self, forKey: .readinessResponse) ?? ""
        wantsNotifications = try container.decodeIfPresent(Bool.self, forKey: .wantsNotifications) ?? false
        referralCode = try container.decodeIfPresent(String.self, forKey: .referralCode) ?? ""
        heardAboutSource = try container.decodeIfPresent(String.self, forKey: .heardAboutSource) ?? ""
        selectedMindsetGoal = try container.decodeIfPresent(String.self, forKey: .selectedMindsetGoal) ?? ""
        selectedHealthGoal = try container.decodeIfPresent(String.self, forKey: .selectedHealthGoal) ?? ""
        selectedPurposeGoal = try container.decodeIfPresent(String.self, forKey: .selectedPurposeGoal) ?? ""
        selectedCommunityGoal = try container.decodeIfPresent(String.self, forKey: .selectedCommunityGoal) ?? ""
        onboardingPotentialScore = try container.decodeIfPresent(Int.self, forKey: .onboardingPotentialScore) ?? 0
        selectedVersion = try container.decodeIfPresent(String.self, forKey: .selectedVersion) ?? ""
        selectedPremiumPlan = try container.decodeIfPresent(String.self, forKey: .selectedPremiumPlan) ?? ""
        currentStreak = try container.decodeIfPresent(Int.self, forKey: .currentStreak) ?? 0
        totalActiveDays = try container.decodeIfPresent(Int.self, forKey: .totalActiveDays) ?? 0
        completedLessons = try container.decodeIfPresent(Int.self, forKey: .completedLessons) ?? 0
        lastReadReference = try container.decodeIfPresent(String.self, forKey: .lastReadReference) ?? ""
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? .now
    }
}
