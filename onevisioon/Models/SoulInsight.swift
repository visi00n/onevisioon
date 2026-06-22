import Foundation

struct OnboardingAnswerSet: Codable, Hashable {
    var fullName: String
    var username: String
    var email: String
    var age: String
    var country: String
    var usaAreaCode: String
    var gender: String
    var faithStage: String
    var biggestChallenge: String
    var scriptureRhythm: String
    var prayerRhythm: String
    var learningStyle: String
    var weeklyCommitment: String
    var reminderWindow: String
    var selectedVersion: String
    var selectedPremiumPlan: String
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

    static let empty = OnboardingAnswerSet(
        fullName: "",
        username: "",
        email: "",
        age: "",
        country: "",
        usaAreaCode: "",
        gender: "",
        faithStage: "",
        biggestChallenge: "",
        scriptureRhythm: "",
        prayerRhythm: "",
        learningStyle: "",
        weeklyCommitment: "",
        reminderWindow: "",
        selectedVersion: "",
        selectedPremiumPlan: "",
        currentSeason: "",
        currentStruggles: [],
        lifeVision: "",
        desiredGrowth: "",
        behindArea: "",
        ifNothingChangesFeeling: "",
        futureStrength: "",
        supportNeed: "",
        spiritualStruggle: "",
        readinessResponse: "",
        wantsNotifications: false,
        referralCode: "",
        heardAboutSource: "",
        selectedMindsetGoal: "",
        selectedHealthGoal: "",
        selectedPurposeGoal: "",
        selectedCommunityGoal: "",
        onboardingPotentialScore: 0
    )

    init(
        fullName: String,
        username: String,
        email: String,
        age: String,
        country: String,
        usaAreaCode: String,
        gender: String,
        faithStage: String,
        biggestChallenge: String,
        scriptureRhythm: String,
        prayerRhythm: String,
        learningStyle: String,
        weeklyCommitment: String,
        reminderWindow: String,
        selectedVersion: String,
        selectedPremiumPlan: String,
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
        onboardingPotentialScore: Int
    ) {
        self.fullName = fullName
        self.username = username
        self.email = email
        self.age = age
        self.country = country
        self.usaAreaCode = usaAreaCode
        self.gender = gender
        self.faithStage = faithStage
        self.biggestChallenge = biggestChallenge
        self.scriptureRhythm = scriptureRhythm
        self.prayerRhythm = prayerRhythm
        self.learningStyle = learningStyle
        self.weeklyCommitment = weeklyCommitment
        self.reminderWindow = reminderWindow
        self.selectedVersion = selectedVersion
        self.selectedPremiumPlan = selectedPremiumPlan
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
    }

    private enum CodingKeys: String, CodingKey {
        case fullName
        case username
        case email
        case age
        case country
        case usaAreaCode
        case gender
        case faithStage
        case biggestChallenge
        case scriptureRhythm
        case prayerRhythm
        case learningStyle
        case weeklyCommitment
        case reminderWindow
        case selectedVersion
        case selectedPremiumPlan
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
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fullName = try container.decodeIfPresent(String.self, forKey: .fullName) ?? ""
        username = try container.decodeIfPresent(String.self, forKey: .username) ?? ""
        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        age = try container.decodeIfPresent(String.self, forKey: .age) ?? ""
        country = try container.decodeIfPresent(String.self, forKey: .country) ?? ""
        usaAreaCode = try container.decodeIfPresent(String.self, forKey: .usaAreaCode) ?? ""
        gender = try container.decodeIfPresent(String.self, forKey: .gender) ?? ""
        faithStage = try container.decodeIfPresent(String.self, forKey: .faithStage) ?? ""
        biggestChallenge = try container.decodeIfPresent(String.self, forKey: .biggestChallenge) ?? ""
        scriptureRhythm = try container.decodeIfPresent(String.self, forKey: .scriptureRhythm) ?? ""
        prayerRhythm = try container.decodeIfPresent(String.self, forKey: .prayerRhythm) ?? ""
        learningStyle = try container.decodeIfPresent(String.self, forKey: .learningStyle) ?? ""
        weeklyCommitment = try container.decodeIfPresent(String.self, forKey: .weeklyCommitment) ?? ""
        reminderWindow = try container.decodeIfPresent(String.self, forKey: .reminderWindow) ?? ""
        selectedVersion = try container.decodeIfPresent(String.self, forKey: .selectedVersion) ?? ""
        selectedPremiumPlan = try container.decodeIfPresent(String.self, forKey: .selectedPremiumPlan) ?? ""
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
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fullName, forKey: .fullName)
        try container.encode(username, forKey: .username)
        try container.encode(email, forKey: .email)
        try container.encode(age, forKey: .age)
        try container.encode(country, forKey: .country)
        try container.encode(usaAreaCode, forKey: .usaAreaCode)
        try container.encode(gender, forKey: .gender)
        try container.encode(faithStage, forKey: .faithStage)
        try container.encode(biggestChallenge, forKey: .biggestChallenge)
        try container.encode(scriptureRhythm, forKey: .scriptureRhythm)
        try container.encode(prayerRhythm, forKey: .prayerRhythm)
        try container.encode(learningStyle, forKey: .learningStyle)
        try container.encode(weeklyCommitment, forKey: .weeklyCommitment)
        try container.encode(reminderWindow, forKey: .reminderWindow)
        try container.encode(selectedVersion, forKey: .selectedVersion)
        try container.encode(selectedPremiumPlan, forKey: .selectedPremiumPlan)
        try container.encode(currentSeason, forKey: .currentSeason)
        try container.encode(currentStruggles, forKey: .currentStruggles)
        try container.encode(lifeVision, forKey: .lifeVision)
        try container.encode(desiredGrowth, forKey: .desiredGrowth)
        try container.encode(behindArea, forKey: .behindArea)
        try container.encode(ifNothingChangesFeeling, forKey: .ifNothingChangesFeeling)
        try container.encode(futureStrength, forKey: .futureStrength)
        try container.encode(supportNeed, forKey: .supportNeed)
        try container.encode(spiritualStruggle, forKey: .spiritualStruggle)
        try container.encode(readinessResponse, forKey: .readinessResponse)
        try container.encode(wantsNotifications, forKey: .wantsNotifications)
        try container.encode(referralCode, forKey: .referralCode)
        try container.encode(heardAboutSource, forKey: .heardAboutSource)
        try container.encode(selectedMindsetGoal, forKey: .selectedMindsetGoal)
        try container.encode(selectedHealthGoal, forKey: .selectedHealthGoal)
        try container.encode(selectedPurposeGoal, forKey: .selectedPurposeGoal)
        try container.encode(selectedCommunityGoal, forKey: .selectedCommunityGoal)
        try container.encode(onboardingPotentialScore, forKey: .onboardingPotentialScore)
    }
}

struct PublicProfileSettings: Codable, Hashable {
    var isPublic: Bool
    var showWisdomLevel: Bool
    var testimonial: String
    var instagram: String
    var xHandle: String
    var youtube: String

    static let empty = PublicProfileSettings(
        isPublic: false,
        showWisdomLevel: true,
        testimonial: "",
        instagram: "",
        xHandle: "",
        youtube: ""
    )
}

struct WisdomQuestion: Identifiable, Hashable, Codable {
    let id: String
    let prompt: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

struct LessonSlide: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let body: String
    let bullets: [String]
    let supportVerse: String
    let reflectionPrompt: String
}

struct WisdomQuest: Hashable, Codable {
    let passingScore: Int
    let questions: [WisdomQuestion]
}

struct WisdomLesson: Identifiable, Hashable, Codable {
    let id: String
    let order: Int
    let title: String
    let sourceName: String
    let sourceURL: String
    let summary: String
    let keyIdeas: [String]
    let keyVerses: [String]
    let quest: WisdomQuest
}

struct WisdomCourse: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let subtitle: String
    let outcomes: [String]
    let lessons: [WisdomLesson]

    static let biblicalWisdomFoundations = WisdomCourse(
        id: "biblical-wisdom-foundations",
        title: "Biblical Wisdom Foundations",
        subtitle: "A guided path from knowledge to godly discernment.",
        outcomes: [
            "Understand what biblical wisdom is and is not.",
            "Practice daily discernment rooted in Scripture.",
            "Build habits of prayer, reflection, and obedience."
        ],
        lessons: [
            WisdomLesson(
                id: "ligonier-definition",
                order: 1,
                title: "What Is Wisdom?",
                sourceName: "Ligonier",
                sourceURL: "https://learn.ligonier.org/articles/virtues-vices-wisdom",
                summary: "Biblical wisdom is not raw intelligence. It is truth applied in real situations for godly ends.",
                keyIdeas: [
                    "The fear of the Lord is the beginning of wisdom (reverent awe, not panic).",
                    "Wisdom and folly are moral directions, not merely IQ differences.",
                    "Wisdom grows through humility, teachability, and Scripture-shaped judgment."
                ],
                keyVerses: ["Proverbs 1:7", "James 3:17", "Matthew 7:24"],
                quest: WisdomQuest(
                    passingScore: 67,
                    questions: [
                        WisdomQuestion(
                            id: "l1q1",
                            prompt: "Which definition best matches biblical wisdom?",
                            options: [
                                "Winning arguments with strong logic",
                                "Truth applied in specific situations for godly ends",
                                "Collecting many Bible facts",
                                "Avoiding hard decisions"
                            ],
                            correctIndex: 1,
                            explanation: "The article defines wisdom as applied truth oriented toward godly outcomes."
                        ),
                        WisdomQuestion(
                            id: "l1q2",
                            prompt: "In Proverbs, the fear of the Lord primarily means:",
                            options: [
                                "Constant dread",
                                "Reverent awe and humble submission",
                                "Blind superstition",
                                "Withdrawal from society"
                            ],
                            correctIndex: 1,
                            explanation: "Biblical fear is reverence that places God at the center of decision-making."
                        ),
                        WisdomQuestion(
                            id: "l1q3",
                            prompt: "According to wisdom literature, a fool is often someone who:",
                            options: [
                                "Never went to school",
                                "Has no opinions",
                                "Is right in his own eyes and rejects instruction",
                                "Speaks very little"
                            ],
                            correctIndex: 2,
                            explanation: "Folly in Scripture is usually self-trusting stubbornness, not lack of data."
                        )
                    ]
                )
            ),
            WisdomLesson(
                id: "james3-characteristics",
                order: 2,
                title: "Wisdom from Above (James 3)",
                sourceName: "Dial In Ministries",
                sourceURL: "https://dialinministries.org/biblical-wisdom-explained-8-characteristics-of-true-wisdom-from-james-3-jonny-ardavanis/",
                summary: "James contrasts godly wisdom with worldly wisdom and gives practical marks of each.",
                keyIdeas: [
                    "Godly wisdom is pure, peaceable, gentle, open to reason, merciful, fruitful, impartial, sincere.",
                    "Worldly wisdom is self-promoting and leads to disorder.",
                    "Wisdom is received from God and practiced through humble service."
                ],
                keyVerses: ["James 3:13-18", "Proverbs 1:7", "James 1:5"],
                quest: WisdomQuest(
                    passingScore: 67,
                    questions: [
                        WisdomQuestion(
                            id: "l2q1",
                            prompt: "Which option lists a trait from James 3 wisdom-from-above?",
                            options: [
                                "Self-ambition",
                                "Harsh domination",
                                "Peaceable gentleness",
                                "Manipulative speech"
                            ],
                            correctIndex: 2,
                            explanation: "James describes wisdom from above as peaceable and gentle."
                        ),
                        WisdomQuestion(
                            id: "l2q2",
                            prompt: "What is a major fruit of worldly wisdom in James 3?",
                            options: [
                                "Order and peace",
                                "Disorder and selfish conflict",
                                "Joyful unity",
                                "Patient endurance"
                            ],
                            correctIndex: 1,
                            explanation: "James ties selfish ambition to disorder and every vile practice."
                        ),
                        WisdomQuestion(
                            id: "l2q3",
                            prompt: "One practical way to grow in wisdom highlighted in this lesson is:",
                            options: [
                                "Avoid prayer and rely on instinct",
                                "Pray and apply Scripture in daily choices",
                                "Outperform others",
                                "Keep wisdom private"
                            ],
                            correctIndex: 1,
                            explanation: "Biblical wisdom is formed through prayerful, applied obedience."
                        )
                    ]
                )
            ),
            WisdomLesson(
                id: "crossway-key-verses",
                order: 3,
                title: "10 Key Verses on Wisdom and Discernment",
                sourceName: "Crossway",
                sourceURL: "https://www.crossway.org/articles/10-key-bible-verses-on-wisdom-and-discernment/",
                summary: "Scripture gives a practical framework for discernment in modern decisions.",
                keyIdeas: [
                    "Wisdom begins with reverence for God, not self-confidence.",
                    "Believers ask God for wisdom and test what is pleasing to Him.",
                    "Discernment requires mind renewal and active obedience."
                ],
                keyVerses: ["Proverbs 3:5-6", "James 1:5", "Romans 12:2", "Matthew 7:24"],
                quest: WisdomQuest(
                    passingScore: 67,
                    questions: [
                        WisdomQuestion(
                            id: "l3q1",
                            prompt: "Which verse explicitly invites believers to ask God for wisdom?",
                            options: [
                                "Romans 11:33",
                                "James 1:5",
                                "1 John 4:1",
                                "Philippians 1:9"
                            ],
                            correctIndex: 1,
                            explanation: "James 1:5 calls believers to ask God, who gives generously."
                        ),
                        WisdomQuestion(
                            id: "l3q2",
                            prompt: "Romans 12:2 teaches discernment flows from:",
                            options: [
                                "Conforming to culture",
                                "Renewal of the mind",
                                "Avoiding all decisions",
                                "Following trends"
                            ],
                            correctIndex: 1,
                            explanation: "Discernment grows as the mind is transformed by God."
                        ),
                        WisdomQuestion(
                            id: "l3q3",
                            prompt: "Jesus compares the wise person to someone who:",
                            options: [
                                "Hears and ignores His words",
                                "Builds on sand",
                                "Hears and does His words",
                                "Avoids building entirely"
                            ],
                            correctIndex: 2,
                            explanation: "In Matthew 7, wisdom is hearing and obeying Jesus."
                        )
                    ]
                )
            ),
            WisdomLesson(
                id: "bibleproject-wisdom-books",
                order: 4,
                title: "Wisdom Literature Lens",
                sourceName: "BibleProject",
                sourceURL: "https://bibleproject.com/explore/video/wisdom-series/",
                summary: "The wisdom books train us to pursue the good life before God through different perspectives.",
                keyIdeas: [
                    "Proverbs, Ecclesiastes, and Job each address the search for meaning.",
                    "Wisdom is not simplistic; it handles both order and ambiguity in life.",
                    "The goal is faithful living, not control of outcomes."
                ],
                keyVerses: ["Proverbs 9:10", "Ecclesiastes 12:13", "Job 28:28"],
                quest: WisdomQuest(
                    passingScore: 67,
                    questions: [
                        WisdomQuestion(
                            id: "l4q1",
                            prompt: "Which books are central in BibleProject's wisdom collection?",
                            options: [
                                "Joshua, Judges, Ruth",
                                "Proverbs, Ecclesiastes, Job",
                                "Isaiah, Jeremiah, Lamentations",
                                "Matthew, Mark, Luke"
                            ],
                            correctIndex: 1,
                            explanation: "The wisdom series centers on Proverbs, Ecclesiastes, and Job."
                        ),
                        WisdomQuestion(
                            id: "l4q2",
                            prompt: "What question do wisdom books repeatedly address?",
                            options: [
                                "How to become politically powerful",
                                "How to live a good life before God",
                                "How to avoid all suffering",
                                "How to ignore uncertainty"
                            ],
                            correctIndex: 1,
                            explanation: "Biblical wisdom is practical guidance for faithful living."
                        ),
                        WisdomQuestion(
                            id: "l4q3",
                            prompt: "Ecclesiastes especially helps believers:",
                            options: [
                                "Pretend life is predictable",
                                "Handle life's uncertainty with reverent hope",
                                "Reject all planning",
                                "Avoid joy"
                            ],
                            correctIndex: 1,
                            explanation: "Ecclesiastes teaches humility within life's limits and uncertainty."
                        )
                    ]
                )
            ),
            WisdomLesson(
                id: "desiringgod-practice",
                order: 5,
                title: "Practices for Growing in Wisdom",
                sourceName: "Desiring God",
                sourceURL: "https://www.desiringgod.org/interviews/five-ways-to-find-wisdom",
                summary: "Wisdom is cultivated through repeated habits and centered in Christ.",
                keyIdeas: [
                    "Small daily practices compound over time.",
                    "Prayer and mortality-awareness sharpen wise priorities.",
                    "In Christ are the treasures of wisdom and knowledge."
                ],
                keyVerses: ["Psalm 90:12", "Colossians 2:3", "James 1:5"],
                quest: WisdomQuest(
                    passingScore: 67,
                    questions: [
                        WisdomQuestion(
                            id: "l5q1",
                            prompt: "Psalm 90:12 connects wisdom with learning to:",
                            options: [
                                "Count achievements",
                                "Number our days",
                                "Avoid responsibility",
                                "Win debates"
                            ],
                            correctIndex: 1,
                            explanation: "Numbering our days produces urgency and wise living."
                        ),
                        WisdomQuestion(
                            id: "l5q2",
                            prompt: "Colossians 2:3 says treasures of wisdom are found in:",
                            options: [
                                "Famous teachers",
                                "Personal experience alone",
                                "Christ",
                                "Cultural success"
                            ],
                            correctIndex: 2,
                            explanation: "Christian wisdom is ultimately Christ-centered."
                        ),
                        WisdomQuestion(
                            id: "l5q3",
                            prompt: "A core growth strategy emphasized in this lesson is:",
                            options: [
                                "One dramatic change only",
                                "Many small faithful practices over time",
                                "Avoiding community",
                                "Suppressing questions"
                            ],
                            correctIndex: 1,
                            explanation: "Wisdom forms through repeated faithful steps."
                        )
                    ]
                )
            ),
            WisdomLesson(
                id: "billygraham-knowledge-vs-wisdom",
                order: 6,
                title: "Knowledge vs. Wisdom",
                sourceName: "Billy Graham Evangelistic Association",
                sourceURL: "https://billygraham.org/answers/arent-knowledge-and-wisdom-different",
                summary: "Knowledge gathers facts; wisdom applies them with discernment and godly judgment.",
                keyIdeas: [
                    "Knowledge without godly direction can be misused.",
                    "Wisdom requires discernment, judgment, and moral grounding.",
                    "God's Word is the true source for rightly applied knowledge."
                ],
                keyVerses: ["Proverbs 2:6", "Psalm 119:65-66", "Proverbs 8"],
                quest: WisdomQuest(
                    passingScore: 67,
                    questions: [
                        WisdomQuestion(
                            id: "l6q1",
                            prompt: "According to this lesson, knowledge is primarily:",
                            options: [
                                "Fact-finding",
                                "Automatic maturity",
                                "Moral perfection",
                                "Guaranteed discernment"
                            ],
                            correctIndex: 0,
                            explanation: "The source distinguishes knowledge gathering from wisdom application."
                        ),
                        WisdomQuestion(
                            id: "l6q2",
                            prompt: "Wisdom is best described as:",
                            options: [
                                "Applying knowledge with discernment and judgment",
                                "Avoiding all complexity",
                                "Following instincts only",
                                "Copying majority opinion"
                            ],
                            correctIndex: 0,
                            explanation: "Wisdom is practical and moral application, not mere accumulation."
                        ),
                        WisdomQuestion(
                            id: "l6q3",
                            prompt: "Where should believers turn to learn true knowledge and wisdom?",
                            options: [
                                "Social trends",
                                "God's Word",
                                "Personal charisma",
                                "Financial success"
                            ],
                            correctIndex: 1,
                            explanation: "Scripture is presented as the reliable guide for application."
                        )
                    ]
                )
            ),
            WisdomLesson(
                id: "tn-biblecollege-importance",
                order: 7,
                title: "The Importance of Wisdom in Daily Walk",
                sourceName: "Tennessee Bible College",
                sourceURL: "https://www.tn-biblecollege.edu/the-importance-of-wisdom/",
                summary: "Wisdom is reverent obedience in everyday life, produced by Scripture and prayer.",
                keyIdeas: [
                    "Wise people display meekness, purity, mercy, and sincerity.",
                    "Wisdom is needed in every season, not only crisis moments.",
                    "We grow in wisdom through studying Scripture and asking God."
                ],
                keyVerses: ["James 3:13-17", "Proverbs 1:7", "2 Timothy 3:15", "James 1:5"],
                quest: WisdomQuest(
                    passingScore: 67,
                    questions: [
                        WisdomQuestion(
                            id: "l7q1",
                            prompt: "James 3 describes the wise person as marked by:",
                            options: [
                                "Meekness and good conduct",
                                "Aggressive self-promotion",
                                "Impatience",
                                "Hypocrisy"
                            ],
                            correctIndex: 0,
                            explanation: "James ties wisdom to character and conduct, not image management."
                        ),
                        WisdomQuestion(
                            id: "l7q2",
                            prompt: "Proverbs 1:7 in this lesson teaches wisdom begins with:",
                            options: [
                                "Social influence",
                                "Fear of the Lord",
                                "Natural talent",
                                "Fast decision-making"
                            ],
                            correctIndex: 1,
                            explanation: "Reverence for God is the beginning point for wise living."
                        ),
                        WisdomQuestion(
                            id: "l7q3",
                            prompt: "A central method for becoming wiser is to:",
                            options: [
                                "Rely on personality",
                                "Study Scripture and pray for wisdom",
                                "Avoid difficult people",
                                "Ignore correction"
                            ],
                            correctIndex: 1,
                            explanation: "The article points to God's Word and prayer as the growth path."
                        )
                    ]
                )
            ),
            WisdomLesson(
                id: "ligonier-proverbs",
                order: 8,
                title: "Proverbs: Skill for Faithful Living",
                sourceName: "Ligonier",
                sourceURL: "https://learn.ligonier.org/articles/proverbs",
                summary: "Proverbs trains believers in practical godliness, not shortcuts. Wisdom learns patterns from God and applies them with humility.",
                keyIdeas: [
                    "Wisdom in Proverbs is skill for living under God's rule, not mere mental knowledge.",
                    "Wise people are teachable and receive correction, while fools reject instruction.",
                    "Proverbs offers general principles that require discernment and context when applied."
                ],
                keyVerses: ["Proverbs 1:7", "Proverbs 15:22", "Proverbs 26:4-5"],
                quest: WisdomQuest(
                    passingScore: 67,
                    questions: [
                        WisdomQuestion(
                            id: "l8q1",
                            prompt: "In Proverbs, wisdom is best understood as:",
                            options: [
                                "A promise of an easy life",
                                "Skillful godly living",
                                "Winning every argument",
                                "Avoiding hard choices"
                            ],
                            correctIndex: 1,
                            explanation: "Proverbs presents wisdom as practical skill for living before God."
                        ),
                        WisdomQuestion(
                            id: "l8q2",
                            prompt: "How should a wise person respond to correction?",
                            options: [
                                "Defend themselves immediately",
                                "Ignore it",
                                "Receive and examine it humbly",
                                "Mock the person giving it"
                            ],
                            correctIndex: 2,
                            explanation: "Teachability is a repeated mark of wisdom in Proverbs."
                        ),
                        WisdomQuestion(
                            id: "l8q3",
                            prompt: "Why do Proverbs 26:4-5 require discernment?",
                            options: [
                                "They contradict Scripture",
                                "They show wisdom principles are always context-free",
                                "They show wise responses depend on the situation",
                                "They only apply to kings"
                            ],
                            correctIndex: 2,
                            explanation: "Wisdom applies principles in context, not mechanical formulas."
                        )
                    ]
                )
            ),
            WisdomLesson(
                id: "ligonier-wisdom-knowledge",
                order: 9,
                title: "Wisdom and Knowledge Together",
                sourceName: "Ligonier",
                sourceURL: "https://learn.ligonier.org/articles/wisdom-and-knowledge",
                summary: "Knowledge and wisdom belong together: knowledge gathers truth, wisdom applies truth for holy living.",
                keyIdeas: [
                    "Knowledge gives understanding of facts; wisdom gives right use of those facts.",
                    "Biblical wisdom is not anti-intellectual, but it is more than information.",
                    "Growth requires both study and Spirit-shaped obedience."
                ],
                keyVerses: ["Proverbs 2:6", "Ecclesiastes 7:12", "Colossians 1:9"],
                quest: WisdomQuest(
                    passingScore: 67,
                    questions: [
                        WisdomQuestion(
                            id: "l9q1",
                            prompt: "What is the key distinction in this lesson?",
                            options: [
                                "Knowledge is bad, wisdom is good",
                                "Knowledge gathers; wisdom applies rightly",
                                "Wisdom ignores doctrine",
                                "Knowledge replaces obedience"
                            ],
                            correctIndex: 1,
                            explanation: "The lesson emphasizes distinction without separation."
                        ),
                        WisdomQuestion(
                            id: "l9q2",
                            prompt: "Which statement reflects a biblical view of thinking?",
                            options: [
                                "Faith means shutting off the mind",
                                "Study and obedience should be integrated",
                                "Only scholars need wisdom",
                                "Knowledge is optional for discipleship"
                            ],
                            correctIndex: 1,
                            explanation: "Christian growth requires understanding and faithful practice."
                        ),
                        WisdomQuestion(
                            id: "l9q3",
                            prompt: "A wise use of knowledge looks like:",
                            options: [
                                "Using truth to serve and obey God",
                                "Collecting facts to impress others",
                                "Avoiding difficult moral choices",
                                "Separating doctrine from daily life"
                            ],
                            correctIndex: 0,
                            explanation: "Wisdom directs knowledge toward love, holiness, and service."
                        )
                    ]
                )
            ),
            WisdomLesson(
                id: "crossway-proverbs-1-7",
                order: 10,
                title: "Fear of the Lord and Discernment",
                sourceName: "Crossway",
                sourceURL: "https://www.crossway.org/articles/what-does-proverbs-17-mean/",
                summary: "The fear of the Lord is reverent trust and submission that shapes how we evaluate choices, people, and desires.",
                keyIdeas: [
                    "Fear of the Lord includes awe, trust, love, and obedience.",
                    "Discernment starts with humility, not self-certainty.",
                    "Wise decisions flow from Scripture-informed priorities."
                ],
                keyVerses: ["Proverbs 1:7", "Proverbs 3:5-6", "Psalm 25:9"],
                quest: WisdomQuest(
                    passingScore: 67,
                    questions: [
                        WisdomQuestion(
                            id: "l10q1",
                            prompt: "In biblical language, fear of the Lord is:",
                            options: [
                                "Panic that God will reject you",
                                "Reverent trust that submits to God",
                                "Avoiding all responsibility",
                                "A feeling with no action"
                            ],
                            correctIndex: 1,
                            explanation: "The lesson frames fear as relational reverence and obedience."
                        ),
                        WisdomQuestion(
                            id: "l10q2",
                            prompt: "What posture is required for discernment?",
                            options: [
                                "Pride and certainty in self",
                                "Humility and teachability",
                                "Speed over reflection",
                                "Following majority opinion"
                            ],
                            correctIndex: 1,
                            explanation: "Humility keeps believers open to correction and guidance."
                        ),
                        WisdomQuestion(
                            id: "l10q3",
                            prompt: "Which choice best reflects this lesson?",
                            options: [
                                "Decide first, pray later",
                                "Ask what honors God before acting",
                                "Trust emotions as final authority",
                                "Ignore counsel from mature believers"
                            ],
                            correctIndex: 1,
                            explanation: "God-centered evaluation is foundational to biblical wisdom."
                        )
                    ]
                )
            ),
            WisdomLesson(
                id: "crossway-digital-discernment",
                order: 11,
                title: "Digital Discernment and Lady Folly",
                sourceName: "Crossway",
                sourceURL: "https://www.crossway.org/articles/social-algorithms-are-todays-lady-folly/",
                summary: "Modern feeds can amplify distraction and temptation. Wisdom requires intentional digital boundaries and heart-level discernment.",
                keyIdeas: [
                    "Digital systems can train desires, attention, and habits without us noticing.",
                    "Biblical wisdom asks what content forms us toward Christlikeness.",
                    "Believers should build intentional limits and curate what they consume."
                ],
                keyVerses: ["Proverbs 4:23", "Philippians 4:8", "1 Corinthians 10:23"],
                quest: WisdomQuest(
                    passingScore: 67,
                    questions: [
                        WisdomQuestion(
                            id: "l11q1",
                            prompt: "What is one risk of algorithm-driven content?",
                            options: [
                                "It always deepens wisdom",
                                "It can shape desires toward distraction and folly",
                                "It removes all temptation",
                                "It makes prayer unnecessary"
                            ],
                            correctIndex: 1,
                            explanation: "The lesson highlights formation, not just information, in digital habits."
                        ),
                        WisdomQuestion(
                            id: "l11q2",
                            prompt: "A wise digital practice is to:",
                            options: [
                                "Consume without reflection",
                                "Set intentional limits and evaluate fruit",
                                "Reject all technology",
                                "Only follow emotionally charged accounts"
                            ],
                            correctIndex: 1,
                            explanation: "Discernment means intentional, accountable digital patterns."
                        ),
                        WisdomQuestion(
                            id: "l11q3",
                            prompt: "Which question best supports biblical discernment online?",
                            options: [
                                "Does this content increase engagement?",
                                "Will this form me toward Christ or away from Him?",
                                "Will this make me look informed?",
                                "Is this trending right now?"
                            ],
                            correctIndex: 1,
                            explanation: "The goal is spiritual formation, not just attention or novelty."
                        )
                    ]
                )
            ),
            WisdomLesson(
                id: "desiringgod-how-to-get-wisdom",
                order: 12,
                title: "How to Get Wisdom",
                sourceName: "Desiring God",
                sourceURL: "https://www.desiringgod.org/messages/how-to-get-wisdom",
                summary: "Scripture calls believers to prize wisdom, ask God for it, and pursue it through disciplined obedience.",
                keyIdeas: [
                    "Wisdom must be valued above shortcuts and immediate comfort.",
                    "God gives wisdom to those who ask in faith and seek Him seriously.",
                    "Wisdom grows in community, Scripture meditation, and Christ-centered living."
                ],
                keyVerses: ["James 1:5", "Proverbs 4:7", "Colossians 2:3"],
                quest: WisdomQuest(
                    passingScore: 67,
                    questions: [
                        WisdomQuestion(
                            id: "l12q1",
                            prompt: "According to James 1:5, believers should:",
                            options: [
                                "Wait passively for wisdom",
                                "Ask God, who gives generously",
                                "Depend only on intuition",
                                "Seek wisdom only after failure"
                            ],
                            correctIndex: 1,
                            explanation: "Asking God is an explicit biblical command and promise."
                        ),
                        WisdomQuestion(
                            id: "l12q2",
                            prompt: "What does it mean to prize wisdom?",
                            options: [
                                "Treat it as optional",
                                "Pursue it more than convenience",
                                "Use it to control people",
                                "Reduce it to facts"
                            ],
                            correctIndex: 1,
                            explanation: "Prizing wisdom changes priorities and choices."
                        ),
                        WisdomQuestion(
                            id: "l12q3",
                            prompt: "Where are all treasures of wisdom ultimately found?",
                            options: [
                                "In personal discipline alone",
                                "In Christ",
                                "In social approval",
                                "In financial success"
                            ],
                            correctIndex: 1,
                            explanation: "Christian wisdom is fundamentally Christ-centered."
                        )
                    ]
                )
            )
        ]
    )
}

extension WisdomCourse {
    static let proverbsWisdomPath = WisdomCourse(
        id: "proverbs-wisdom-path",
        title: "Proverbs Wisdom Path",
        subtitle: "31 chapter lessons: one chapter, one lesson.",
        outcomes: [
            "Study every chapter of Proverbs in order.",
            "Build clear biblical decision habits from each chapter.",
            "Replace passive scrolling with intentional growth.",
            "Turn Scripture into practical daily obedience."
        ],
        lessons: buildProverbsChapterLessons()
    )

    private struct ProverbsChapterBlueprint {
        let chapter: Int
        let title: String
        let summary: String
        let keyVerses: [String]
    }

    private static let proverbsChapterBlueprints: [ProverbsChapterBlueprint] = [
        ProverbsChapterBlueprint(chapter: 1, title: "Choose Wisdom's Voice", summary: "Proverbs opens with a call to fear the Lord, receive instruction, and reject voices that normalize sin.", keyVerses: ["Proverbs 1:7", "Proverbs 1:10", "Proverbs 1:33"]),
        ProverbsChapterBlueprint(chapter: 2, title: "Seek Wisdom Like Treasure", summary: "Wisdom is pursued intentionally through God's words, and it protects from crooked paths and destructive temptation.", keyVerses: ["Proverbs 2:1-2", "Proverbs 2:6", "Proverbs 2:20"]),
        ProverbsChapterBlueprint(chapter: 3, title: "Trust the Lord in Every Path", summary: "Wholehearted trust in God shapes decisions, stewardship, discipline, and relationships.", keyVerses: ["Proverbs 3:5-6", "Proverbs 3:7", "Proverbs 3:9-10"]),
        ProverbsChapterBlueprint(chapter: 4, title: "Guard Your Heart and Path", summary: "A guarded heart and focused direction are essential for staying on the path of life.", keyVerses: ["Proverbs 4:7", "Proverbs 4:23", "Proverbs 4:26-27"]),
        ProverbsChapterBlueprint(chapter: 5, title: "Faithfulness and Purity", summary: "Wisdom warns against sexual unfaithfulness and calls for covenant faithfulness and integrity.", keyVerses: ["Proverbs 5:3-5", "Proverbs 5:18", "Proverbs 5:21"]),
        ProverbsChapterBlueprint(chapter: 6, title: "Diligence, Integrity, and Boundaries", summary: "This chapter addresses laziness, dishonesty, divisive behavior, and the value of wise discipline.", keyVerses: ["Proverbs 6:6-8", "Proverbs 6:16-19", "Proverbs 6:23"]),
        ProverbsChapterBlueprint(chapter: 7, title: "Resist Seduction and Shortcuts", summary: "Wisdom helps you recognize seductive patterns early and avoid choices that lead to ruin.", keyVerses: ["Proverbs 7:2-3", "Proverbs 7:22-23", "Proverbs 7:24-25"]),
        ProverbsChapterBlueprint(chapter: 8, title: "Wisdom Calls Publicly", summary: "Godly wisdom is available, precious, and life-giving for those who listen and respond.", keyVerses: ["Proverbs 8:11", "Proverbs 8:13", "Proverbs 8:35"]),
        ProverbsChapterBlueprint(chapter: 9, title: "Two Invitations: Wisdom or Folly", summary: "Life is shaped by which invitation you accept: wisdom's path to life or folly's path to destruction.", keyVerses: ["Proverbs 9:6", "Proverbs 9:10", "Proverbs 9:17-18"]),
        ProverbsChapterBlueprint(chapter: 10, title: "Daily Character in Contrast", summary: "Short proverbs contrast righteous and foolish habits in speech, work, and integrity.", keyVerses: ["Proverbs 10:9", "Proverbs 10:19", "Proverbs 10:22"]),
        ProverbsChapterBlueprint(chapter: 11, title: "Integrity, Generosity, and Humility", summary: "Righteousness and honesty stabilize life, while pride and deceit lead to trouble.", keyVerses: ["Proverbs 11:1", "Proverbs 11:2", "Proverbs 11:25"]),
        ProverbsChapterBlueprint(chapter: 12, title: "Discipline, Speech, and Work", summary: "Wisdom receives correction, speaks to heal, and works faithfully with diligence.", keyVerses: ["Proverbs 12:1", "Proverbs 12:18", "Proverbs 12:24"]),
        ProverbsChapterBlueprint(chapter: 13, title: "Teachability, Patience, and Companions", summary: "Growth comes through humility, delayed gratification, and wise relationships.", keyVerses: ["Proverbs 13:10", "Proverbs 13:12", "Proverbs 13:20"]),
        ProverbsChapterBlueprint(chapter: 14, title: "Discernment in Emotions and Choices", summary: "Wisdom examines motives, manages anger, and rejects paths that only appear right.", keyVerses: ["Proverbs 14:1", "Proverbs 14:12", "Proverbs 14:29"]),
        ProverbsChapterBlueprint(chapter: 15, title: "Soft Answers and Wise Counsel", summary: "Gentle speech, teachability, and shared counsel produce peace and clarity.", keyVerses: ["Proverbs 15:1", "Proverbs 15:22", "Proverbs 15:33"]),
        ProverbsChapterBlueprint(chapter: 16, title: "Surrender Plans to God", summary: "Humans plan, but God directs outcomes; wisdom walks in humility and trust.", keyVerses: ["Proverbs 16:3", "Proverbs 16:9", "Proverbs 16:18"]),
        ProverbsChapterBlueprint(chapter: 17, title: "Peacemaking and Loyal Friendship", summary: "Wisdom seeks peace, practices restraint, and values faithful friendship.", keyVerses: ["Proverbs 17:9", "Proverbs 17:17", "Proverbs 17:27"]),
        ProverbsChapterBlueprint(chapter: 18, title: "Listening, Speech, and Strong Refuge", summary: "Wise people listen before speaking, guard words, and run to the Lord for safety.", keyVerses: ["Proverbs 18:10", "Proverbs 18:13", "Proverbs 18:21"]),
        ProverbsChapterBlueprint(chapter: 19, title: "Prudence, Mercy, and Instruction", summary: "Wisdom responds slowly in conflict, shows mercy, and welcomes correction.", keyVerses: ["Proverbs 19:11", "Proverbs 19:17", "Proverbs 19:20"]),
        ProverbsChapterBlueprint(chapter: 20, title: "Honest Measures and Steady Judgment", summary: "Godly wisdom values fairness, patience, and tested judgment in daily life.", keyVerses: ["Proverbs 20:5", "Proverbs 20:13", "Proverbs 20:22"]),
        ProverbsChapterBlueprint(chapter: 21, title: "Justice Over Performance", summary: "External religion without righteousness fails; wise living prioritizes justice and truth.", keyVerses: ["Proverbs 21:2", "Proverbs 21:3", "Proverbs 21:23"]),
        ProverbsChapterBlueprint(chapter: 22, title: "Reputation, Training, and Stewardship", summary: "Wisdom values character, early formation, and responsible financial choices.", keyVerses: ["Proverbs 22:1", "Proverbs 22:6", "Proverbs 22:7"]),
        ProverbsChapterBlueprint(chapter: 23, title: "Self-Control and Eternal Perspective", summary: "Wise living resists greed, envy, and intoxication while pursuing disciplined hearts.", keyVerses: ["Proverbs 23:4-5", "Proverbs 23:12", "Proverbs 23:17"]),
        ProverbsChapterBlueprint(chapter: 24, title: "Courage, Preparation, and Resilience", summary: "Wisdom builds carefully, prepares in advance, and rises again after failure.", keyVerses: ["Proverbs 24:3-4", "Proverbs 24:10", "Proverbs 24:16"]),
        ProverbsChapterBlueprint(chapter: 25, title: "Timing, Diplomacy, and Self-Control", summary: "Wise people value restraint, timely speech, and measured leadership.", keyVerses: ["Proverbs 25:11", "Proverbs 25:15", "Proverbs 25:28"]),
        ProverbsChapterBlueprint(chapter: 26, title: "Avoiding Foolish Patterns", summary: "Proverbs teaches discernment in handling fools, gossip, and deceptive speech.", keyVerses: ["Proverbs 26:4-5", "Proverbs 26:11", "Proverbs 26:20"]),
        ProverbsChapterBlueprint(chapter: 27, title: "Honest Friendship and Stewardship", summary: "Wise relationships include honest correction, loyalty, and practical stewardship.", keyVerses: ["Proverbs 27:5-6", "Proverbs 27:17", "Proverbs 27:23"]),
        ProverbsChapterBlueprint(chapter: 28, title: "Confession, Courage, and Integrity", summary: "Righteous boldness grows through confession, truthfulness, and trust in God.", keyVerses: ["Proverbs 28:1", "Proverbs 28:13", "Proverbs 28:26"]),
        ProverbsChapterBlueprint(chapter: 29, title: "Leadership, Correction, and Fear of God", summary: "Wise leadership embraces correction, restrains anger, and fears God over people.", keyVerses: ["Proverbs 29:11", "Proverbs 29:18", "Proverbs 29:25"]),
        ProverbsChapterBlueprint(chapter: 30, title: "Humble Limits and Dependence", summary: "Agur models humility, dependence on God's word, and contentment in daily life.", keyVerses: ["Proverbs 30:5", "Proverbs 30:8-9", "Proverbs 30:24-28"]),
        ProverbsChapterBlueprint(chapter: 31, title: "Noble Character and Wise Legacy", summary: "Wisdom shapes leadership, family life, work ethic, generosity, and enduring character.", keyVerses: ["Proverbs 31:10", "Proverbs 31:25", "Proverbs 31:30"])
    ]

    private static func buildProverbsChapterLessons() -> [WisdomLesson] {
        proverbsChapterBlueprints.map { chapter in
            WisdomLesson(
                id: "proverbs-chapter-\(chapter.chapter)",
                order: chapter.chapter,
                title: "Chapter \(chapter.chapter): \(chapter.title)",
                sourceName: "Proverbs \(chapter.chapter)",
                sourceURL: "https://www.biblegateway.com/passage/?search=Proverbs+\(chapter.chapter)&version=KJV",
                summary: chapter.summary,
                keyIdeas: chapterKeyIdeas(for: chapter),
                keyVerses: chapter.keyVerses,
                quest: chapterQuest(for: chapter)
            )
        }
    }

    private static func chapterKeyIdeas(for chapter: ProverbsChapterBlueprint) -> [String] {
        [
            "Core focus: \(chapter.title).",
            chapter.summary,
            "Practice step: choose one instruction from Proverbs \(chapter.chapter) and obey it today in a concrete action."
        ]
    }

    private static func chapterQuest(for chapter: ProverbsChapterBlueprint) -> WisdomQuest {
        let section = proverbsCollectionLabel(for: chapter.chapter)
        let emphasis = proverbsThemePrompt(for: chapter)
        let actionStep = proverbsPracticeStep(for: chapter)
        let keyVerse = chapter.keyVerses[safe: 0] ?? "Proverbs \(chapter.chapter):1"

        return WisdomQuest(
            passingScore: 75,
            questions: [
                WisdomQuestion(
                    id: "proverbs\(chapter.chapter)q1",
                    prompt: "Which description best fits Proverbs \(chapter.chapter) inside the book's larger design?",
                    options: [
                        "A detached prophecy unrelated to wisdom formation",
                        section,
                        "A New Testament-style church letter about leadership structure",
                        "A historical narrative chapter focused on Israel's kings"
                    ],
                        correctIndex: 1,
                    explanation: "This chapter belongs to that literary setting, which helps explain how its wisdom should be read."
                ),
                WisdomQuestion(
                    id: "proverbs\(chapter.chapter)q2",
                    prompt: "What chapter emphasis is Proverbs \(chapter.chapter) pressing most clearly?",
                    options: [
                        "Wisdom mainly lives in private thought and not in real decisions",
                        emphasis,
                        "Godly living becomes clearer when correction is ignored",
                        "This chapter teaches that character matters less than quick success"
                    ],
                    correctIndex: 1,
                    explanation: "That focus captures the chapter's main burden and keeps the reading anchored in its actual message."
                ),
                WisdomQuestion(
                    id: "proverbs\(chapter.chapter)q3",
                    prompt: "Which key verse belongs to Proverbs \(chapter.chapter) and helps anchor its message?",
                    options: [
                        "James 1:5",
                        "Psalm 23:1",
                        keyVerse,
                        "Matthew 5:9"
                    ],
                    correctIndex: 2,
                    explanation: "That verse comes from the chapter itself and gives one of the clearest anchors for its teaching."
                ),
                WisdomQuestion(
                    id: "proverbs\(chapter.chapter)q4",
                    prompt: "What is the wisest next response after studying Proverbs \(chapter.chapter)?",
                    options: [
                        "Wait until life slows down before applying any of it",
                        "Treat the chapter as interesting sayings without personal obedience",
                        "Copy the words you like without changing any habits",
                        actionStep
                    ],
                    correctIndex: 3,
                    explanation: "Proverbs trains discernment for ordinary life, so the next step should be concrete, humble, and practiced."
                )
            ]
        )
    }

    private static func proverbsCollectionLabel(for chapter: Int) -> String {
        switch chapter {
        case 1...9:
            return "A fatherly wisdom discourse that forms the reader before the short proverb collections begin"
        case 10...21:
            return "Part of the main Solomonic proverb collection, where short sayings train daily discernment"
        case 22...24:
            return "A wisdom-instruction section that blends short sayings with focused teaching and counsel"
        case 25...29:
            return "Part of the Solomonic collection preserved by Hezekiah's men, stressing leadership and practical judgment"
        case 30:
            return "Agur's wisdom chapter, marked by humility, limits, and careful observation"
        case 31:
            return "Lemuel's royal instruction, ending with a portrait of noble character and faithful fear of the Lord"
        default:
            return "A wisdom chapter inside Proverbs that trains the reader in faithful living"
        }
    }

    private static func proverbsThemePrompt(for chapter: ProverbsChapterBlueprint) -> String {
        chapter.summary
    }

    private static func proverbsPracticeStep(for chapter: ProverbsChapterBlueprint) -> String {
        "Choose one instruction from Proverbs \(chapter.chapter) and obey it in a real decision today"
    }

    static let jamesBibleSchool = WisdomCourse(
        id: "james-bible-school",
        title: "James",
        subtitle: "A 5-chapter Bible-school path through James.",
        outcomes: [
            "Read the full book of James chapter by chapter in a clean guided format.",
            "Understand how trials, faith, speech, humility, and prayer work together in the letter.",
            "Move from chapter knowledge into visible obedience and steady spiritual maturity.",
            "Use premium quests to test understanding of chapter meaning, history, and application."
        ],
        lessons: buildJamesBibleSchoolLessons()
    )

    static let bibleInAYearSchool = WisdomCourse(
        id: "bible-in-a-year-school",
        title: "Bible in a Year",
        subtitle: "12 guided monthly checkpoints through the full Bible.",
        outcomes: [
            "Read the full Bible across one year with a guided monthly structure.",
            "Use anchor chapters to keep each month's main movement clear and memorable.",
            "Stay rooted in the storyline of Scripture instead of reading disconnected passages.",
            "Let Bible School teaching, context, and quests keep the full-year path focused."
        ],
        lessons: buildBibleInAYearLessons()
    )

    private struct JamesBibleSchoolBlueprint {
        let chapter: Int
        let title: String
        let summary: String
        let keyIdeas: [String]
        let keyVerses: [String]
        let questions: [WisdomQuestion]
    }

    private static let jamesBibleSchoolBlueprints: [JamesBibleSchoolBlueprint] = [
        JamesBibleSchoolBlueprint(
            chapter: 1,
            title: "Wisdom in Trials",
            summary: "James 1 teaches believers how to endure pressure with steadfast faith, ask God for wisdom without divided loyalty, refuse to blame God for temptation, and become doers of the Word instead of hearers only.",
            keyIdeas: [
                "Trials expose whether faith is steady enough to endure under pressure.",
                "Wisdom in James 1 is practical guidance for faithful endurance, not abstract information.",
                "Temptation grows from disordered desire, so James pushes the reader toward honest self-examination.",
                "The chapter closes by defining maturity as active obedience, mercy, and restrained speech."
            ],
            keyVerses: ["James 1:5", "James 1:12", "James 1:22", "James 1:27"],
            questions: [
                WisdomQuestion(
                    id: "james-school-1-q1",
                    prompt: "What setting best fits the opening of James 1?",
                    options: [
                        "Believers scattered under pressure who need endurance and clarity",
                        "A settled church mainly debating ceremonial details",
                        "A missionary team preparing only for travel",
                        "A royal court asking for political advice"
                    ],
                    correctIndex: 0,
                    explanation: "James addresses scattered believers living under instability, which explains the chapter's urgency about trials, wisdom, and endurance."
                ),
                WisdomQuestion(
                    id: "james-school-1-q2",
                    prompt: "Why does James connect asking for wisdom to seasons of trial?",
                    options: [
                        "Because suffering automatically proves a person is wise",
                        "Because pressure reveals whether a believer will trust God steadily and respond faithfully",
                        "Because wisdom matters only when life feels uncertain",
                        "Because James wants believers to escape difficulty quickly"
                    ],
                    correctIndex: 1,
                    explanation: "In James 1, wisdom is the God-given clarity needed to endure and obey under strain."
                ),
                WisdomQuestion(
                    id: "james-school-1-q3",
                    prompt: "What does James say about temptation in the middle of the chapter?",
                    options: [
                        "Temptation proves God is testing believers beyond faithfulness",
                        "Temptation is mainly caused by other people",
                        "Temptation should be ignored because it passes on its own",
                        "Temptation grows from desire and must not be blamed on God"
                    ],
                    correctIndex: 3,
                    explanation: "James traces temptation inward toward desire and protects God's character from false blame."
                ),
                WisdomQuestion(
                    id: "james-school-1-q4",
                    prompt: "According to the end of James 1, who is spiritually deceived?",
                    options: [
                        "The person who hears the Word without doing it",
                        "The person who asks questions while learning",
                        "The person who suffers and asks God for help",
                        "The person who serves quietly in ordinary life"
                    ],
                    correctIndex: 0,
                    explanation: "James ends by redefining maturity around obedience, not familiarity with truth."
                )
            ]
        ),
        JamesBibleSchoolBlueprint(
            chapter: 2,
            title: "Faith That Works",
            summary: "James 2 confronts favoritism inside the gathered church, explains the royal law of love, and shows that genuine faith becomes visible through action rather than empty profession.",
            keyIdeas: [
                "James rebukes favoritism because the gospel does not permit churches to rank people by wealth or status.",
                "The royal law to love your neighbor exposes partiality as a serious contradiction, not a small social flaw.",
                "Faith without works is dead because real trust in God produces visible obedience.",
                "Abraham and Rahab show that living faith acts in costly, concrete ways."
            ],
            keyVerses: ["James 2:1", "James 2:8", "James 2:17", "James 2:26"],
            questions: [
                WisdomQuestion(
                    id: "james-school-2-q1",
                    prompt: "What issue does James confront first in chapter 2?",
                    options: [
                        "Confusion about prayer language",
                        "Favoritism toward the rich and dishonor toward the poor",
                        "Questions about fasting practice",
                        "Debate about church leadership titles"
                    ],
                    correctIndex: 1,
                    explanation: "James begins with an assembly scene that exposes how status can distort Christian community."
                ),
                WisdomQuestion(
                    id: "james-school-2-q2",
                    prompt: "Why is partiality such a serious problem in James 2?",
                    options: [
                        "Because it makes gatherings inefficient",
                        "Because it breaks the royal law of love and contradicts gospel judgment",
                        "Because poor people should never be corrected",
                        "Because wealth itself is always sinful"
                    ],
                    correctIndex: 1,
                    explanation: "James treats favoritism as a law-breaking failure of love, not a minor social mistake."
                ),
                WisdomQuestion(
                    id: "james-school-2-q3",
                    prompt: "When James says faith without works is dead, what is his main point?",
                    options: [
                        "Works replace the need for grace",
                        "A profession of faith is alive only when it is visible in obedience",
                        "Only public acts of service matter",
                        "Mature believers no longer need faith once they obey"
                    ],
                    correctIndex: 1,
                    explanation: "James is not opposing grace; he is opposing empty claims that show no evidence of living faith."
                ),
                WisdomQuestion(
                    id: "james-school-2-q4",
                    prompt: "Why does James mention Abraham and Rahab together?",
                    options: [
                        "To show that living faith acts across very different lives and situations",
                        "To compare the Old Testament with the New Testament",
                        "To teach that only famous people can obey well",
                        "To argue that faith is mainly a private feeling"
                    ],
                    correctIndex: 0,
                    explanation: "James uses both examples to show that genuine faith becomes concrete in action, regardless of background."
                )
            ]
        ),
        JamesBibleSchoolBlueprint(
            chapter: 3,
            title: "Wisdom From Above",
            summary: "James 3 warns that words carry great power, exposes the tongue as a revealing force in community life, and contrasts earthly wisdom with the peaceable, pure, and merciful wisdom that comes from above.",
            keyIdeas: [
                "Teachers face stricter judgment because words shape people and communities.",
                "The tongue functions like a diagnostic tool, revealing what is governing the heart.",
                "Earthly wisdom is driven by bitter jealousy and selfish ambition, producing disorder.",
                "Wisdom from above is pure, peaceable, gentle, teachable, merciful, fruitful, impartial, and sincere."
            ],
            keyVerses: ["James 3:1", "James 3:5", "James 3:14", "James 3:17"],
            questions: [
                WisdomQuestion(
                    id: "james-school-3-q1",
                    prompt: "Why does James open chapter 3 with a warning about teachers?",
                    options: [
                        "Because teaching is unimportant compared with private devotion",
                        "Because teachers speak publicly and will be judged more strictly for their influence",
                        "Because only apostles were ever allowed to teach",
                        "Because James wants most believers to avoid Scripture"
                    ],
                    correctIndex: 1,
                    explanation: "James begins with teachers because speech and influence are central to the chapter's burden."
                ),
                WisdomQuestion(
                    id: "james-school-3-q2",
                    prompt: "What do the images of the bit, rudder, and fire teach in James 3?",
                    options: [
                        "Speech is small and therefore spiritually unimportant",
                        "Words should be ignored when evaluating maturity",
                        "Small things like the tongue can direct or destroy far more than they seem to control",
                        "Only angry speech is dangerous"
                    ],
                    correctIndex: 2,
                    explanation: "James uses vivid images to show how powerful and revealing speech can be."
                ),
                WisdomQuestion(
                    id: "james-school-3-q3",
                    prompt: "How does James identify earthly wisdom in the chapter?",
                    options: [
                        "By education level and polished speaking ability",
                        "By strictness in ceremonial practices",
                        "By mystical experiences unavailable to ordinary believers",
                        "By bitter jealousy and selfish ambition that produce disorder"
                    ],
                    correctIndex: 3,
                    explanation: "James evaluates wisdom by fruit, especially whether it creates rivalry, chaos, and corruption."
                ),
                WisdomQuestion(
                    id: "james-school-3-q4",
                    prompt: "Which summary best fits wisdom from above in James 3:17?",
                    options: [
                        "Strategic, impressive, and self-protective",
                        "Pure, peaceable, gentle, teachable, and full of mercy",
                        "Aggressive toward critics and swift to dominate",
                        "Private, hidden, and detached from community"
                    ],
                    correctIndex: 1,
                    explanation: "James presents heavenly wisdom as morally clean and relationally peace-making."
                )
            ]
        ),
        JamesBibleSchoolBlueprint(
            chapter: 4,
            title: "Humble Yourself",
            summary: "James 4 uncovers the inner passions behind conflict, warns against friendship with the world, calls believers to repent pride, and teaches them to hold plans humbly before the Lord.",
            keyIdeas: [
                "James traces conflict back to desires at war within the heart, not merely outward circumstances.",
                "Friendship with the world means adopting rival loyalties that oppose God's rule.",
                "The chapter calls believers to repent pride, draw near to God, and submit themselves to Him.",
                "Planning without humility becomes boastful because life itself depends on the Lord's will."
            ],
            keyVerses: ["James 4:1", "James 4:4", "James 4:7", "James 4:15"],
            questions: [
                WisdomQuestion(
                    id: "james-school-4-q1",
                    prompt: "According to James 4, where do fights and quarrels ultimately come from?",
                    options: [
                        "Mostly from personality differences that cannot be helped",
                        "From desires and passions warring within people",
                        "From not having enough information",
                        "From God withholding peace from sincere believers"
                    ],
                    correctIndex: 1,
                    explanation: "James presses beneath surface conflict and locates the deeper source inside disordered desires."
                ),
                WisdomQuestion(
                    id: "james-school-4-q2",
                    prompt: "What does James mean by friendship with the world?",
                    options: [
                        "Enjoying creation and daily work",
                        "Loving unbelieving neighbors less",
                        "Adopting loyalties, desires, and values that rival devotion to God",
                        "Leaving church life to pursue private spirituality"
                    ],
                    correctIndex: 2,
                    explanation: "James uses strong covenant language because divided allegiance is at the center of the chapter."
                ),
                WisdomQuestion(
                    id: "james-school-4-q3",
                    prompt: "Why does James include 'You ask and do not receive, because you ask wrongly'?",
                    options: [
                        "To say prayer never changes anything",
                        "To expose motives that want God to serve selfish desire",
                        "To discourage believers from praying during conflict",
                        "To teach that only leaders may pray effectively"
                    ],
                    correctIndex: 1,
                    explanation: "James uses prayer language to reveal that even religious activity can be driven by wrong motives."
                ),
                WisdomQuestion(
                    id: "james-school-4-q4",
                    prompt: "What is the point of the merchant-planning example at the end of James 4?",
                    options: [
                        "Business planning is always wrong",
                        "Travel should be avoided by mature believers",
                        "Future plans become arrogant when they ignore dependence on the Lord's will",
                        "Christians should never think about tomorrow"
                    ],
                    correctIndex: 2,
                    explanation: "James critiques boastful independence, not wise planning itself."
                )
            ]
        ),
        JamesBibleSchoolBlueprint(
            chapter: 5,
            title: "Patient Faith",
            summary: "James 5 warns unjust wealthy oppressors, calls suffering believers to patient endurance, and ends the letter with a strong vision of prayer, confession, restoration, and faith-filled perseverance.",
            keyIdeas: [
                "James begins by exposing wealth used unjustly against laborers and the vulnerable.",
                "Believers are called to patient endurance like farmers, prophets, and Job while awaiting the Lord's coming.",
                "The chapter presents prayer as a normal response to suffering, weakness, joy, and sin.",
                "James ends with a community vision in which straying believers are pursued and restored."
            ],
            keyVerses: ["James 5:4", "James 5:7", "James 5:16", "James 5:19-20"],
            questions: [
                WisdomQuestion(
                    id: "james-school-5-q1",
                    prompt: "Who is being confronted at the start of James 5?",
                    options: [
                        "Believers who are too emotional in worship",
                        "Wealthy people who have used riches unjustly and withheld wages",
                        "Missionaries who travel without support",
                        "Young believers still learning endurance"
                    ],
                    correctIndex: 1,
                    explanation: "James begins the chapter with a prophetic warning against exploitative wealth and injustice."
                ),
                WisdomQuestion(
                    id: "james-school-5-q2",
                    prompt: "Why does James use the image of the farmer waiting for precious fruit?",
                    options: [
                        "To show that discipleship often requires steady patience rather than instant resolution",
                        "To teach that all believers should become farmers",
                        "To suggest suffering always ends quickly",
                        "To shift the chapter away from prayer"
                    ],
                    correctIndex: 0,
                    explanation: "James uses the farmer to teach patient, hopeful endurance while waiting for the Lord."
                ),
                WisdomQuestion(
                    id: "james-school-5-q3",
                    prompt: "What picture of community life appears in James 5:13-18?",
                    options: [
                        "Believers should handle suffering privately whenever possible",
                        "Only the strongest believers should pray for others",
                        "Prayer, confession, and care belong to ordinary church life",
                        "Physical weakness is outside the concern of the church"
                    ],
                    correctIndex: 2,
                    explanation: "James ends the letter by presenting prayerful care and confession as normal community practices."
                ),
                WisdomQuestion(
                    id: "james-school-5-q4",
                    prompt: "Why does James close by talking about bringing back someone who wanders from the truth?",
                    options: [
                        "To show that mature believers stop caring about straying people",
                        "To emphasize that the letter aims at restoration, not information alone",
                        "To say doctrine matters more than people",
                        "To limit correction to public leaders only"
                    ],
                    correctIndex: 1,
                    explanation: "The closing verses show James's pastoral goal: communities that pursue restoration when someone drifts."
                )
            ]
        )
    ]

    private static func buildJamesBibleSchoolLessons() -> [WisdomLesson] {
        jamesBibleSchoolBlueprints.map { blueprint in
            WisdomLesson(
                id: "james-school-\(blueprint.chapter)",
                order: blueprint.chapter,
                title: "James \(blueprint.chapter): \(blueprint.title)",
                sourceName: "Bible: James \(blueprint.chapter)",
                sourceURL: "https://www.biblegateway.com/passage/?search=James+\(blueprint.chapter)&version=KJV",
                summary: blueprint.summary,
                keyIdeas: blueprint.keyIdeas,
                keyVerses: blueprint.keyVerses,
                quest: WisdomQuest(
                    passingScore: 75,
                    questions: blueprint.questions
                )
            )
        }
    }

    private struct BibleYearBlueprint {
        let month: Int
        let title: String
        let studyReference: String
        let readingRange: String
        let focusLine: String
        let summary: String
        let keyIdeas: [String]
        let keyVerses: [String]
        let practiceStep: String
    }

    private static let bibleYearBlueprints: [BibleYearBlueprint] = [
        BibleYearBlueprint(
            month: 1,
            title: "Beginnings and Promise",
            studyReference: "Genesis 1",
            readingRange: "Genesis 1-50",
            focusLine: "Creation, fall, covenant promise, and the beginnings of God's people",
            summary: "Read Genesis and trace how creation, the fall, judgment, covenant promise, and the family line of Abraham set the stage for the whole Bible.",
            keyIdeas: [
                "Reading scope: Genesis 1-50.",
                "Watch the storyline move from creation and fall into covenant promise and preservation.",
                "Let Genesis teach you that the Bible begins with God's initiative, not human strength."
            ],
            keyVerses: ["Genesis 1:1", "Genesis 12:2-3", "Genesis 50:20"],
            practiceStep: "Track one promise God makes in Genesis and carry it into prayer this week."
        ),
        BibleYearBlueprint(
            month: 2,
            title: "Deliverance and Holiness",
            studyReference: "Exodus 12",
            readingRange: "Exodus - Leviticus",
            focusLine: "God rescues His people, forms covenant identity, and teaches holy worship",
            summary: "Read Exodus and Leviticus together to see redemption, covenant, priesthood, sacrifice, and the holiness of God shaping Israel's life.",
            keyIdeas: [
                "Reading scope: Exodus and Leviticus.",
                "Watch God move from rescue to covenant formation to holy worship.",
                "Let the tabernacle, priesthood, and sacrifices show how seriously God takes His presence."
            ],
            keyVerses: ["Exodus 12:13", "Exodus 19:5-6", "Leviticus 19:2"],
            practiceStep: "Read this month asking how redemption should change the way you approach God's holiness."
        ),
        BibleYearBlueprint(
            month: 3,
            title: "Wilderness and Renewal",
            studyReference: "Deuteronomy 6",
            readingRange: "Numbers - Deuteronomy",
            focusLine: "Testing, unbelief, leadership, and covenant renewal in the wilderness",
            summary: "Read Numbers and Deuteronomy to see how unbelief delays obedience, how God remains faithful, and how covenant truth is pressed into the next generation.",
            keyIdeas: [
                "Reading scope: Numbers and Deuteronomy.",
                "Watch how wilderness pressure exposes faith, complaint, rebellion, and dependence.",
                "Let Moses' final sermons teach you how covenant memory shapes obedience."
            ],
            keyVerses: ["Numbers 14:9", "Deuteronomy 6:4-5", "Deuteronomy 8:2"],
            practiceStep: "Name one place where remembering God's faithfulness should change your obedience."
        ),
        BibleYearBlueprint(
            month: 4,
            title: "Land, Judges, and Mercy",
            studyReference: "Joshua 1",
            readingRange: "Joshua - Ruth",
            focusLine: "Entering the land, cycles of compromise, and God's mercy in unstable times",
            summary: "Read Joshua, Judges, and Ruth to watch conquest, covenant testing, repeated rebellion, and God's quiet faithfulness through ordinary people.",
            keyIdeas: [
                "Reading scope: Joshua, Judges, and Ruth.",
                "Watch obedience, compromise, and covenant memory shape life in the land.",
                "Let Ruth remind you that redemption often moves quietly inside ordinary faithfulness."
            ],
            keyVerses: ["Joshua 1:8-9", "Judges 21:25", "Ruth 1:16"],
            practiceStep: "Read these books by asking where compromise begins small before becoming normal."
        ),
        BibleYearBlueprint(
            month: 5,
            title: "Kingship and Covenant Line",
            studyReference: "1 Samuel 16",
            readingRange: "1 Samuel - 2 Samuel",
            focusLine: "The rise of kingship, David's calling, and the tension between outward power and the heart",
            summary: "Read 1 and 2 Samuel to see leadership, anointing, covenant promise, sin, repentance, and the shaping of Israel's kingdom around David.",
            keyIdeas: [
                "Reading scope: 1 Samuel and 2 Samuel.",
                "Watch how God exposes the difference between outward appearance and the heart.",
                "Let David's story teach you both covenant promise and the seriousness of sin."
            ],
            keyVerses: ["1 Samuel 16:7", "2 Samuel 7:16", "2 Samuel 24:24"],
            practiceStep: "Ask God to expose where you still measure leadership by appearance instead of character."
        ),
        BibleYearBlueprint(
            month: 6,
            title: "Kings, Temple, and Division",
            studyReference: "1 Kings 8",
            readingRange: "1 Kings - 2 Chronicles",
            focusLine: "Temple glory, kingdom division, prophetic confrontation, and the consequences of covenant drift",
            summary: "Read Kings and Chronicles together to trace Solomon, the temple, divided kingdoms, reform, decline, and the long consequences of unfaithfulness.",
            keyIdeas: [
                "Reading scope: 1 Kings through 2 Chronicles.",
                "Watch how worship, leadership, and covenant loyalty shape the fate of a nation.",
                "Let the prophets and reforming kings teach you that compromise always carries consequences."
            ],
            keyVerses: ["1 Kings 8:27", "2 Chronicles 7:14", "1 Kings 18:21"],
            practiceStep: "Notice one warning pattern in the kings and resist that same drift early in your own life."
        ),
        BibleYearBlueprint(
            month: 7,
            title: "Return and Rebuilding",
            studyReference: "Ezra 1",
            readingRange: "Ezra - Esther",
            focusLine: "Return from exile, rebuilding worship, rebuilding walls, and God's providence in hidden places",
            summary: "Read Ezra, Nehemiah, and Esther to see restoration after exile, renewed worship, leadership under pressure, and God's unseen providence.",
            keyIdeas: [
                "Reading scope: Ezra, Nehemiah, and Esther.",
                "Watch restoration happen through repentance, courage, rebuilding, and providence.",
                "Let these books teach you that renewal often comes through hard, patient work."
            ],
            keyVerses: ["Ezra 1:3", "Nehemiah 4:14", "Esther 4:14"],
            practiceStep: "Choose one area of neglected spiritual rebuilding and begin it with courage this week."
        ),
        BibleYearBlueprint(
            month: 8,
            title: "Wisdom, Worship, and Longing",
            studyReference: "Psalm 1",
            readingRange: "Job - Song of Solomon",
            focusLine: "Wisdom literature teaches suffering, worship, godly judgment, and holy desire",
            summary: "Read Job, Psalms, Proverbs, Ecclesiastes, and Song of Solomon to learn how Scripture speaks into pain, praise, wisdom, meaning, and covenant love.",
            keyIdeas: [
                "Reading scope: Job through Song of Solomon.",
                "Watch wisdom literature train the heart, not only the mind.",
                "Let these books give you language for suffering, praise, discernment, and longing."
            ],
            keyVerses: ["Job 28:28", "Psalm 1:2-3", "Proverbs 9:10"],
            practiceStep: "Use one psalm, proverb, or wisdom verse as the language of your prayer each day."
        ),
        BibleYearBlueprint(
            month: 9,
            title: "Prophets of Warning and Hope",
            studyReference: "Isaiah 6",
            readingRange: "Isaiah - Lamentations",
            focusLine: "God confronts sin, promises judgment, and speaks hope of redemption through the prophets",
            summary: "Read Isaiah, Jeremiah, and Lamentations to see God's holiness, human rebellion, prophetic grief, and the promise of restoration.",
            keyIdeas: [
                "Reading scope: Isaiah, Jeremiah, and Lamentations.",
                "Watch prophecy hold warning and hope together without watering down either.",
                "Let the prophets deepen your vision of God's holiness, justice, and coming salvation."
            ],
            keyVerses: ["Isaiah 6:8", "Isaiah 53:5", "Lamentations 3:22-23"],
            practiceStep: "Read the prophets asking not only what they condemn, but what they reveal about God's heart."
        ),
        BibleYearBlueprint(
            month: 10,
            title: "Exile, Return, and Final Expectation",
            studyReference: "Ezekiel 36",
            readingRange: "Ezekiel - Malachi",
            focusLine: "Exile visions, kingdom hope, and the final prophetic expectation before Christ",
            summary: "Read Ezekiel, Daniel, and the Twelve to see exile, sovereignty, repentance, restoration, and the growing expectation of the Lord's coming deliverance.",
            keyIdeas: [
                "Reading scope: Ezekiel through Malachi.",
                "Watch how God sustains hope even in judgment and exile.",
                "Let the closing prophets sharpen your expectation for the Messiah and true restoration."
            ],
            keyVerses: ["Ezekiel 36:26", "Daniel 7:14", "Malachi 4:2"],
            practiceStep: "Read the final prophets looking for how they prepare the heart to receive Jesus."
        ),
        BibleYearBlueprint(
            month: 11,
            title: "Jesus and the Kingdom",
            studyReference: "Matthew 5",
            readingRange: "Matthew - John",
            focusLine: "The life, teaching, death, and resurrection of Jesus stand at the center of the whole Bible",
            summary: "Read the Gospels slowly to watch Jesus' kingdom teaching, compassion, confrontation, cross, resurrection, and identity from multiple angles.",
            keyIdeas: [
                "Reading scope: Matthew, Mark, Luke, and John.",
                "Watch how each Gospel reveals Jesus faithfully while emphasizing different angles of His ministry.",
                "Let the Gospels reset your whole reading of Scripture around Christ Himself."
            ],
            keyVerses: ["Matthew 5:16", "Mark 10:45", "John 20:31"],
            practiceStep: "Read the Gospels asking one question daily: what does this show me about Jesus Himself?"
        ),
        BibleYearBlueprint(
            month: 12,
            title: "Church, Mission, and Last Hope",
            studyReference: "Acts 2",
            readingRange: "Acts - Revelation",
            focusLine: "The risen Christ builds His church, sends the gospel outward, and fixes hope on His final return",
            summary: "Read Acts, the Epistles, and Revelation to see the Spirit-filled church, apostolic teaching, gospel mission, practical discipleship, and the final hope of Christ's return.",
            keyIdeas: [
                "Reading scope: Acts through Revelation.",
                "Watch doctrine, church life, mission, suffering, holiness, and hope stay tied together.",
                "Let the New Testament letters train your daily life while Revelation lifts your eyes to final victory."
            ],
            keyVerses: ["Acts 2:42", "Romans 8:1", "Revelation 21:5"],
            practiceStep: "Finish the year by naming how the whole Bible has changed the way you now follow Jesus."
        )
    ]

    private static func buildBibleInAYearLessons() -> [WisdomLesson] {
        bibleYearBlueprints.map { blueprint in
            WisdomLesson(
                id: "bible-year-\(blueprint.month)",
                order: blueprint.month,
                title: "Month \(blueprint.month): \(blueprint.title)",
                sourceName: "Bible: \(blueprint.studyReference)",
                sourceURL: "https://www.biblegateway.com/passage/?search=\(blueprint.studyReference.replacingOccurrences(of: " ", with: "+"))&version=KJV",
                summary: "\(blueprint.summary) Reading scope: \(blueprint.readingRange).",
                keyIdeas: blueprint.keyIdeas,
                keyVerses: blueprint.keyVerses,
                quest: bibleYearQuest(for: blueprint)
            )
        }
    }

    private static func bibleYearQuest(for blueprint: BibleYearBlueprint) -> WisdomQuest {
        let ranges = bibleYearBlueprints.map(\.readingRange)
        let incorrectRanges = ranges.filter { $0 != blueprint.readingRange }
        let firstDistractor = incorrectRanges[safe: max(0, blueprint.month - 2)] ?? incorrectRanges.first ?? "Genesis 1-50"
        let secondDistractor = incorrectRanges[safe: min(incorrectRanges.count - 1, blueprint.month)] ?? incorrectRanges.last ?? "Acts - Revelation"
        let anchorVerse = blueprint.keyVerses.first ?? blueprint.studyReference

        return WisdomQuest(
            passingScore: 75,
            questions: [
                WisdomQuestion(
                    id: "bible-year-\(blueprint.month)-q1",
                    prompt: "Which reading range belongs to Month \(blueprint.month)?",
                    options: [
                        firstDistractor,
                        blueprint.readingRange,
                        secondDistractor,
                        "Only the anchor chapter for that month"
                    ],
                    correctIndex: 1,
                    explanation: "Each Bible in a Year lesson uses one anchor chapter, but the monthly path is guiding a much larger reading range."
                ),
                WisdomQuestion(
                    id: "bible-year-\(blueprint.month)-q2",
                    prompt: "What major movement is this month meant to keep clear?",
                    options: [
                        "A detached collection of unrelated devotional thoughts",
                        blueprint.focusLine,
                        "A purely historical record with no discipleship purpose",
                        "A reading month that matters only for completion streaks"
                    ],
                    correctIndex: 1,
                    explanation: "The guided checkpoint exists to keep the month's main biblical movement clear while you read widely."
                ),
                WisdomQuestion(
                    id: "bible-year-\(blueprint.month)-q3",
                    prompt: "Which anchor chapter helps ground Month \(blueprint.month)?",
                    options: [
                        "Psalm 23",
                        anchorVerse,
                        blueprint.studyReference,
                        "Matthew 28"
                    ],
                    correctIndex: 2,
                    explanation: "The anchor chapter is the lesson's main guided entry point for that month's larger reading span."
                ),
                WisdomQuestion(
                    id: "bible-year-\(blueprint.month)-q4",
                    prompt: "What is the wisest next step after this month's checkpoint?",
                    options: [
                        "Read only the anchor chapter and skip the rest of the month's books",
                        "Treat the plan like information instead of formation",
                        "Let the reading shape one concrete act of obedience or prayer",
                        "Wait to apply anything until the whole year is finished"
                    ],
                    correctIndex: 2,
                    explanation: "This guided year path is meant to form obedience and understanding while you read, not only at the end."
                )
            ]
        )
    }

    static let biblicalWisdomV2 = WisdomCourse(
        id: "biblical-wisdom-v2",
        title: "Wisdom v2",
        subtitle: "Bible-wide wisdom lessons across key chapters and passages.",
        outcomes: [
            "Learn how wisdom is revealed from Job, Psalms, Ecclesiastes, the Gospels, and the Epistles.",
            "Practice chapter-level discernment instead of collecting isolated quotes.",
            "Strengthen memory through checkpoints, review slides, and deeper application questions.",
            "Build a fuller biblical framework for decisions, suffering, speech, money, and obedience."
        ],
        lessons: buildBiblicalWisdomV2Lessons()
    )

    private struct BiblicalWisdomV2Blueprint {
        let id: String
        let order: Int
        let title: String
        let sourceName: String
        let sourceURL: String
        let summary: String
        let keyIdeas: [String]
        let keyVerses: [String]
        let questions: [WisdomQuestion]
    }

    private static let biblicalWisdomV2Blueprints: [BiblicalWisdomV2Blueprint] = [
        BiblicalWisdomV2Blueprint(
            id: "wisdom-v2-job-28",
            order: 1,
            title: "Job 28: Where Wisdom Is Found",
            sourceName: "Bible: Job 28",
            sourceURL: "https://www.biblegateway.com/passage/?search=Job+28&version=KJV",
            summary: "Job 28 contrasts human brilliance with human limitation. People can mine hidden treasure, engineer solutions, and measure the physical world, yet they still cannot discover the meaning of life by technique alone. The chapter drives readers to God's perspective: wisdom belongs to Him, and for humans wisdom begins in fearing the Lord and turning away from evil.",
            keyIdeas: [
                "Human competence is real, but it is never the same thing as moral and spiritual wisdom.",
                "Wisdom cannot be bought, extracted, or mastered like a tool because it belongs to God's full understanding of reality.",
                "Job 28 ends by defining wisdom for people in practical terms: fear the Lord and turn away from evil.",
                "Wise people do not deny their limits; they let those limits drive them into reverence and obedience."
            ],
            keyVerses: ["Job 28:12", "Job 28:20", "Job 28:28"],
            questions: [
                WisdomQuestion(
                    id: "wisdomv2-job28-q1",
                    prompt: "What major contrast controls the argument of Job 28?",
                    options: [
                        "Humans can work hard and discover every hidden truth without God.",
                        "Humans can uncover physical treasure, but wisdom is not found by human skill alone.",
                        "Wisdom is easier to find than precious metals if you are disciplined.",
                        "Job 28 teaches that wisdom comes mainly through age and experience."
                    ],
                    correctIndex: 1,
                    explanation: "Job 28 highlights impressive human achievement, then shows that wisdom still lies beyond human discovery unless God reveals it."
                ),
                WisdomQuestion(
                    id: "wisdomv2-job28-q2",
                    prompt: "According to Job 28:28, which statement best defines wisdom for human beings?",
                    options: [
                        "Wisdom is mastering hidden information before others do.",
                        "Wisdom is avoiding difficult questions so your faith stays simple.",
                        "Wisdom is fearing the Lord and turning away from evil.",
                        "Wisdom is becoming strong enough to handle life without dependence."
                    ],
                    correctIndex: 2,
                    explanation: "The chapter ends with a direct definition: reverence before God and moral separation from evil."
                ),
                WisdomQuestion(
                    id: "wisdomv2-job28-q3",
                    prompt: "A student applies Job 28 best when he or she:",
                    options: [
                        "Relies on intelligence alone because deep thinkers are usually wisest.",
                        "Treats moral obedience as less important than getting answers quickly.",
                        "Begins big decisions with humble reverence, prayer, and a willingness to reject evil.",
                        "Assumes wisdom is impossible, so choices should be made by instinct."
                    ],
                    correctIndex: 2,
                    explanation: "Job 28 moves the learner from admiration of human ability to dependence on God's wisdom and moral obedience."
                )
            ]
        ),
        BiblicalWisdomV2Blueprint(
            id: "wisdom-v2-psalm-1",
            order: 2,
            title: "Psalm 1: Meditation and the Two Paths",
            sourceName: "Bible: Psalm 1",
            sourceURL: "https://www.biblegateway.com/passage/?search=Psalm+1&version=KJV",
            summary: "Psalm 1 opens the Psalter by presenting two ways to live. The blessed person resists the slow drift into ungodly influence, delights in God's instruction, and becomes stable like a fruitful tree. The wicked, by contrast, look substantial for a moment but are weightless like chaff when judgment and testing arrive.",
            keyIdeas: [
                "Psalm 1 describes formation as a path: counsel shapes standing, standing shapes belonging, and belonging shapes identity.",
                "Meditation in Scripture is not vague inspiration; it is repeated, joyful reflection that reshapes desire and direction.",
                "Fruitfulness in Psalm 1 is rootedness before it is visibility; stability comes before productivity.",
                "The contrast between tree and chaff teaches that wisdom produces substance, endurance, and lasting direction."
            ],
            keyVerses: ["Psalm 1:1", "Psalm 1:2", "Psalm 1:3"],
            questions: [
                WisdomQuestion(
                    id: "wisdomv2-psalm1-q1",
                    prompt: "What is the main warning in Psalm 1:1?",
                    options: [
                        "Ungodly influence usually arrives in small stages that shape your direction over time.",
                        "The blessed life requires separating from every person who struggles.",
                        "Meditation matters less than strong emotion in worship.",
                        "You should avoid all public life if you want to remain pure."
                    ],
                    correctIndex: 0,
                    explanation: "Psalm 1 shows a progression from counsel to standing to sitting, revealing how influence slowly forms a life."
                ),
                WisdomQuestion(
                    id: "wisdomv2-psalm1-q2",
                    prompt: "Why is the righteous person compared to a tree planted by streams of water?",
                    options: [
                        "Because wisdom guarantees an easy life without suffering.",
                        "Because wisdom creates rootedness, nourishment, and steady fruitfulness over time.",
                        "Because biblical meditation is mostly about private comfort.",
                        "Because the psalm is mainly interested in agricultural imagery."
                    ],
                    correctIndex: 1,
                    explanation: "The tree image communicates stability, supply, and lasting fruit, not instant results."
                ),
                WisdomQuestion(
                    id: "wisdomv2-psalm1-q3",
                    prompt: "Which daily habit best matches Psalm 1?",
                    options: [
                        "Let your mood decide whether Scripture matters today.",
                        "Read Scripture only when facing a crisis.",
                        "Return to God's Word repeatedly until it shapes your desires and choices.",
                        "Collect Christian content without slowing down long enough to reflect."
                    ],
                    correctIndex: 2,
                    explanation: "Psalm 1 praises steady delight and meditation, not sporadic exposure."
                )
            ]
        ),
        BiblicalWisdomV2Blueprint(
            id: "wisdom-v2-psalm-37",
            order: 3,
            title: "Psalm 37: Patient Wisdom When Evil Seems to Win",
            sourceName: "Bible: Psalm 37",
            sourceURL: "https://www.biblegateway.com/passage/?search=Psalm+37&version=KJV",
            summary: "Psalm 37 trains wise patience. When evil appears to prosper, the psalm repeatedly commands believers not to fret, but to trust, do good, commit their way to the Lord, be still, and wait patiently. The chapter teaches long-range faith: God's justice is real even when it does not arrive on your timetable.",
            keyIdeas: [
                "Fretting is more than stress; it is agitated unbelief that begins to copy the methods of the wicked.",
                "Wise patience is active: trust, do good, delight in God, commit your way, and wait.",
                "Psalm 37 teaches learners to think in long horizons instead of immediate appearances.",
                "Meekness in Scripture is not passivity; it is strength that refuses revenge because it trusts God to judge rightly."
            ],
            keyVerses: ["Psalm 37:1", "Psalm 37:5", "Psalm 37:7"],
            questions: [
                WisdomQuestion(
                    id: "wisdomv2-psalm37-q1",
                    prompt: "In Psalm 37, what is wrong with 'fretting' over evildoers?",
                    options: [
                        "It is harmless as long as you do not say anything out loud.",
                        "It can pull your heart toward envy, imitation, and restless unbelief.",
                        "It shows you care more deeply than other believers do.",
                        "It is the same thing as wise discernment."
                    ],
                    correctIndex: 1,
                    explanation: "Psalm 37 warns that fretful obsession can move the heart toward sinful comparison and imitation."
                ),
                WisdomQuestion(
                    id: "wisdomv2-psalm37-q2",
                    prompt: "Which response best reflects the psalm's repeated commands?",
                    options: [
                        "Trust, do good, commit your way, be still, and wait for the Lord.",
                        "Retaliate quietly so injustice does not go unanswered.",
                        "Withdraw from responsibility until circumstances improve.",
                        "Measure God's faithfulness by how quickly visible outcomes change."
                    ],
                    correctIndex: 0,
                    explanation: "The chapter builds a pattern of active trust rather than anxious control."
                ),
                WisdomQuestion(
                    id: "wisdomv2-psalm37-q3",
                    prompt: "A wise reading of Psalm 37 helps a user remember that:",
                    options: [
                        "Short-term success is the truest measure of righteousness.",
                        "Delayed justice means God is uninvolved.",
                        "Patience is weakness when wicked people seem powerful.",
                        "God's timeline is larger than today's appearance, so faithfulness should not be abandoned."
                    ],
                    correctIndex: 3,
                    explanation: "Psalm 37 keeps expanding the learner's time horizon so outward appearances do not control inner obedience."
                )
            ]
        ),
        BiblicalWisdomV2Blueprint(
            id: "wisdom-v2-ecclesiastes-3",
            order: 4,
            title: "Ecclesiastes 3: Time, Limits, and Reverence",
            sourceName: "Bible: Ecclesiastes 3",
            sourceURL: "https://www.biblegateway.com/passage/?search=Ecclesiastes+3&version=KJV",
            summary: "Ecclesiastes 3 teaches that life unfolds in seasons God governs, not seasons we control. The famous poem about time is not fatalistic; it is humbling. Humans cannot master timing or decode the whole plan of God, so wisdom receives limits, fears God, does good in the present, and enjoys His gifts without pretending to rule history.",
            keyIdeas: [
                "The chapter pushes back on the illusion that maturity means total control over timing and outcomes.",
                "God's sovereignty over seasons should produce humility, gratitude, and reverence, not paralysis.",
                "Ecclesiastes 3 calls learners to faithfulness in the present instead of obsessive anxiety about the whole future.",
                "Enjoying God's gifts is a wise response when it is joined to reverence and obedience."
            ],
            keyVerses: ["Ecclesiastes 3:1", "Ecclesiastes 3:11", "Ecclesiastes 3:14"],
            questions: [
                WisdomQuestion(
                    id: "wisdomv2-ecc3-q1",
                    prompt: "What is the main effect of the 'time for every matter' poem in Ecclesiastes 3?",
                    options: [
                        "It teaches that people can predict the perfect season for every decision.",
                        "It reminds readers that life unfolds under God's rule, not human control.",
                        "It suggests choices do not matter because everything is fixed anyway.",
                        "It argues that wisdom means escaping ordinary responsibilities."
                    ],
                    correctIndex: 1,
                    explanation: "The poem humbles human control and places time under God's wise ordering."
                ),
                WisdomQuestion(
                    id: "wisdomv2-ecc3-q2",
                    prompt: "What does Ecclesiastes 3:11 mean when it says God has put eternity into man's heart?",
                    options: [
                        "Humans sense there is more than the present moment, yet cannot fully grasp God's total work.",
                        "Humans are able to comprehend God's entire plan if they think hard enough.",
                        "Humans should ignore present duties and think only about heaven.",
                        "Humans no longer need God's revelation to understand meaning."
                    ],
                    correctIndex: 0,
                    explanation: "The verse highlights both deep longing and deep limitation."
                ),
                WisdomQuestion(
                    id: "wisdomv2-ecc3-q3",
                    prompt: "A wise application of Ecclesiastes 3 would be to:",
                    options: [
                        "Demand certainty from God before obeying the next right step.",
                        "Receive today's assignment faithfully, knowing only God sees the whole picture.",
                        "Treat waiting seasons as proof that life has stalled.",
                        "Assume that reverence and joy cannot exist together."
                    ],
                    correctIndex: 1,
                    explanation: "Ecclesiastes 3 calls learners to humble faithfulness in the season God has actually given."
                )
            ]
        ),
        BiblicalWisdomV2Blueprint(
            id: "wisdom-v2-ecclesiastes-7",
            order: 5,
            title: "Ecclesiastes 7: Sorrow, Correction, and Restraint",
            sourceName: "Bible: Ecclesiastes 7",
            sourceURL: "https://www.biblegateway.com/passage/?search=Ecclesiastes+7&version=KJV",
            summary: "Ecclesiastes 7 teaches a more mature kind of wisdom than simple positivity. The chapter values the house of mourning over the house of mirth, honest rebuke over flattering entertainment, patience over pride, and careful restraint over quick anger. It forms learners to grow through difficulty instead of escaping whatever feels heavy.",
            keyIdeas: [
                "Biblical wisdom does not treat sorrow as automatically bad; some painful settings teach truth better than shallow celebration.",
                "Loving correction is better than flattering noise because wisdom values formation over comfort.",
                "Quick anger and nostalgic idealism both reveal impatience with reality and God's present work.",
                "Ecclesiastes 7 teaches sober humility: no one is perfectly righteous, so wisdom stays teachable."
            ],
            keyVerses: ["Ecclesiastes 7:2", "Ecclesiastes 7:5", "Ecclesiastes 7:9"],
            questions: [
                WisdomQuestion(
                    id: "wisdomv2-ecc7-q1",
                    prompt: "Why does Ecclesiastes 7 value the house of mourning more than the house of feasting?",
                    options: [
                        "Because grief is spiritually better than joy in every situation.",
                        "Because difficult realities can sober the heart and teach wisdom more deeply than constant amusement.",
                        "Because wise people should avoid celebration completely.",
                        "Because pleasure itself is always sinful."
                    ],
                    correctIndex: 1,
                    explanation: "The chapter is not condemning joy; it is teaching that serious reflection often produces deeper wisdom."
                ),
                WisdomQuestion(
                    id: "wisdomv2-ecc7-q2",
                    prompt: "What makes rebuke from the wise better than the song of fools?",
                    options: [
                        "It feels better in the moment.",
                        "It protects pride while sounding spiritual.",
                        "It forms character even when it is uncomfortable.",
                        "It guarantees that conflict will disappear."
                    ],
                    correctIndex: 2,
                    explanation: "Wise rebuke serves growth, while empty amusement can distract from needed change."
                ),
                WisdomQuestion(
                    id: "wisdomv2-ecc7-q3",
                    prompt: "Which response best fits Ecclesiastes 7:9?",
                    options: [
                        "Hold onto irritation until people finally understand your point.",
                        "Let anger rise quickly because it proves you care about truth.",
                        "See anger as mostly harmless if it stays internal.",
                        "Refuse quick anger, because a wise heart does not make a home for it."
                    ],
                    correctIndex: 3,
                    explanation: "The chapter links quick anger with foolishness, not maturity."
                )
            ]
        ),
        BiblicalWisdomV2Blueprint(
            id: "wisdom-v2-matthew-7",
            order: 6,
            title: "Matthew 7: Hearing Jesus and Building on the Rock",
            sourceName: "Bible: Matthew 7",
            sourceURL: "https://www.biblegateway.com/passage/?search=Matthew+7&version=KJV",
            summary: "Matthew 7 gathers Jesus' wisdom for discernment, prayer, relationships, and obedience. The chapter warns against hypocritical judgment, urges persistent asking, exposes false prophets by their fruit, and ends with the famous contrast between the wise builder and the foolish builder. Wisdom in Jesus' teaching is never mere listening; it is hearing and doing.",
            keyIdeas: [
                "Jesus rejects hypocritical judgment, not careful discernment; wise people inspect themselves before correcting others.",
                "Persistent asking, seeking, and knocking show relational dependence on the Father.",
                "Fruit reveals reality: words, claims, and appearances are not enough to identify true obedience.",
                "The wise builder is defined by practiced obedience, not by admiration of Jesus alone."
            ],
            keyVerses: ["Matthew 7:3", "Matthew 7:12", "Matthew 7:24"],
            questions: [
                WisdomQuestion(
                    id: "wisdomv2-matt7-q1",
                    prompt: "What is Jesus correcting in the opening section of Matthew 7?",
                    options: [
                        "All forms of moral evaluation.",
                        "Hypocritical judgment that ignores one's own need for repentance.",
                        "Any attempt to help another believer grow.",
                        "Serious concern for truth and fruit."
                    ],
                    correctIndex: 1,
                    explanation: "Jesus addresses self-righteous blindness, not the need for discernment itself."
                ),
                WisdomQuestion(
                    id: "wisdomv2-matt7-q2",
                    prompt: "How does Matthew 7 teach believers to identify false teachers and false profession?",
                    options: [
                        "By how confidently people speak.",
                        "By visible fruit that reveals whether life matches truth.",
                        "By whether they impress a large crowd.",
                        "By how emotional their worship feels."
                    ],
                    correctIndex: 1,
                    explanation: "Jesus says fruit, not appearance, exposes what is real."
                ),
                WisdomQuestion(
                    id: "wisdomv2-matt7-q3",
                    prompt: "Who is the wise builder at the end of Matthew 7?",
                    options: [
                        "The one who hears Jesus and appreciates His teaching style.",
                        "The one who can explain doctrine clearly but avoids application.",
                        "The one who hears Jesus' words and puts them into practice.",
                        "The one who avoids storms by choosing safer circumstances."
                    ],
                    correctIndex: 2,
                    explanation: "Jesus defines wisdom as obedient response, not information alone."
                )
            ]
        ),
        BiblicalWisdomV2Blueprint(
            id: "wisdom-v2-luke-12",
            order: 7,
            title: "Luke 12: Treasure, Greed, and Readiness",
            sourceName: "Bible: Luke 12",
            sourceURL: "https://www.biblegateway.com/passage/?search=Luke+12&version=KJV",
            summary: "Luke 12 exposes the false security of possessions and the foolishness of living without reference to God. The rich fool stores more but prepares less. Jesus then teaches His disciples not to be consumed by anxious striving, but to seek the kingdom, hold possessions loosely, and live ready for the Master's return.",
            keyIdeas: [
                "Greed is not measured only by abundance; it is measured by what the heart trusts and serves.",
                "The rich fool misread success because he planned for bigger storage, not for standing before God.",
                "Jesus answers anxiety by redirecting value, identity, and pursuit toward the kingdom.",
                "Wise readiness means stewardship in the present, not panic about the future."
            ],
            keyVerses: ["Luke 12:15", "Luke 12:21", "Luke 12:31"],
            questions: [
                WisdomQuestion(
                    id: "wisdomv2-luke12-q1",
                    prompt: "What made the rich man in Luke 12 a fool?",
                    options: [
                        "He worked in agriculture instead of ministry.",
                        "He saved money instead of spending it immediately.",
                        "He planned for larger barns but failed to reckon with God, eternity, and the true purpose of life.",
                        "He owned property during a difficult economy."
                    ],
                    correctIndex: 2,
                    explanation: "His problem was not planning alone, but planning that excluded God and treated possessions as ultimate security."
                ),
                WisdomQuestion(
                    id: "wisdomv2-luke12-q2",
                    prompt: "How does Jesus confront anxiety in Luke 12?",
                    options: [
                        "By promising disciples they will always have more than others.",
                        "By calling disciples to seek the kingdom and trust the Father's care.",
                        "By teaching that concern for tomorrow is always a lack of faith, no matter the context.",
                        "By telling disciples to ignore earthly responsibilities."
                    ],
                    correctIndex: 1,
                    explanation: "Jesus redirects anxious striving toward trust in the Father and pursuit of the kingdom."
                ),
                WisdomQuestion(
                    id: "wisdomv2-luke12-q3",
                    prompt: "A wise application of Luke 12 would lead someone to:",
                    options: [
                        "Treat possessions as tools for stewardship instead of proof of safety.",
                        "Avoid planning because any financial thought is worldly.",
                        "Measure spiritual maturity by visible prosperity.",
                        "Postpone generosity until every personal goal is secured."
                    ],
                    correctIndex: 0,
                    explanation: "Luke 12 trains the heart to value the kingdom above accumulation and anxiety."
                )
            ]
        ),
        BiblicalWisdomV2Blueprint(
            id: "wisdom-v2-romans-12",
            order: 8,
            title: "Romans 12: Renewed Minds and Sober Judgment",
            sourceName: "Bible: Romans 12",
            sourceURL: "https://www.biblegateway.com/passage/?search=Romans+12&version=KJV",
            summary: "Romans 12 moves from doctrine to transformed life. Paul calls believers to present themselves as living sacrifices, reject conformity to the world's patterns, and experience mind-renewal that leads to tested discernment. The chapter then works out wisdom in humility, community, love, suffering, peacemaking, and overcoming evil with good.",
            keyIdeas: [
                "Discernment in Romans 12 comes from renewed minds, not from stronger instincts or louder confidence.",
                "Paul links sober self-judgment with healthy community life and faithful use of gifts.",
                "Biblical love is active and concrete: honoring, serving, blessing enemies, and rejecting revenge.",
                "Overcoming evil with good is not passive weakness; it is a wisdom strategy rooted in God's mercy."
            ],
            keyVerses: ["Romans 12:1", "Romans 12:2", "Romans 12:21"],
            questions: [
                WisdomQuestion(
                    id: "wisdomv2-rom12-q1",
                    prompt: "According to Romans 12:2, how is discernment formed?",
                    options: [
                        "By conforming carefully to successful cultural patterns.",
                        "By mind renewal that tests and approves God's will.",
                        "By having stronger emotions during worship.",
                        "By avoiding all contact with difficult people."
                    ],
                    correctIndex: 1,
                    explanation: "Paul ties discernment directly to transformed thinking rather than cultural conformity."
                ),
                WisdomQuestion(
                    id: "wisdomv2-rom12-q2",
                    prompt: "Why does Paul stress sober judgment about oneself in Romans 12?",
                    options: [
                        "Because insecurity is the main sign of maturity.",
                        "Because spiritual gifts are dangerous and should be hidden.",
                        "Because humility helps believers serve rightly inside the body instead of competing for status.",
                        "Because individual growth matters more than the church."
                    ],
                    correctIndex: 2,
                    explanation: "Romans 12 connects humility to healthy service and realistic self-understanding."
                ),
                WisdomQuestion(
                    id: "wisdomv2-rom12-q3",
                    prompt: "Which response shows Romans 12 wisdom in conflict?",
                    options: [
                        "Return sharpness for sharpness so evil loses its advantage.",
                        "Wait until feelings improve before choosing good.",
                        "Refuse revenge and actively overcome evil with good.",
                        "Stay neutral because direct love is usually unsafe."
                    ],
                    correctIndex: 2,
                    explanation: "Paul frames enemy-love and non-retaliation as active gospel-shaped wisdom."
                )
            ]
        ),
        BiblicalWisdomV2Blueprint(
            id: "wisdom-v2-james-1",
            order: 9,
            title: "James 1: Ask for Wisdom, Endure Trials, Do the Word",
            sourceName: "Bible: James 1",
            sourceURL: "https://www.biblegateway.com/passage/?search=James+1&version=KJV",
            summary: "James 1 teaches that wisdom is needed most when life becomes unstable. Trials expose faith, produce steadfastness, and push believers to ask God for wisdom without double-mindedness. The chapter also exposes temptation as arising from disordered desire and warns that hearing truth without doing it is a form of self-deception.",
            keyIdeas: [
                "Trials are not automatically good, but God uses them to mature steadfast faith when believers respond rightly.",
                "Asking for wisdom in James 1 is not about collecting abstract answers; it is about receiving guidance for faithful endurance.",
                "Temptation is not blamed on God; James forces the learner to examine the heart's desires honestly.",
                "The chapter ends by redefining spiritual maturity as doing the Word, not merely hearing it."
            ],
            keyVerses: ["James 1:5", "James 1:12", "James 1:22"],
            questions: [
                WisdomQuestion(
                    id: "wisdomv2-james1-q1",
                    prompt: "Why does James connect trials with wisdom?",
                    options: [
                        "Because hard seasons reveal what kind of faith is actually operating and require God-shaped endurance.",
                        "Because all pain is automatically a sign of failure.",
                        "Because wisdom matters mainly when life is calm and predictable.",
                        "Because Christians should enjoy suffering for its own sake."
                    ],
                    correctIndex: 0,
                    explanation: "James sees trials as moments where endurance, dependence, and wisdom become visible."
                ),
                WisdomQuestion(
                    id: "wisdomv2-james1-q2",
                    prompt: "What does James warn about double-mindedness?",
                    options: [
                        "It means thinking deeply before acting.",
                        "It means asking God while refusing stable trust in Him.",
                        "It means using both Old and New Testaments together.",
                        "It means serving others too consistently."
                    ],
                    correctIndex: 1,
                    explanation: "Double-mindedness describes divided allegiance, not careful reflection."
                ),
                WisdomQuestion(
                    id: "wisdomv2-james1-q3",
                    prompt: "Who is the deceived person at the end of James 1?",
                    options: [
                        "The one who hears the Word but does not act on it.",
                        "The one who struggles to understand everything immediately.",
                        "The one who asks for help while growing.",
                        "The one who remembers Scripture in prayer."
                    ],
                    correctIndex: 0,
                    explanation: "James insists that hearing without doing is a false form of spirituality."
                )
            ]
        ),
        BiblicalWisdomV2Blueprint(
            id: "wisdom-v2-james-3",
            order: 10,
            title: "James 3: Wisdom From Above",
            sourceName: "Bible: James 3",
            sourceURL: "https://www.biblegateway.com/passage/?search=James+3&version=KJV",
            summary: "James 3 contrasts two kinds of wisdom by tracing them into speech, ambition, and community life. Earthly wisdom is fueled by bitter jealousy and selfish ambition, producing disorder and every vile practice. Wisdom from above is pure, peaceable, gentle, open to reason, full of mercy, fruitful, impartial, and sincere. The chapter trains learners to judge wisdom by its fruit, not by its branding.",
            keyIdeas: [
                "James links the tongue to the heart, showing that speech is a diagnostic tool for inner wisdom or folly.",
                "Earthly wisdom can look strategic and strong while actually feeding rivalry and chaos.",
                "Wisdom from above is recognized by moral purity, relational peace, teachability, mercy, and sincerity.",
                "The chapter teaches believers to evaluate leadership, influence, and their own motives by the fruit they produce."
            ],
            keyVerses: ["James 3:5", "James 3:14", "James 3:17"],
            questions: [
                WisdomQuestion(
                    id: "wisdomv2-james3-q1",
                    prompt: "How does James 3 expose false wisdom?",
                    options: [
                        "False wisdom is shown by polished speech alone.",
                        "False wisdom is seen when bitter jealousy and selfish ambition produce disorder.",
                        "False wisdom is any form of careful planning.",
                        "False wisdom only appears in explicitly secular settings."
                    ],
                    correctIndex: 1,
                    explanation: "James measures wisdom by its fruit, especially the disorder produced by selfish ambition."
                ),
                WisdomQuestion(
                    id: "wisdomv2-james3-q2",
                    prompt: "Which trait belongs to wisdom from above in James 3:17?",
                    options: [
                        "Manipulative certainty",
                        "Self-protective harshness",
                        "Open-to-reason gentleness",
                        "Competitive superiority"
                    ],
                    correctIndex: 2,
                    explanation: "James describes heavenly wisdom as peaceable, gentle, teachable, and merciful."
                ),
                WisdomQuestion(
                    id: "wisdomv2-james3-q3",
                    prompt: "A mature reader of James 3 should conclude that wisdom is best evaluated by:",
                    options: [
                        "How quickly a person wins arguments.",
                        "The fruit a person's speech, motives, and relationships consistently produce.",
                        "How forcefully a person presents an opinion.",
                        "Whether a leader appears impressive in public."
                    ],
                    correctIndex: 1,
                    explanation: "James teaches believers to evaluate wisdom by its moral and relational outcomes."
                )
            ]
        )
    ]

    private static func buildBiblicalWisdomV2Lessons() -> [WisdomLesson] {
        biblicalWisdomV2Blueprints.map { blueprint in
            WisdomLesson(
                id: blueprint.id,
                order: blueprint.order,
                title: blueprint.title,
                sourceName: blueprint.sourceName,
                sourceURL: blueprint.sourceURL,
                summary: blueprint.summary,
                keyIdeas: blueprint.keyIdeas,
                keyVerses: blueprint.keyVerses,
                quest: WisdomQuest(
                    passingScore: 70,
                    questions: blueprint.questions
                )
            )
        }
    }
}

struct LessonProgress: Codable, Hashable {
    var lessonCompleted: Bool
    var quizPassed: Bool
    var quizAttempts: Int
    var bestQuizScore: Int
    var lastQuizScore: Int
    var completedAt: Date?
    var passedAt: Date?

    static let empty = LessonProgress(
        lessonCompleted: false,
        quizPassed: false,
        quizAttempts: 0,
        bestQuizScore: 0,
        lastQuizScore: 0,
        completedAt: nil,
        passedAt: nil
    )
}

struct QuestAttempt: Identifiable, Codable, Hashable {
    let id: UUID
    let lessonID: String
    let score: Int
    let passed: Bool
    let attemptedAt: Date

    init(id: UUID = UUID(), lessonID: String, score: Int, passed: Bool, attemptedAt: Date = .now) {
        self.id = id
        self.lessonID = lessonID
        self.score = score
        self.passed = passed
        self.attemptedAt = attemptedAt
    }
}

struct QuestSubmissionResult {
    let score: Int
    let passed: Bool
    let pointsEarned: Int
    let correctAnswers: Int
    let totalQuestions: Int
}

struct NoteSaveResult {
    let saved: Bool
    let pointsEarned: Int
}

enum WisdomStoreCategory: String, Codable, Hashable, CaseIterable {
    case growth
    case profile
    case utility

    var title: String {
        switch self {
        case .growth:
            return "Growth"
        case .profile:
            return "Profile"
        case .utility:
            return "Utility"
        }
    }
}

struct WisdomStoreItem: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let detail: String
    let pointsCost: Int
    let category: WisdomStoreCategory
    let icon: String
}

enum WisdomStoreCatalog {
    static let items: [WisdomStoreItem] = [
        WisdomStoreItem(
            id: "store_devotional_promises",
            name: "7-Day Promise Devotional",
            detail: "A guided 7-day reading and prayer track focused on God's promises.",
            pointsCost: 250,
            category: .growth,
            icon: "book.closed.fill"
        ),
        WisdomStoreItem(
            id: "store_devotional_peace",
            name: "Peace Under Pressure Plan",
            detail: "A practical Scripture plan for anxiety, pressure, and decision stress.",
            pointsCost: 300,
            category: .growth,
            icon: "leaf.fill"
        ),
        WisdomStoreItem(
            id: "store_quest_pack_parables",
            name: "Parables Quest Pack",
            detail: "Bonus quiz pack based on Jesus' parables and daily application prompts.",
            pointsCost: 350,
            category: .growth,
            icon: "sparkles"
        ),
        WisdomStoreItem(
            id: "store_badge_faithful_learner",
            name: "Faithful Learner Badge",
            detail: "Display a public profile badge that signals consistent biblical growth.",
            pointsCost: 200,
            category: .profile,
            icon: "rosette"
        ),
        WisdomStoreItem(
            id: "store_badge_prayer_builder",
            name: "Prayer Builder Badge",
            detail: "Public badge for users who stay active in prayer and reflection habits.",
            pointsCost: 220,
            category: .profile,
            icon: "hands.sparkles.fill"
        ),
        WisdomStoreItem(
            id: "store_profile_theme_sky",
            name: "Sky Theme Pack",
            detail: "Unlock an alternate soft-blue profile style for your account screen.",
            pointsCost: 180,
            category: .profile,
            icon: "paintpalette.fill"
        ),
        WisdomStoreItem(
            id: "store_streak_shield",
            name: "Streak Shield (1 use)",
            detail: "Protect your streak for one missed day. Great for travel or emergencies.",
            pointsCost: 400,
            category: .utility,
            icon: "shield.fill"
        ),
        WisdomStoreItem(
            id: "store_note_boost_pack",
            name: "Advanced Notes Template Pack",
            detail: "Unlock expanded note templates with sermon-style prompts.",
            pointsCost: 280,
            category: .utility,
            icon: "square.and.pencil"
        )
    ]
}

struct LessonNoteTemplate: Hashable, Codable {
    var keyTruth: String
    var keyVerse: String
    var applicationToday: String
    var prayerResponse: String

    static let empty = LessonNoteTemplate(
        keyTruth: "",
        keyVerse: "",
        applicationToday: "",
        prayerResponse: ""
    )
}

struct LessonNote: Identifiable, Hashable, Codable {
    let id: UUID
    let lessonID: String
    let lessonOrder: Int
    let lessonTitle: String
    var keyTruth: String
    var keyVerse: String
    var applicationToday: String
    var prayerResponse: String
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        lessonID: String,
        lessonOrder: Int,
        lessonTitle: String,
        keyTruth: String,
        keyVerse: String,
        applicationToday: String,
        prayerResponse: String,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.lessonID = lessonID
        self.lessonOrder = lessonOrder
        self.lessonTitle = lessonTitle
        self.keyTruth = keyTruth
        self.keyVerse = keyVerse
        self.applicationToday = applicationToday
        self.prayerResponse = prayerResponse
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var searchableText: String {
        [
            lessonTitle,
            keyTruth,
            keyVerse,
            applicationToday,
            prayerResponse
        ].joined(separator: " ").lowercased()
    }
}

struct PrayerFeedPost: Identifiable, Hashable, Codable {
    let id: UUID
    let authorName: String
    let handle: String
    let prayerTopic: String
    let message: String
    let createdAt: Date
    var amens: Int
    var didAmen: Bool

    init(
        id: UUID = UUID(),
        authorName: String,
        handle: String,
        prayerTopic: String,
        message: String,
        createdAt: Date = .now,
        amens: Int = 0,
        didAmen: Bool = false
    ) {
        self.id = id
        self.authorName = authorName
        self.handle = handle
        self.prayerTopic = prayerTopic
        self.message = message
        self.createdAt = createdAt
        self.amens = amens
        self.didAmen = didAmen
    }
}

struct DailyGrowthEntry: Identifiable, Hashable, Codable {
    let id: UUID
    let createdAt: Date
    let learnedToday: String
    let applicationPlan: String
    let prayerAction: String

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        learnedToday: String,
        applicationPlan: String,
        prayerAction: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.learnedToday = learnedToday
        self.applicationPlan = applicationPlan
        self.prayerAction = prayerAction
    }
}

struct VerseInsight: Hashable, Codable {
    let reference: String
    let writtenAbout: String
    let summary: String
    let deeperMeaning: String
}

enum VerseInsightLibrary {
    static func insight(for reference: String) -> VerseInsight {
        let key = normalize(reference)
        if let found = map[key] {
            return found
        }

        return VerseInsight(
            reference: reference,
            writtenAbout: "Godly wisdom for real decisions",
            summary: "This verse points you toward wisdom shaped by God's truth instead of impulse.",
            deeperMeaning: "Biblical wisdom is not only knowledge. It is trust, obedience, and discernment practiced daily."
        )
    }

    private static func normalize(_ reference: String) -> String {
        reference.lowercased().replacingOccurrences(of: " ", with: "")
    }

    private static let map: [String: VerseInsight] = [
        "proverbs1:7": VerseInsight(
            reference: "Proverbs 1:7",
            writtenAbout: "The starting point of true wisdom",
            summary: "Wisdom begins with reverence for God, while fools reject instruction.",
            deeperMeaning: "When God is central, your decisions gain clarity. Without that posture, knowledge alone can still lead to folly."
        ),
        "proverbs9:10": VerseInsight(
            reference: "Proverbs 9:10",
            writtenAbout: "Foundation of wise understanding",
            summary: "Knowing God rightly is the root of wisdom and understanding.",
            deeperMeaning: "Real discernment is relational before it is technical. You grow wiser as your life aligns with God's character."
        ),
        "proverbs3:7": VerseInsight(
            reference: "Proverbs 3:7",
            writtenAbout: "Rejecting self-made wisdom",
            summary: "Do not trust your own wisdom; fear the Lord and turn from evil.",
            deeperMeaning: "Wisdom matures through humility. Pride makes you unteachable, but reverence makes correction possible."
        ),
        "proverbs4:23": VerseInsight(
            reference: "Proverbs 4:23",
            writtenAbout: "Guarding your inner life",
            summary: "Your heart must be guarded because life direction flows from it.",
            deeperMeaning: "What you repeatedly focus on becomes what you desire, and what you desire eventually becomes how you live."
        ),
        "proverbs4:25-27": VerseInsight(
            reference: "Proverbs 4:25-27",
            writtenAbout: "Focused moral direction",
            summary: "Keep your eyes on the right path and do not turn aside.",
            deeperMeaning: "Wisdom is directional consistency. Small course corrections today prevent major compromise later."
        ),
        "philippians4:8": VerseInsight(
            reference: "Philippians 4:8",
            writtenAbout: "Thought-life formation",
            summary: "Intentionally think on what is true, honorable, and pure.",
            deeperMeaning: "Your mind is not neutral territory. Wise thinking protects your heart and shapes obedient action."
        ),
        "proverbs15:1": VerseInsight(
            reference: "Proverbs 15:1",
            writtenAbout: "Conflict and wise speech",
            summary: "A gentle answer can calm anger; harsh words escalate conflict.",
            deeperMeaning: "Wisdom in speech is not weakness. It is strength under control, using words for peace and truth."
        ),
        "proverbs18:21": VerseInsight(
            reference: "Proverbs 18:21",
            writtenAbout: "Power of the tongue",
            summary: "Words carry power for life or death.",
            deeperMeaning: "Speech creates spiritual direction. Consistent wise words build trust, hope, and healing over time."
        ),
        "proverbs12:18": VerseInsight(
            reference: "Proverbs 12:18",
            writtenAbout: "Wounds or healing through words",
            summary: "Reckless speech wounds; wise speech heals.",
            deeperMeaning: "Wisdom asks not only 'Is it true?' but also 'How do I speak truth in a way that heals?'"
        ),
        "proverbs11:2": VerseInsight(
            reference: "Proverbs 11:2",
            writtenAbout: "Pride vs humility",
            summary: "Pride leads to shame, but humility brings wisdom.",
            deeperMeaning: "Humility is a strategic strength because it keeps you teachable, correctable, and spiritually safe."
        ),
        "proverbs16:18": VerseInsight(
            reference: "Proverbs 16:18",
            writtenAbout: "Danger of pride",
            summary: "Pride goes before destruction.",
            deeperMeaning: "Collapse often starts internally before it appears externally. Wisdom resists self-exaltation early."
        ),
        "proverbs22:4": VerseInsight(
            reference: "Proverbs 22:4",
            writtenAbout: "Reward of humility and fear of the Lord",
            summary: "Humility and reverence for God lead to life-giving fruit.",
            deeperMeaning: "Godly growth is usually gradual. Faithful humility compounds into lasting spiritual stability."
        ),
        "proverbs6:6-8": VerseInsight(
            reference: "Proverbs 6:6-8",
            writtenAbout: "Diligence and initiative",
            summary: "Observe the ant: faithful preparation and initiative produce readiness.",
            deeperMeaning: "Wisdom honors consistent stewardship. You do not need pressure to start doing what is right."
        ),
        "proverbs13:4": VerseInsight(
            reference: "Proverbs 13:4",
            writtenAbout: "Desire and disciplined effort",
            summary: "The diligent are satisfied; idle desire stays empty.",
            deeperMeaning: "Wisdom closes the gap between intentions and actions through daily discipline."
        ),
        "proverbs14:23": VerseInsight(
            reference: "Proverbs 14:23",
            writtenAbout: "Work over empty talk",
            summary: "Faithful labor brings profit; empty talk leads to lack.",
            deeperMeaning: "Spiritual maturity is practiced in concrete action, not only in inspiring language."
        ),
        "proverbs13:20": VerseInsight(
            reference: "Proverbs 13:20",
            writtenAbout: "Influence of companions",
            summary: "Walking with the wise grows wisdom; foolish company brings harm.",
            deeperMeaning: "Your relationships are formation systems. Who you follow becomes who you become."
        ),
        "proverbs15:22": VerseInsight(
            reference: "Proverbs 15:22",
            writtenAbout: "Value of counsel",
            summary: "Plans fail without counsel but succeed with many advisers.",
            deeperMeaning: "Wisdom invites outside perspective because blind spots are normal, not exceptional."
        ),
        "proverbs27:17": VerseInsight(
            reference: "Proverbs 27:17",
            writtenAbout: "Mutual sharpening",
            summary: "People can sharpen one another through honest relationship.",
            deeperMeaning: "Accountability is a grace. Loving correction can accelerate growth when received with humility."
        ),
        "proverbs11:1": VerseInsight(
            reference: "Proverbs 11:1",
            writtenAbout: "Integrity in dealings",
            summary: "Dishonesty is detestable to God; integrity is pleasing to Him.",
            deeperMeaning: "Wisdom chooses righteousness over short-term gain because character outlasts advantage."
        ),
        "proverbs3:9-10": VerseInsight(
            reference: "Proverbs 3:9-10",
            writtenAbout: "Honoring God with resources",
            summary: "Honor God with your wealth and firstfruits.",
            deeperMeaning: "Generosity is theological: it declares trust in God, not ultimate trust in money."
        ),
        "proverbs22:7": VerseInsight(
            reference: "Proverbs 22:7",
            writtenAbout: "Financial realities and stewardship",
            summary: "Debt can create forms of bondage and limitation.",
            deeperMeaning: "Wisdom in finances protects freedom for obedience, generosity, and long-term faithfulness."
        ),
        "proverbs21:3": VerseInsight(
            reference: "Proverbs 21:3",
            writtenAbout: "Justice over performance",
            summary: "God values righteousness and justice more than empty ritual.",
            deeperMeaning: "Biblical wisdom ties devotion to ethical living. Worship and justice are meant to stay together."
        ),
        "proverbs24:3-6": VerseInsight(
            reference: "Proverbs 24:3-6",
            writtenAbout: "Wisdom for building and strategy",
            summary: "Wise plans, knowledge, and counsel build stable outcomes.",
            deeperMeaning: "Discernment is not passivity. Wisdom plans carefully while remaining dependent on God."
        ),
        "proverbs3:5-6": VerseInsight(
            reference: "Proverbs 3:5-6",
            writtenAbout: "Trusting God over self-reliance",
            summary: "Trust the Lord fully, acknowledge Him, and He directs your path.",
            deeperMeaning: "Wisdom means surrendering control. As dependence deepens, direction becomes clearer."
        ),
        "james1:5": VerseInsight(
            reference: "James 1:5",
            writtenAbout: "Asking God for wisdom",
            summary: "God gives wisdom generously to those who ask.",
            deeperMeaning: "You are not expected to navigate life alone. Prayer is a wisdom habit, not only an emergency response."
        )
    ]
}

extension WisdomLesson {
    var assessmentQuest: WisdomQuest {
        let shuffledBaseQuestions = quest.questions.map {
            $0.deterministicallyShuffled(seed: "\(id)-\($0.id)-base")
        }
        let combined: [WisdomQuestion]

        if id.hasPrefix("james-school-") || id.hasPrefix("proverbs-chapter-") || id.hasPrefix("bible-year-") {
            combined = shuffledBaseQuestions
        } else {
            let challengeQuestions = buildChallengeQuestions()
            combined = (shuffledBaseQuestions + challengeQuestions).sorted {
                stableHash64("\(id)-order-\($0.id)") < stableHash64("\(id)-order-\($1.id)")
            }
        }

        return WisdomQuest(
            passingScore: quest.passingScore,
            questions: combined
        )
    }

    var slides: [LessonSlide] {
        let verses = keyVerses.isEmpty ? ["James 1:5"] : keyVerses
        let isWisdomV2Lesson = id.hasPrefix("wisdom-v2-")
        let verseAt: (Int) -> String = { index in
            verses[index % verses.count]
        }
        let ideaOne = keyIdeas[safe: 0] ?? summary
        let ideaTwo = keyIdeas[safe: 1] ?? ideaOne
        let ideaThree = keyIdeas[safe: 2] ?? ideaTwo
        let ideaFour = keyIdeas[safe: 3] ?? ideaThree

        let slideOne = LessonSlide(
            id: "\(id)-slide-1",
            title: "Lesson Focus",
            body: "\(summary)\n\nThis lesson is here to help you understand the truth clearly and practice it in normal daily decisions.",
            bullets: [
                "Primary source: \(sourceName)",
                "Goal: move from information to faithful obedience",
                "Result: clearer decisions shaped by God's Word"
            ],
            supportVerse: verseAt(0),
            reflectionPrompt: "Where do you most need biblical wisdom this week?"
        )

        let slideTwo = LessonSlide(
            id: "\(id)-slide-2",
            title: "Core Truth 1",
            body: "\(ideaOne)\n\nSimple meaning: biblical wisdom starts by putting God first, not mood, pressure, or convenience.",
            bullets: [
                "Start with: What honors Christ here?",
                "Slow down your first reaction",
                "Choose obedience over image"
            ],
            supportVerse: verseAt(1),
            reflectionPrompt: "Which recent decision shows your need for this truth?"
        )

        let slideThree = LessonSlide(
            id: "\(id)-slide-3",
            title: "Core Truth 2",
            body: "\(ideaTwo)\n\nSimple meaning: wisdom is seen in response, speech, and priorities, not only in what we know.",
            bullets: [
                "Foolishness often resists correction",
                "Wisdom listens, tests, and responds with humility",
                "Prayer and Scripture must shape real choices"
            ],
            supportVerse: verseAt(2),
            reflectionPrompt: "Where are you being invited to receive correction?"
        )

        let slideFour = LessonSlide(
            id: "\(id)-slide-4",
            title: "Checkpoint Review",
            body: "Before moving on, summarize the first three slides in one sentence and make sure you can explain them clearly.",
            bullets: [
                "Truth understood is not yet truth applied",
                "You will answer one checkpoint question next",
                "Use your notes to lock in the core idea"
            ],
            supportVerse: verseAt(0),
            reflectionPrompt: "Can you explain this lesson to a friend in plain language?"
        )

        let slideFive = LessonSlide(
            id: "\(id)-slide-5",
            title: "Core Truth 3",
            body: "\(ideaThree)\n\nSimple meaning: wisdom grows through faithful patterns over time, not occasional intensity.",
            bullets: [
                "Small obedient habits compound",
                "Consistency beats motivation spikes",
                "Repent quickly when you fail, then continue"
            ],
            supportVerse: verseAt(1),
            reflectionPrompt: "What one habit will you practice for the next 7 days?"
        )

        let slideSix = LessonSlide(
            id: "\(id)-slide-6",
            title: isWisdomV2Lesson ? "Checkpoint Review 2" : "Practice Scenario",
            body: isWisdomV2Lesson
                ? "Pause again and restate the lesson's main argument without looking back. If you had to teach this chapter to someone else, what are the two truths they must not miss?"
                : "Imagine a difficult conversation, a tempting compromise, or a stressful decision. Apply this lesson before acting.",
            bullets: [
                isWisdomV2Lesson ? "Summarize the chapter in your own words" : "Pause: what does Scripture say here?",
                isWisdomV2Lesson ? "Connect one key verse to one real decision" : "Pray briefly before you respond",
                isWisdomV2Lesson ? "Name the obedience the chapter is calling for" : "Choose the next obedient action, not the easiest action"
            ],
            supportVerse: verseAt(2),
            reflectionPrompt: isWisdomV2Lesson
                ? "What part of this lesson would be hardest to explain clearly right now?"
                : "Which real situation today will you apply this to?"
        )

        let slideSeven = LessonSlide(
            id: "\(id)-slide-7",
            title: isWisdomV2Lesson ? "Core Truth 4" : "Verse Lab",
            body: isWisdomV2Lesson
                ? "\(ideaFour)\n\nSimple meaning: mature wisdom is not only about understanding a truth, but knowing how it reshapes your pace, your motives, and your relationships."
                : "Use these lesson verses as decision tools. Read, paraphrase, and connect each verse to one concrete behavior.",
            bullets: isWisdomV2Lesson ? [
                "Ask: what motive does this truth expose?",
                "Ask: what habit does this truth build?",
                "Ask: what relationship does this truth change?"
            ] : verses,
            supportVerse: verseAt(0),
            reflectionPrompt: isWisdomV2Lesson
                ? "What change would prove this truth is really sinking in?"
                : "Which verse will guide one decision in the next 24 hours?"
        )

        let slideEight = LessonSlide(
            id: "\(id)-slide-8",
            title: isWisdomV2Lesson ? "Practice Scenario" : "Quest Preparation",
            body: isWisdomV2Lesson
                ? "Now apply the chapter to a realistic moment: tension, delay, temptation, stress, disappointment, or leadership pressure. The point is to move from explanation to response."
                : "You are ready for the lesson quest. The goal is not guessing; it is proving you understand and can apply biblical wisdom.",
            bullets: [
                isWisdomV2Lesson ? "Name the wise response before naming the easy response" : "Passing score: \(quest.passingScore)%",
                isWisdomV2Lesson ? "Ground your answer in one verse from the lesson" : "Read your notes before starting",
                isWisdomV2Lesson ? "Choose the next obedient action, not the most comfortable action" : "Passing unlocks the next lesson"
            ],
            supportVerse: verseAt(1),
            reflectionPrompt: isWisdomV2Lesson
                ? "Where are you most tempted to know the truth without doing it?"
                : "What is the single most important truth from this lesson?"
        )

        if !isWisdomV2Lesson {
            return [slideOne, slideTwo, slideThree, slideFour, slideFive, slideSix, slideSeven, slideEight]
        }

        let slideNine = LessonSlide(
            id: "\(id)-slide-9",
            title: "Verse Lab",
            body: "Use these lesson verses as decision tools. Read, paraphrase, and connect each verse to one concrete behavior before taking the quest.",
            bullets: verses,
            supportVerse: verseAt(0),
            reflectionPrompt: "Which verse should stay in front of you for the next 24 hours?"
        )

        let slideTen = LessonSlide(
            id: "\(id)-slide-10",
            title: "Quest Preparation",
            body: "You are ready for the lesson quest. These questions are built to check understanding, not speed, so slow down and answer like a learner.",
            bullets: [
                "Passing score: \(quest.passingScore)%",
                "Review your notes and the checkpoint slides",
                "Aim to explain the truth, not just recognize a phrase"
            ],
            supportVerse: verseAt(1),
            reflectionPrompt: "What is the central argument of this chapter in one sentence?"
        )

        return [slideOne, slideTwo, slideThree, slideFour, slideFive, slideSix, slideSeven, slideEight, slideNine, slideTen]
    }

    private func buildChallengeQuestions() -> [WisdomQuestion] {
        let primaryVerse = keyVerses.first ?? "James 1:5"
        let focusPhrase = shortPhrase(from: keyIdeas[safe: 0] ?? summary)

        let questionOne = makeChallengeQuestion(
            idSuffix: "challenge-focus",
            prompt: "Pick the phrase closest to this lesson's focus.",
            correct: "\(focusPhrase) obedience",
            distractors: [
                "\(focusPhrase) image",
                "\(focusPhrase) impulse",
                "Self-first obedience"
            ],
            explanation: "Wisdom is not image management. It is practical obedience rooted in God's truth."
        )

        let questionTwo = makeChallengeQuestion(
            idSuffix: "challenge-verse",
            prompt: "Which daily response best aligns with \(primaryVerse)?",
            correct: "Pray, test, obey",
            distractors: [
                "Pray, rush, react",
                "Post, discuss, delay",
                "Feel, choose, defend"
            ],
            explanation: "Biblical discernment is prayerful, tested by Scripture, and followed by obedient action."
        )

        let questionThree = makeChallengeQuestion(
            idSuffix: "challenge-pattern",
            prompt: "Which pattern builds biblical wisdom over time?",
            correct: "Scripture, prayer, action",
            distractors: [
                "Scripture, debate, delay",
                "Opinion, prayer, action",
                "Scripture, prayer, image"
            ],
            explanation: "Growth comes from repeated Scripture-shaped practice, not occasional inspiration."
        )

        return [questionOne, questionTwo, questionThree]
    }

    private func makeChallengeQuestion(
        idSuffix: String,
        prompt: String,
        correct: String,
        distractors: [String],
        explanation: String
    ) -> WisdomQuestion {
        let baseQuestion = WisdomQuestion(
            id: "\(id)-\(idSuffix)",
            prompt: prompt,
            options: [correct] + Array(distractors.prefix(3)),
            correctIndex: 0,
            explanation: explanation
        )
        return baseQuestion.deterministicallyShuffled(seed: "\(id)-\(idSuffix)-options")
    }

    private func shortPhrase(from text: String) -> String {
        let stopWords: Set<String> = [
            "the", "and", "for", "with", "that", "this", "from", "into", "through",
            "over", "under", "your", "you", "what", "when", "where", "which",
            "wisdom", "chapter", "lesson", "proverbs", "godly", "daily"
        ]

        let words = text
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9 ]", with: " ", options: .regularExpression)
            .split(separator: " ")
            .map(String.init)
            .filter { !$0.isEmpty && !stopWords.contains($0) }

        let phrase = words.prefix(2).map { $0.capitalized }.joined(separator: " ")
        return phrase.isEmpty ? "Faithful" : phrase
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }
}

private extension WisdomQuestion {
    func deterministicallyShuffled(seed: String) -> WisdomQuestion {
        let indexed = options.enumerated().map { (originalIndex: $0.offset, text: $0.element) }
        let reordered = indexed.sorted { lhs, rhs in
            stableHash64("\(seed)-\(id)-\(lhs.originalIndex)-\(lhs.text)") <
            stableHash64("\(seed)-\(id)-\(rhs.originalIndex)-\(rhs.text)")
        }
        let reorderedOptions = reordered.map(\.text)
        let updatedCorrectIndex = reordered.firstIndex(where: { $0.originalIndex == correctIndex }) ?? correctIndex

        return WisdomQuestion(
            id: id,
            prompt: prompt,
            options: reorderedOptions,
            correctIndex: updatedCorrectIndex,
            explanation: explanation
        )
    }
}

private func stableHash64(_ value: String) -> UInt64 {
    var hash: UInt64 = 1469598103934665603
    for byte in value.utf8 {
        hash ^= UInt64(byte)
        hash &*= 1099511628211
    }
    return hash
}
