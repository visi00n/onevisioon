import Foundation

enum SpiritualGiftKind: String, CaseIterable, Codable, Hashable, Identifiable {
    case encouragement
    case service
    case teaching
    case mercy
    case leadership
    case creativity

    var id: String { rawValue }

    var title: String {
        switch self {
        case .encouragement: return "Encouragement"
        case .service: return "Service"
        case .teaching: return "Teaching"
        case .mercy: return "Mercy"
        case .leadership: return "Leadership"
        case .creativity: return "Creativity"
        }
    }

    var shortSummary: String {
        switch self {
        case .encouragement:
            return "You help people keep going with hope, truth, and steady words."
        case .service:
            return "You notice what needs to be done and move toward practical help."
        case .teaching:
            return "You care about helping people understand truth clearly and live it out."
        case .mercy:
            return "You move toward pain with compassion, patience, and care."
        case .leadership:
            return "You naturally create order, direction, and movement when others are drifting."
        case .creativity:
            return "You turn truth into something visible, memorable, and meaningful."
        }
    }

    var growthLine: String {
        switch self {
        case .encouragement:
            return "Train this gift by speaking life on purpose, not only when it feels easy."
        case .service:
            return "Train this gift by serving faithfully without becoming invisible or resentful."
        case .teaching:
            return "Train this gift by making Scripture clearer, simpler, and more obedient."
        case .mercy:
            return "Train this gift by staying tender without carrying what only God can carry."
        case .leadership:
            return "Train this gift by taking responsibility with humility, peace, and courage."
        case .creativity:
            return "Train this gift by making truth visible with discipline instead of waiting for inspiration."
        }
    }

    var caution: String {
        switch self {
        case .encouragement:
            return "Do not drift into vague comfort. Encourage with truth, not only warmth."
        case .service:
            return "Do not serve so quietly that you burn out and nobody knows you are drowning."
        case .teaching:
            return "Do not love being right more than helping people actually understand and obey."
        case .mercy:
            return "Do not confuse compassion with carrying every burden by yourself."
        case .leadership:
            return "Do not let urgency turn into control or pride."
        case .creativity:
            return "Do not let perfectionism keep the gift hidden when it could already bless someone."
        }
    }

    var symbol: String {
        switch self {
        case .encouragement: return "message.badge.waveform"
        case .service: return "hands.sparkles"
        case .teaching: return "book.pages"
        case .mercy: return "heart.text.square"
        case .leadership: return "flag.2.crossed"
        case .creativity: return "paintpalette"
        }
    }

    var anchorReference: String {
        switch self {
        case .encouragement: return "1 Thessalonians 5:11"
        case .service: return "1 Peter 4:10"
        case .teaching: return "Romans 12:7"
        case .mercy: return "Romans 12:8"
        case .leadership: return "Romans 12:8"
        case .creativity: return "Exodus 31:3-5"
        }
    }

    var dailyPrayer: String {
        switch self {
        case .encouragement:
            return "Lord, make my words life-giving, truthful, and full of courage for the people around me."
        case .service:
            return "Jesus, help me notice real needs and serve with joy, humility, and strength."
        case .teaching:
            return "God, help me understand Your Word clearly and explain it in a way that leads to obedience."
        case .mercy:
            return "Father, keep my heart soft, wise, and steady so I can care for people without losing peace."
        case .leadership:
            return "Lord, help me lead with humility, clarity, and a heart that serves instead of controls."
        case .creativity:
            return "God, train my hands and mind to make things that carry truth, beauty, and light."
        }
    }

    var dailyActionIdeas: [String] {
        switch self {
        case .encouragement:
            return [
                "Send one honest message that strengthens someone instead of only checking a box.",
                "Speak one specific truth over somebody who feels tired or stuck.",
                "Follow up with one person you know is quietly carrying a lot.",
                "Turn one verse into a short encouragement you can share today."
            ]
        case .service:
            return [
                "Do one needed task before anybody asks you.",
                "Help someone with something practical that makes their day lighter.",
                "Offer steady help in a place you usually only notice.",
                "Choose one hidden act of faithfulness and do it with joy."
            ]
        case .teaching:
            return [
                "Write one clear takeaway from Scripture in simple words.",
                "Explain one verse to a friend or in your notes as if you were guiding a beginner.",
                "Turn today’s reading into one simple truth you can live by.",
                "Read a chapter and name the main point in one sentence."
            ]
        case .mercy:
            return [
                "Slow down long enough to really listen to one person instead of rushing past them.",
                "Pray with compassion for someone specific and then check in on them.",
                "Sit with somebody’s pain without trying to fix everything too fast.",
                "Choose tenderness in one conversation where you could have become cold."
            ]
        case .leadership:
            return [
                "Take ownership of one good next step instead of waiting for someone else.",
                "Bring order to one messy area that affects other people.",
                "Start one conversation that gives direction and peace.",
                "Use your initiative today to serve people, not impress them."
            ]
        case .creativity:
            return [
                "Make one small piece that points people back to truth.",
                "Turn a verse into something visual, written, or spoken today.",
                "Finish one draft instead of overthinking it.",
                "Use your creative skill to make something clearer, warmer, or more beautiful for someone else."
            ]
        }
    }

    var reflectionPrompts: [String] {
        switch self {
        case .encouragement:
            return [
                "Who needed strength from me today, and did I actually give it?",
                "Did my words carry truth, or only nice language?",
                "Where can I be more intentional instead of passive with encouragement?"
            ]
        case .service:
            return [
                "What need did I notice today, and how did I respond?",
                "Did I serve with peace, or did I serve with hidden frustration?",
                "Where is God asking me to stay faithful in small things?"
            ]
        case .teaching:
            return [
                "What truth became clearer to me today?",
                "Did I explain truth in a way people can actually carry?",
                "Where do I need more humility as I grow in clarity?"
            ]
        case .mercy:
            return [
                "Whose pain did I really make room for today?",
                "Did I keep compassion joined to truth and prayer?",
                "Where do I need stronger boundaries so mercy stays healthy?"
            ]
        case .leadership:
            return [
                "What responsibility did I take today that helped other people?",
                "Did I lead with peace, or did I push too hard?",
                "Where can I become more servant-hearted as I take initiative?"
            ]
        case .creativity:
            return [
                "What did I make today that carried truth or beauty?",
                "Did I hide behind perfectionism, or did I use the gift?",
                "How can my creativity point more to Christ and less to myself?"
            ]
        }
    }

    var habits: [GiftHabitBlueprint] {
        switch self {
        case .encouragement:
            return [
                GiftHabitBlueprint(id: "encouragement-pray", title: "Pray before you speak", detail: "Ask God to make your words timely and true.", reference: "Proverbs 16:24"),
                GiftHabitBlueprint(id: "encouragement-message", title: "Send one direct encouragement", detail: "Text, call, or voice note one person on purpose.", reference: "1 Thessalonians 5:11"),
                GiftHabitBlueprint(id: "encouragement-scripture", title: "Use one verse in your encouragement", detail: "Let your comfort stay rooted in truth.", reference: "Colossians 4:6"),
                GiftHabitBlueprint(id: "encouragement-followup", title: "Follow up instead of forgetting", detail: "Come back to the person after the first conversation.", reference: "Hebrews 10:24")
            ]
        case .service:
            return [
                GiftHabitBlueprint(id: "service-notice", title: "Notice one real need", detail: "Look for what would actually help today.", reference: "Philippians 2:4"),
                GiftHabitBlueprint(id: "service-act", title: "Do one practical act", detail: "Take action before it becomes a big plan.", reference: "Galatians 5:13"),
                GiftHabitBlueprint(id: "service-quiet", title: "Serve without needing praise", detail: "Let hidden faithfulness still count as ministry.", reference: "Matthew 6:4"),
                GiftHabitBlueprint(id: "service-boundary", title: "Serve with peace", detail: "Give help without ignoring your limits.", reference: "1 Peter 4:11")
            ]
        case .teaching:
            return [
                GiftHabitBlueprint(id: "teaching-read", title: "Read one chapter slowly", detail: "Look for the main point before the details.", reference: "2 Timothy 2:15"),
                GiftHabitBlueprint(id: "teaching-summarize", title: "Write the truth simply", detail: "Put one biblical idea into everyday words.", reference: "Nehemiah 8:8"),
                GiftHabitBlueprint(id: "teaching-share", title: "Explain one insight", detail: "Share truth clearly with one person or in notes.", reference: "Romans 12:7"),
                GiftHabitBlueprint(id: "teaching-obey", title: "Turn truth into action", detail: "Do not stop at understanding alone.", reference: "James 1:22")
            ]
        case .mercy:
            return [
                GiftHabitBlueprint(id: "mercy-listen", title: "Listen without rushing", detail: "Make room for the person, not only the problem.", reference: "James 1:19"),
                GiftHabitBlueprint(id: "mercy-pray", title: "Pray with compassion", detail: "Carry people to God, not only in your head.", reference: "Colossians 3:12"),
                GiftHabitBlueprint(id: "mercy-presence", title: "Show up gently", detail: "Let your presence feel safe and steady.", reference: "Romans 12:15"),
                GiftHabitBlueprint(id: "mercy-boundary", title: "Keep healthy limits", detail: "Let God stay God while you stay faithful.", reference: "Galatians 6:2")
            ]
        case .leadership:
            return [
                GiftHabitBlueprint(id: "leadership-pray", title: "Pray before directing", detail: "Lead from dependence, not pressure.", reference: "James 1:5"),
                GiftHabitBlueprint(id: "leadership-clarify", title: "Name the next step clearly", detail: "Give people direction that lowers confusion.", reference: "Habakkuk 2:2"),
                GiftHabitBlueprint(id: "leadership-serve", title: "Use initiative to serve", detail: "Let leadership help people, not control them.", reference: "Mark 10:45"),
                GiftHabitBlueprint(id: "leadership-review", title: "Review your motive", detail: "Check for pride, hurry, or self-importance.", reference: "Romans 12:8")
            ]
        case .creativity:
            return [
                GiftHabitBlueprint(id: "creativity-scripture", title: "Start from Scripture", detail: "Anchor the work in truth before style.", reference: "Exodus 31:3-5"),
                GiftHabitBlueprint(id: "creativity-make", title: "Make one real thing", detail: "Choose progress over delay.", reference: "Ecclesiastes 9:10"),
                GiftHabitBlueprint(id: "creativity-refine", title: "Sharpen the work with care", detail: "Practice excellence without obsession.", reference: "Colossians 3:23"),
                GiftHabitBlueprint(id: "creativity-share", title: "Let someone see the light", detail: "Use the work to bless people, not only to store it.", reference: "Matthew 5:16")
            ]
        }
    }
}

enum GiftFormationNeed: String, CaseIterable, Codable, Hashable, Identifiable {
    case consistency
    case courage
    case clarity
    case compassion
    case discipline
    case humility
    case boundaries
    case followThrough

    var id: String { rawValue }

    var title: String {
        switch self {
        case .consistency: return "Consistency"
        case .courage: return "Courage"
        case .clarity: return "Clarity"
        case .compassion: return "Compassion"
        case .discipline: return "Discipline"
        case .humility: return "Humility"
        case .boundaries: return "Boundaries"
        case .followThrough: return "Follow-through"
        }
    }

    var shortSummary: String {
        switch self {
        case .consistency:
            return "You will grow most when small daily steps become steady."
        case .courage:
            return "You will grow most when you act even when you feel exposed."
        case .clarity:
            return "You will grow most when you slow down and make truth plain."
        case .compassion:
            return "You will grow most when you stay tender toward real people."
        case .discipline:
            return "You will grow most when structure replaces waiting for the mood to be right."
        case .humility:
            return "You will grow most when your gift stays submitted instead of self-driven."
        case .boundaries:
            return "You will grow most when peace and wisdom protect the gift from burnout."
        case .followThrough:
            return "You will grow most when good starts become completed acts of faithfulness."
        }
    }

    var coachPrompt: String {
        switch self {
        case .consistency:
            return "Repeat one faithful step today even if it feels small."
        case .courage:
            return "Move toward the hard thing instead of waiting until fear is gone."
        case .clarity:
            return "Name the main point simply before you try to do too much."
        case .compassion:
            return "Notice the person in front of you before the task in front of you."
        case .discipline:
            return "Choose structure over mood and follow the plan you already know is good."
        case .humility:
            return "Use the gift to serve, not to prove anything."
        case .boundaries:
            return "Stay open-hearted without carrying what belongs to God."
        case .followThrough:
            return "Finish the next faithful step instead of stopping at intention."
        }
    }
}

struct GiftHabitBlueprint: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let detail: String
    let reference: String
}

struct GiftDiscoveryOption: Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String
    let scores: [SpiritualGiftKind: Int]
    let needScores: [GiftFormationNeed: Int]
}

struct GiftDiscoveryQuestion: Identifiable, Hashable {
    let id: String
    let prompt: String
    let detail: String
    let options: [GiftDiscoveryOption]
}

struct GiftDiscoveryProfile: Codable, Hashable {
    let completedAt: Date
    let answers: [String: String]
    let orderedGiftIDs: [String]
    let scoreMap: [String: Int]
    let needScoreMap: [String: Int]

    private enum CodingKeys: String, CodingKey {
        case completedAt
        case answers
        case orderedGiftIDs
        case scoreMap
        case needScoreMap
    }

    init(
        completedAt: Date,
        answers: [String: String],
        orderedGiftIDs: [String],
        scoreMap: [String: Int],
        needScoreMap: [String: Int]
    ) {
        self.completedAt = completedAt
        self.answers = answers
        self.orderedGiftIDs = orderedGiftIDs
        self.scoreMap = scoreMap
        self.needScoreMap = needScoreMap
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        completedAt = try container.decode(Date.self, forKey: .completedAt)
        answers = try container.decode([String: String].self, forKey: .answers)
        orderedGiftIDs = try container.decode([String].self, forKey: .orderedGiftIDs)
        scoreMap = try container.decode([String: Int].self, forKey: .scoreMap)
        needScoreMap = try container.decodeIfPresent([String: Int].self, forKey: .needScoreMap) ?? [:]
    }

    var orderedGifts: [SpiritualGiftKind] {
        orderedGiftIDs.compactMap(SpiritualGiftKind.init(rawValue:))
    }

    var primaryGift: SpiritualGiftKind? {
        orderedGifts.first
    }

    var secondaryGift: SpiritualGiftKind? {
        orderedGifts.dropFirst().first
    }

    var orderedNeeds: [GiftFormationNeed] {
        let ranked = GiftFormationNeed.allCases.filter { needScoreMap[$0.rawValue, default: 0] > 0 }
        return ranked.sorted { left, right in
            let leftScore = needScoreMap[left.rawValue] ?? 0
            let rightScore = needScoreMap[right.rawValue] ?? 0
            if leftScore != rightScore {
                return leftScore > rightScore
            }
            return left.title < right.title
        }
    }

    var primaryNeed: GiftFormationNeed? {
        orderedNeeds.first
    }

    var secondaryNeed: GiftFormationNeed? {
        orderedNeeds.dropFirst().first
    }

    var confidenceScore: Int {
        guard let primaryGift, let secondaryGift else { return 50 }
        let primary = score(for: primaryGift)
        let secondary = score(for: secondaryGift)
        let difference = max(0, primary - secondary)
        return min(95, max(52, 55 + (difference * 5)))
    }

    var confidenceLabel: String {
        switch confidenceScore {
        case 80...:
            return "Strong fit"
        case 66...:
            return "Clear fit"
        default:
            return "Blended fit"
        }
    }

    var resultHeadline: String {
        guard let primaryGift else {
            return "A steady training path"
        }

        if let secondaryGift {
            return "\(primaryGift.title) with \(secondaryGift.title.lowercased()) support"
        }

        return primaryGift.title
    }

    var resultSummary: String {
        guard let primaryGift else {
            return "One Visioon will guide you through steady daily practice."
        }

        if let primaryNeed {
            return "\(primaryGift.shortSummary) Your biggest growth edge right now looks like \(primaryNeed.title.lowercased())."
        }

        return primaryGift.shortSummary
    }

    var trainingSummary: String {
        guard let primaryGift else {
            return "The app will help you build a simple daily path."
        }

        guard let primaryNeed else {
            return "The app will help you use \(primaryGift.title.lowercased()) with daily Scripture, habits, and reflection."
        }

        return "The app will help you use \(primaryGift.title.lowercased()) with more \(primaryNeed.title.lowercased()), steadiness, and real-life obedience."
    }

    func score(for gift: SpiritualGiftKind) -> Int {
        scoreMap[gift.rawValue] ?? 0
    }

    func needScore(for need: GiftFormationNeed) -> Int {
        needScoreMap[need.rawValue] ?? 0
    }
}

struct GiftTrainingCheckIn: Identifiable, Hashable, Codable {
    let id: UUID
    let dayKey: String
    var completedHabitIDs: [String]
    var reflection: String
    var clockedInAt: Date?
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        dayKey: String,
        completedHabitIDs: [String] = [],
        reflection: String = "",
        clockedInAt: Date? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.dayKey = dayKey
        self.completedHabitIDs = completedHabitIDs
        self.reflection = reflection
        self.clockedInAt = clockedInAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var completedCount: Int {
        Set(completedHabitIDs).count
    }

    var isClockedIn: Bool {
        clockedInAt != nil
    }

    var hasMeaningfulProgress: Bool {
        isClockedIn || completedCount > 0 || !reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct GiftDailyFocus: Hashable {
    let gift: SpiritualGiftKind
    let title: String
    let detail: String
    let whyItMatters: String
    let actionStep: String
    let reflectionPrompt: String
    let habitIDs: [String]
    let reference: String
    let dayNumber: Int
    let totalSteps: Int
}

struct GlorifyReminderSettings: Codable, Hashable {
    let isEnabled: Bool
    let hour: Int
    let minute: Int

    static let dailyMorning = GlorifyReminderSettings(isEnabled: true, hour: 7, minute: 0)
}

struct GlorifyMorningQuote: Identifiable, Hashable {
    let id: String
    let text: String
    let source: String
    let reference: String
}

enum GiftDiscoveryCatalog {
    private struct GiftFocusDraft {
        let gift: SpiritualGiftKind
        let title: String
        let detail: String
        let whyItMatters: String
        let actionStep: String
        let reflectionPrompt: String
        let habitIDs: [String]
        let reference: String
    }

    static let morningQuotes: [GlorifyMorningQuote] = [
        GlorifyMorningQuote(id: "mq-1", text: "God does not need a perfect morning from you. He wants your first yes.", source: "One Visioon", reference: "Psalm 5:3"),
        GlorifyMorningQuote(id: "mq-2", text: "Start small, stay faithful, and let God shape the rest of the day.", source: "One Visioon", reference: "Luke 16:10"),
        GlorifyMorningQuote(id: "mq-3", text: "Peace grows when the first thing you do is turn toward God.", source: "One Visioon", reference: "Isaiah 26:3"),
        GlorifyMorningQuote(id: "mq-4", text: "You do not need more pressure today. You need a clear next step with God.", source: "One Visioon", reference: "Proverbs 3:5-6"),
        GlorifyMorningQuote(id: "mq-5", text: "The strongest habits are built by ordinary faithfulness, not dramatic moments.", source: "One Visioon", reference: "Galatians 6:9"),
        GlorifyMorningQuote(id: "mq-6", text: "If you feel weak this morning, start there. God works with honest people.", source: "One Visioon", reference: "2 Corinthians 12:9"),
        GlorifyMorningQuote(id: "mq-7", text: "Truth is clearer when you slow down enough to receive it.", source: "One Visioon", reference: "James 1:5"),
        GlorifyMorningQuote(id: "mq-8", text: "Your gift grows when you use it for people, not just think about it.", source: "One Visioon", reference: "1 Peter 4:10"),
        GlorifyMorningQuote(id: "mq-9", text: "Do not wait to feel inspired before you obey.", source: "One Visioon", reference: "James 1:22"),
        GlorifyMorningQuote(id: "mq-10", text: "God can do a lot with one disciplined yes today.", source: "One Visioon", reference: "Colossians 3:23"),
        GlorifyMorningQuote(id: "mq-11", text: "You are not behind if you return to God this morning. You are alive and still being called.", source: "One Visioon", reference: "Lamentations 3:22-23"),
        GlorifyMorningQuote(id: "mq-12", text: "When your mind feels scattered, come back to what is true and start there.", source: "One Visioon", reference: "Philippians 4:8"),
        GlorifyMorningQuote(id: "mq-13", text: "A quiet act of faithfulness still counts in the Kingdom of God.", source: "One Visioon", reference: "Matthew 6:4"),
        GlorifyMorningQuote(id: "mq-14", text: "The goal today is not to impress God. It is to walk with Him.", source: "One Visioon", reference: "Micah 6:8"),
        GlorifyMorningQuote(id: "mq-15", text: "Let Scripture shape your first thoughts before the world shapes the rest.", source: "One Visioon", reference: "Psalm 1:2"),
        GlorifyMorningQuote(id: "mq-16", text: "Courage often looks like one simple act of obedience.", source: "One Visioon", reference: "Joshua 1:9"),
        GlorifyMorningQuote(id: "mq-17", text: "Your calling grows clearer when you keep showing up.", source: "One Visioon", reference: "Romans 12:6"),
        GlorifyMorningQuote(id: "mq-18", text: "Stay near to God first. The rest of the day makes more sense from there.", source: "One Visioon", reference: "James 4:8")
    ]

    private static func option(
        _ id: String,
        title: String,
        detail: String,
        gift: SpiritualGiftKind,
        secondary: SpiritualGiftKind? = nil,
        secondaryWeight: Int = 1,
        needs: [GiftFormationNeed: Int] = [:]
    ) -> GiftDiscoveryOption {
        var scores: [SpiritualGiftKind: Int] = [gift: 3]
        if let secondary {
            scores[secondary] = secondaryWeight
        }

        return GiftDiscoveryOption(
            id: id,
            title: title,
            detail: detail,
            scores: scores,
            needScores: needs
        )
    }

    static let questions: [GiftDiscoveryQuestion] = [
        GiftDiscoveryQuestion(
            id: "q1",
            prompt: "When someone near you is discouraged, what do you usually do first?",
            detail: "Pick what feels most natural, not what sounds best.",
            options: [
                option("q1-a", title: "I speak hope and truth", detail: "I try to help them stand back up.", gift: .encouragement, secondary: .mercy, needs: [.courage: 2, .consistency: 1]),
                option("q1-b", title: "I help with something real", detail: "I want to make the load lighter.", gift: .service, secondary: .mercy, needs: [.followThrough: 2]),
                option("q1-c", title: "I bring Scripture or clarity", detail: "I want them grounded, not only comforted.", gift: .teaching, secondary: .encouragement, needs: [.clarity: 2]),
                option("q1-d", title: "I sit with them and listen", detail: "I want them to feel seen and safe.", gift: .mercy, secondary: .encouragement, needs: [.compassion: 2, .boundaries: 1]),
                option("q1-e", title: "I think about a plan", detail: "I start figuring out what would move help forward.", gift: .leadership, secondary: .service, needs: [.humility: 1, .followThrough: 2]),
                option("q1-f", title: "I make something meaningful", detail: "I want to encourage them through something creative.", gift: .creativity, secondary: .encouragement, needs: [.discipline: 2]),
                option("q1-g", title: "I pray first, then respond", detail: "I pause, ask God for wisdom, then choose how to help.", gift: .mercy, secondary: .teaching, needs: [.clarity: 1, .compassion: 1])
            ]
        ),
        GiftDiscoveryQuestion(
            id: "q2",
            prompt: "What kind of responsibility gives you the most energy?",
            detail: "Think about church, work, family, or community.",
            options: [
                option("q2-a", title: "Strengthening people with words", detail: "I like helping people keep going.", gift: .encouragement, needs: [.courage: 1, .consistency: 1]),
                option("q2-b", title: "Helping behind the scenes", detail: "I like getting useful things done.", gift: .service, needs: [.followThrough: 2]),
                option("q2-c", title: "Explaining truth clearly", detail: "I like helping people understand.", gift: .teaching, needs: [.clarity: 2]),
                option("q2-d", title: "Caring for hurting people", detail: "I like making people feel held with grace.", gift: .mercy, needs: [.compassion: 2, .boundaries: 1]),
                option("q2-e", title: "Organizing people toward a goal", detail: "I like bringing direction and movement.", gift: .leadership, needs: [.humility: 1, .followThrough: 1]),
                option("q2-f", title: "Building something beautiful or useful", detail: "I like shaping ideas into something people can see.", gift: .creativity, needs: [.discipline: 2]),
                option("q2-g", title: "Walking deeply with one person", detail: "I like mentoring one person steadily over time.", gift: .encouragement, secondary: .teaching, needs: [.consistency: 2, .clarity: 1])
            ]
        ),
        GiftDiscoveryQuestion(
            id: "q3",
            prompt: "What do people usually come to you for?",
            detail: "Think about what happens naturally in real life.",
            options: [
                option("q3-a", title: "A word that lifts them", detail: "People come when they need hope.", gift: .encouragement, needs: [.courage: 1]),
                option("q3-b", title: "Reliable help", detail: "People trust me to show up and carry part of the load.", gift: .service, needs: [.followThrough: 2]),
                option("q3-c", title: "Explanation or clarity", detail: "People come when they need to understand something.", gift: .teaching, needs: [.clarity: 2]),
                option("q3-d", title: "Compassion", detail: "People come when they need gentleness and care.", gift: .mercy, needs: [.compassion: 2]),
                option("q3-e", title: "Direction", detail: "People come when something needs leading or organizing.", gift: .leadership, needs: [.humility: 1, .clarity: 1]),
                option("q3-f", title: "A creative eye", detail: "People come when something needs to be expressed or shaped well.", gift: .creativity, needs: [.discipline: 1, .clarity: 1]),
                option("q3-g", title: "Prayer and spiritual discernment", detail: "People come when they need prayer, peace, and direction.", gift: .mercy, secondary: .leadership, needs: [.compassion: 1, .humility: 1])
            ]
        ),
        GiftDiscoveryQuestion(
            id: "q4",
            prompt: "What is hardest for you to ignore?",
            detail: "This often reveals what God has wired you to notice.",
            options: [
                option("q4-a", title: "People losing heart", detail: "I notice when someone is about to give up.", gift: .encouragement, needs: [.consistency: 1]),
                option("q4-b", title: "Needs going unmet", detail: "I notice what is not being handled.", gift: .service, needs: [.followThrough: 1]),
                option("q4-c", title: "Truth getting twisted", detail: "I notice confusion and weak understanding.", gift: .teaching, needs: [.clarity: 2]),
                option("q4-d", title: "Pain being overlooked", detail: "I notice when hurt is being ignored.", gift: .mercy, needs: [.compassion: 2, .boundaries: 1]),
                option("q4-e", title: "Disorder and drift", detail: "I notice when nobody is taking responsibility.", gift: .leadership, needs: [.humility: 1, .followThrough: 1]),
                option("q4-f", title: "Truth feeling flat or forgettable", detail: "I notice when something could be carried more clearly or beautifully.", gift: .creativity, secondary: .teaching, needs: [.discipline: 1, .clarity: 1]),
                option("q4-g", title: "People drifting from God quietly", detail: "I notice when someone looks fine but is spiritually fading.", gift: .encouragement, secondary: .mercy, needs: [.consistency: 1, .compassion: 1])
            ]
        ),
        GiftDiscoveryQuestion(
            id: "q5",
            prompt: "When you read Scripture, what usually happens first?",
            detail: "Think about your normal first response.",
            options: [
                option("q5-a", title: "I think of who needs it", detail: "My mind goes to people who need hope.", gift: .encouragement, needs: [.courage: 1]),
                option("q5-b", title: "I think of what I can do", detail: "I want to turn it into action quickly.", gift: .service, needs: [.followThrough: 1]),
                option("q5-c", title: "I want to explain it clearly", detail: "I start breaking it down.", gift: .teaching, needs: [.clarity: 2]),
                option("q5-d", title: "I feel the comfort of God", detail: "I enter it with tenderness and care.", gift: .mercy, needs: [.compassion: 2]),
                option("q5-e", title: "I see a path forward", detail: "I start noticing direction and next steps.", gift: .leadership, needs: [.clarity: 1, .discipline: 1]),
                option("q5-f", title: "I want to turn it into something", detail: "I imagine a design, lyric, image, or piece of work.", gift: .creativity, needs: [.discipline: 2]),
                option("q5-g", title: "I pause and pray before deciding", detail: "I wait on God first, then I decide what to do with it.", gift: .mercy, secondary: .teaching, needs: [.clarity: 1, .humility: 1])
            ]
        ),
        GiftDiscoveryQuestion(
            id: "q6",
            prompt: "Which sentence sounds most like you on a strong day?",
            detail: "Pick the one that feels most natural, not just admirable.",
            options: [
                option("q6-a", title: "I know how to strengthen people", detail: "I can help people keep going.", gift: .encouragement, needs: [.courage: 1]),
                option("q6-b", title: "I quietly make things happen", detail: "I get useful things done without fuss.", gift: .service, needs: [.followThrough: 1]),
                option("q6-c", title: "I can make truth simple", detail: "I help people see clearly.", gift: .teaching, needs: [.clarity: 2]),
                option("q6-d", title: "I feel what people carry", detail: "I move toward people with care.", gift: .mercy, needs: [.compassion: 2]),
                option("q6-e", title: "I can bring order and movement", detail: "I help people stop drifting.", gift: .leadership, needs: [.humility: 1, .clarity: 1]),
                option("q6-f", title: "I can make truth visible", detail: "I turn ideas into something memorable.", gift: .creativity, needs: [.discipline: 1, .clarity: 1]),
                option("q6-g", title: "I adapt to what each person needs", detail: "I can shift roles quickly depending on what helps most.", gift: .service, secondary: .leadership, needs: [.clarity: 1, .followThrough: 1])
            ]
        ),
        GiftDiscoveryQuestion(
            id: "q7",
            prompt: "When a group feels stuck, what do you naturally start doing?",
            detail: "Think about your first move in a room that needs help.",
            options: [
                option("q7-a", title: "I try to lift the mood", detail: "I want people to have heart again.", gift: .encouragement, needs: [.courage: 1]),
                option("q7-b", title: "I take one useful task", detail: "I start by helping in a practical way.", gift: .service, needs: [.followThrough: 1]),
                option("q7-c", title: "I explain the key issue", detail: "I want everyone to understand what matters most.", gift: .teaching, needs: [.clarity: 2]),
                option("q7-d", title: "I notice who is quietly struggling", detail: "I watch the people, not only the plan.", gift: .mercy, needs: [.compassion: 2]),
                option("q7-e", title: "I bring direction", detail: "I start organizing the next steps.", gift: .leadership, secondary: .service, needs: [.humility: 1, .followThrough: 1]),
                option("q7-f", title: "I think of a better way to communicate it", detail: "I want the message or moment to land more deeply.", gift: .creativity, secondary: .teaching, needs: [.discipline: 1, .clarity: 1])
            ]
        ),
        GiftDiscoveryQuestion(
            id: "q8",
            prompt: "What kind of fruit do you most want your life to leave in other people?",
            detail: "Choose the impact that matters most to you.",
            options: [
                option("q8-a", title: "People feel stronger", detail: "I want people to leave with courage.", gift: .encouragement, needs: [.consistency: 1]),
                option("q8-b", title: "People feel helped", detail: "I want people to experience real care.", gift: .service, needs: [.followThrough: 1]),
                option("q8-c", title: "People understand God better", detail: "I want truth to become clear.", gift: .teaching, needs: [.clarity: 2]),
                option("q8-d", title: "People feel seen and loved", detail: "I want the hurting to experience mercy.", gift: .mercy, needs: [.compassion: 2]),
                option("q8-e", title: "People move with purpose", detail: "I want direction and growth to become real.", gift: .leadership, needs: [.humility: 1, .followThrough: 1]),
                option("q8-f", title: "People remember truth more deeply", detail: "I want truth to become visible and memorable.", gift: .creativity, secondary: .teaching, needs: [.clarity: 1, .discipline: 1])
            ]
        ),
        GiftDiscoveryQuestion(
            id: "q9",
            prompt: "What do you avoid the least, even when you are tired?",
            detail: "This often reveals what is deeply built into you.",
            options: [
                option("q9-a", title: "Lifting someone’s heart", detail: "I still want people to leave stronger.", gift: .encouragement, needs: [.consistency: 2]),
                option("q9-b", title: "Helping where needed", detail: "I still want to be useful.", gift: .service, needs: [.followThrough: 2]),
                option("q9-c", title: "Explaining what is true", detail: "I still want to bring clarity.", gift: .teaching, needs: [.clarity: 2]),
                option("q9-d", title: "Caring for the hurting", detail: "I still feel moved by pain.", gift: .mercy, needs: [.compassion: 2, .boundaries: 1]),
                option("q9-e", title: "Taking responsibility", detail: "I still feel the need to bring direction.", gift: .leadership, needs: [.humility: 1, .followThrough: 2]),
                option("q9-f", title: "Making something meaningful", detail: "I still want to create something that matters.", gift: .creativity, needs: [.discipline: 2])
            ]
        ),
        GiftDiscoveryQuestion(
            id: "q10",
            prompt: "If you had one free evening to bless someone, what would you most likely do?",
            detail: "Choose the investment that feels most like you.",
            options: [
                option("q10-a", title: "Call or message someone with strength", detail: "I would help them not feel alone.", gift: .encouragement, needs: [.courage: 1, .consistency: 1]),
                option("q10-b", title: "Help with a real need", detail: "Meal, setup, moving, errands, support.", gift: .service, needs: [.followThrough: 2]),
                option("q10-c", title: "Prepare a study or simple teaching", detail: "I would help someone understand truth.", gift: .teaching, needs: [.clarity: 2]),
                option("q10-d", title: "Sit with someone who is hurting", detail: "I would make room for their pain.", gift: .mercy, needs: [.compassion: 2, .boundaries: 1]),
                option("q10-e", title: "Plan something that helps a group", detail: "I would create structure that moves people forward.", gift: .leadership, needs: [.humility: 1, .followThrough: 1]),
                option("q10-f", title: "Make something for someone", detail: "I would write, design, film, or build something meaningful.", gift: .creativity, needs: [.discipline: 2])
            ]
        ),
        GiftDiscoveryQuestion(
            id: "q11",
            prompt: "Where do you most need growth right now?",
            detail: "Be honest. This helps shape the training path after the quiz.",
            options: [
                option("q11-a", title: "I need to show up more steadily", detail: "I start well but do not always stay steady.", gift: .encouragement, secondary: .service, needs: [.consistency: 3]),
                option("q11-b", title: "I need to follow through better", detail: "I mean well but I do not always finish.", gift: .service, secondary: .leadership, needs: [.followThrough: 3]),
                option("q11-c", title: "I need clearer understanding", detail: "I want to handle truth more carefully.", gift: .teaching, secondary: .creativity, needs: [.clarity: 3]),
                option("q11-d", title: "I need a softer and wiser heart", detail: "I want to care well without becoming overwhelmed.", gift: .mercy, secondary: .encouragement, needs: [.compassion: 2, .boundaries: 2]),
                option("q11-e", title: "I need stronger courage and humility", detail: "I want to step up without pushing too hard.", gift: .leadership, secondary: .service, needs: [.humility: 2, .courage: 2]),
                option("q11-f", title: "I need more discipline", detail: "I know there is something in me, but I hide or delay too much.", gift: .creativity, secondary: .teaching, needs: [.discipline: 3])
            ]
        ),
        GiftDiscoveryQuestion(
            id: "q12",
            prompt: "Which kind of work feels most alive to you?",
            detail: "It can be in ministry, your job, school, home, or community.",
            options: [
                option("q12-a", title: "Helping people leave stronger", detail: "I love when hope comes back into a person.", gift: .encouragement, needs: [.courage: 1]),
                option("q12-b", title: "Helping something run better", detail: "I love when people are genuinely served.", gift: .service, needs: [.followThrough: 1]),
                option("q12-c", title: "Helping people understand", detail: "I love when confusion turns into clarity.", gift: .teaching, needs: [.clarity: 2]),
                option("q12-d", title: "Helping people feel cared for", detail: "I love when someone feels safe, seen, and less alone.", gift: .mercy, needs: [.compassion: 2]),
                option("q12-e", title: "Helping a group move forward", detail: "I love when purpose replaces drift.", gift: .leadership, needs: [.humility: 1, .followThrough: 1]),
                option("q12-f", title: "Helping truth land deeply", detail: "I love when beauty or creativity helps people receive what matters.", gift: .creativity, secondary: .teaching, needs: [.discipline: 1, .clarity: 1])
            ]
        ),
        GiftDiscoveryQuestion(
            id: "q13",
            prompt: "What would people most likely thank you for after serving with you?",
            detail: "Pick the one that sounds most true over time.",
            options: [
                option("q13-a", title: "You strengthened me", detail: "I made them feel more hopeful and grounded.", gift: .encouragement, needs: [.consistency: 1]),
                option("q13-b", title: "You really helped me", detail: "I made life lighter in a practical way.", gift: .service, needs: [.followThrough: 1]),
                option("q13-c", title: "You made it make sense", detail: "I helped them understand truth or direction.", gift: .teaching, needs: [.clarity: 2]),
                option("q13-d", title: "You really cared", detail: "I made them feel safe and remembered.", gift: .mercy, needs: [.compassion: 2]),
                option("q13-e", title: "You brought direction", detail: "I helped people stop drifting and move.", gift: .leadership, needs: [.humility: 1, .followThrough: 1]),
                option("q13-f", title: "You brought the message to life", detail: "I helped truth feel visible, memorable, or beautiful.", gift: .creativity, secondary: .encouragement, needs: [.discipline: 1])
            ]
        ),
        GiftDiscoveryQuestion(
            id: "q14",
            prompt: "What do you most want God to sharpen in you next?",
            detail: "This gives your first weeks of guidance a clearer target.",
            options: [
                option("q14-a", title: "Words that strengthen", detail: "I want to speak courage more faithfully.", gift: .encouragement, needs: [.courage: 2, .consistency: 1]),
                option("q14-b", title: "Hands that serve", detail: "I want to help people in real ways with better follow-through.", gift: .service, needs: [.followThrough: 2]),
                option("q14-c", title: "Clarity with Scripture", detail: "I want stronger understanding and explanation.", gift: .teaching, needs: [.clarity: 3]),
                option("q14-d", title: "Tenderness with wisdom", detail: "I want compassion that stays healthy.", gift: .mercy, needs: [.compassion: 2, .boundaries: 2]),
                option("q14-e", title: "Courage to lead well", detail: "I want initiative shaped by humility and peace.", gift: .leadership, needs: [.humility: 2, .courage: 1]),
                option("q14-f", title: "Skill with purpose", detail: "I want to create faithfully instead of waiting for perfect conditions.", gift: .creativity, needs: [.discipline: 3])
            ]
        )
    ]

    static let maxAdaptiveFollowUps = 4

    private static let followUpQuestionsByGift: [SpiritualGiftKind: GiftDiscoveryQuestion] = [
        .encouragement: GiftDiscoveryQuestion(
            id: "fup-encouragement",
            prompt: "When you encourage someone, what kind of response feels most like you?",
            detail: "This follow-up helps us understand your encouragement style more accurately.",
            options: [
                option("fup-enc-a", title: "I speak direct truth with hope", detail: "I challenge and strengthen at the same time.", gift: .encouragement, secondary: .teaching, needs: [.courage: 2, .clarity: 1]),
                option("fup-enc-b", title: "I ask questions before I speak", detail: "I want to understand their heart first.", gift: .encouragement, secondary: .mercy, needs: [.compassion: 1, .clarity: 1]),
                option("fup-enc-c", title: "I follow up later so they do not feel forgotten", detail: "I check back in after the first conversation.", gift: .encouragement, secondary: .service, needs: [.consistency: 2]),
                option("fup-enc-d", title: "I pray with them right there", detail: "I want God's presence to lead the moment.", gift: .encouragement, secondary: .mercy, needs: [.courage: 1, .compassion: 1]),
                option("fup-enc-e", title: "I give one practical next step", detail: "I help them move forward, not just feel better.", gift: .leadership, secondary: .encouragement, needs: [.clarity: 1, .followThrough: 1]),
                option("fup-enc-f", title: "I write or create something to lift them", detail: "I use words, notes, or creative work to strengthen them.", gift: .creativity, secondary: .encouragement, needs: [.discipline: 1, .consistency: 1])
            ]
        ),
        .service: GiftDiscoveryQuestion(
            id: "fup-service",
            prompt: "When you serve, which role fits you best most of the time?",
            detail: "Pick the service pattern that feels most natural.",
            options: [
                option("fup-ser-a", title: "I take practical tasks and finish them", detail: "I quietly get things done.", gift: .service, needs: [.followThrough: 2]),
                option("fup-ser-b", title: "I care for people one-on-one", detail: "I serve by being personally present.", gift: .service, secondary: .mercy, needs: [.compassion: 1, .boundaries: 1]),
                option("fup-ser-c", title: "I build systems so people are served better", detail: "I improve structure, not only one task.", gift: .leadership, secondary: .service, needs: [.clarity: 1, .humility: 1]),
                option("fup-ser-d", title: "I step in quickly during pressure moments", detail: "I help most when things are urgent.", gift: .service, secondary: .leadership, needs: [.courage: 1, .followThrough: 1]),
                option("fup-ser-e", title: "I coordinate volunteers and teams", detail: "I like mobilizing people around a need.", gift: .leadership, secondary: .service, needs: [.humility: 1, .followThrough: 1]),
                option("fup-ser-f", title: "I make care feel thoughtful and meaningful", detail: "I bring creative touch to practical help.", gift: .creativity, secondary: .service, needs: [.discipline: 1, .followThrough: 1])
            ]
        ),
        .teaching: GiftDiscoveryQuestion(
            id: "fup-teaching",
            prompt: "When you explain Scripture, what approach comes most naturally?",
            detail: "This clarifies your teaching lane and depth.",
            options: [
                option("fup-tea-a", title: "Line-by-line explanation", detail: "I like unpacking the text carefully.", gift: .teaching, needs: [.clarity: 2]),
                option("fup-tea-b", title: "Simple summary and application", detail: "I like turning truth into one clear action.", gift: .teaching, secondary: .leadership, needs: [.clarity: 1, .followThrough: 1]),
                option("fup-tea-c", title: "Stories and examples that make it click", detail: "I connect truth to daily life pictures.", gift: .teaching, secondary: .creativity, needs: [.clarity: 1, .discipline: 1]),
                option("fup-tea-d", title: "One-on-one discipleship conversations", detail: "I teach best in personal dialogue.", gift: .teaching, secondary: .mercy, needs: [.compassion: 1, .clarity: 1]),
                option("fup-tea-e", title: "Question and answer format", detail: "I help people process doubts and confusion.", gift: .teaching, secondary: .encouragement, needs: [.clarity: 1, .courage: 1]),
                option("fup-tea-f", title: "Truth defense and worldview clarity", detail: "I like correcting confusion and false ideas.", gift: .teaching, secondary: .leadership, needs: [.clarity: 2, .humility: 1])
            ]
        ),
        .mercy: GiftDiscoveryQuestion(
            id: "fup-mercy",
            prompt: "When someone is hurting, how do you care for them most naturally?",
            detail: "This helps us understand your mercy expression and growth edge.",
            options: [
                option("fup-mer-a", title: "I stay present and listen deeply", detail: "I give people space to be honest.", gift: .mercy, needs: [.compassion: 2, .boundaries: 1]),
                option("fup-mer-b", title: "I give practical care and support", detail: "I help with meals, rides, errands, and real needs.", gift: .service, secondary: .mercy, needs: [.followThrough: 1, .compassion: 1]),
                option("fup-mer-c", title: "I pray and intercede with them", detail: "I carry their pain to God quickly.", gift: .mercy, secondary: .encouragement, needs: [.courage: 1, .compassion: 1]),
                option("fup-mer-d", title: "I gently bring truth and perspective", detail: "I care deeply but still guide toward what is true.", gift: .encouragement, secondary: .mercy, needs: [.clarity: 1, .courage: 1]),
                option("fup-mer-e", title: "I protect healthy boundaries while caring", detail: "I stay loving without carrying everything.", gift: .mercy, secondary: .leadership, needs: [.boundaries: 2, .humility: 1]),
                option("fup-mer-f", title: "I advocate for overlooked people", detail: "I step up when someone is being ignored.", gift: .leadership, secondary: .mercy, needs: [.courage: 1, .compassion: 1])
            ]
        ),
        .leadership: GiftDiscoveryQuestion(
            id: "fup-leadership",
            prompt: "When you lead, what pattern sounds most like you?",
            detail: "Choose the leadership style you use most often.",
            options: [
                option("fup-lead-a", title: "I clarify the mission and next steps", detail: "I help people know where we are going.", gift: .leadership, needs: [.clarity: 2]),
                option("fup-lead-b", title: "I organize people and timelines", detail: "I build order and accountability.", gift: .leadership, secondary: .service, needs: [.followThrough: 2, .humility: 1]),
                option("fup-lead-c", title: "I coach people one-on-one", detail: "I grow leaders personally.", gift: .leadership, secondary: .encouragement, needs: [.consistency: 1, .humility: 1]),
                option("fup-lead-d", title: "I stay calm and decide during pressure", detail: "I carry responsibility in crisis moments.", gift: .leadership, secondary: .service, needs: [.courage: 2, .clarity: 1]),
                option("fup-lead-e", title: "I keep the group spiritually grounded", detail: "I lead by prayer and discernment first.", gift: .leadership, secondary: .mercy, needs: [.humility: 1, .clarity: 1]),
                option("fup-lead-f", title: "I communicate vision in a memorable way", detail: "I use storytelling and creativity to move people.", gift: .creativity, secondary: .leadership, needs: [.discipline: 1, .clarity: 1])
            ]
        ),
        .creativity: GiftDiscoveryQuestion(
            id: "fup-creativity",
            prompt: "How does your creativity usually show up when serving God and people?",
            detail: "Pick what is most true right now, not your ideal version.",
            options: [
                option("fup-cre-a", title: "Writing words that strengthen or teach", detail: "I process truth through writing and messaging.", gift: .creativity, secondary: .encouragement, needs: [.discipline: 1, .clarity: 1]),
                option("fup-cre-b", title: "Visual design that makes truth clearer", detail: "I think in images, layout, and visual flow.", gift: .creativity, secondary: .teaching, needs: [.discipline: 2]),
                option("fup-cre-c", title: "Music, spoken word, or voice", detail: "I use sound and rhythm to help people receive truth.", gift: .creativity, secondary: .encouragement, needs: [.courage: 1, .discipline: 1]),
                option("fup-cre-d", title: "Film, editing, or storytelling media", detail: "I bring narrative and emotion into focus.", gift: .creativity, secondary: .leadership, needs: [.discipline: 2]),
                option("fup-cre-e", title: "Problem-solving and building new systems", detail: "I create tools or workflows that help people.", gift: .leadership, secondary: .creativity, needs: [.clarity: 1, .followThrough: 1]),
                option("fup-cre-f", title: "I have ideas but struggle to finish", detail: "My biggest gap is consistency and execution.", gift: .creativity, secondary: .service, needs: [.discipline: 2, .followThrough: 2])
            ]
        )
    ]

    private static var questionLookup: [String: GiftDiscoveryQuestion] {
        var lookup = questions.reduce(into: [String: GiftDiscoveryQuestion]()) { partial, question in
            partial[question.id] = question
        }
        for question in followUpQuestionsByGift.values {
            lookup[question.id] = question
        }
        return lookup
    }

    private static var baseQuestionLookup: [String: GiftDiscoveryQuestion] {
        questions.reduce(into: [String: GiftDiscoveryQuestion]()) { partial, question in
            partial[question.id] = question
        }
    }

    static func isBaseQuestionID(_ questionID: String) -> Bool {
        baseQuestionLookup[questionID] != nil
    }

    static func adaptiveFollowUp(
        forBaseQuestionID questionID: String,
        selectedOptionID: String,
        existingFollowUpIDs: Set<String>
    ) -> GiftDiscoveryQuestion? {
        guard existingFollowUpIDs.count < maxAdaptiveFollowUps,
              let question = baseQuestionLookup[questionID],
              let selectedOption = question.options.first(where: { $0.id == selectedOptionID }),
              let gift = dominantGift(for: selectedOption),
              let followUp = followUpQuestionsByGift[gift],
              !existingFollowUpIDs.contains(followUp.id) else {
            return nil
        }

        return followUp
    }

    private static func dominantGift(for option: GiftDiscoveryOption) -> SpiritualGiftKind? {
        option.scores.max { left, right in
            if left.value != right.value {
                return left.value < right.value
            }
            return left.key.rawValue > right.key.rawValue
        }?.key
    }

    static func buildProfile(from answers: [String: String], completedAt: Date = .now) -> GiftDiscoveryProfile {
        var scoreMap = SpiritualGiftKind.allCases.reduce(into: [String: Int]()) { partial, gift in
            partial[gift.rawValue] = 0
        }
        var needScoreMap = GiftFormationNeed.allCases.reduce(into: [String: Int]()) { partial, need in
            partial[need.rawValue] = 0
        }

        for (questionID, answerID) in answers {
            guard let question = questionLookup[questionID],
                  let option = question.options.first(where: { $0.id == answerID }) else {
                continue
            }

            for (gift, score) in option.scores {
                scoreMap[gift.rawValue, default: 0] += score
            }

            for (need, score) in option.needScores {
                needScoreMap[need.rawValue, default: 0] += score
            }
        }

        let ordered = SpiritualGiftKind.allCases.sorted { left, right in
            let leftScore = scoreMap[left.rawValue] ?? 0
            let rightScore = scoreMap[right.rawValue] ?? 0
            if leftScore != rightScore {
                return leftScore > rightScore
            }
            return left.title < right.title
        }

        return GiftDiscoveryProfile(
            completedAt: completedAt,
            answers: answers,
            orderedGiftIDs: ordered.map(\.rawValue),
            scoreMap: scoreMap,
            needScoreMap: needScoreMap
        )
    }

    static func morningQuote(for date: Date = .now) -> GlorifyMorningQuote {
        let calendar = Calendar.current
        let dayNumber = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let index = (max(1, dayNumber) - 1) % morningQuotes.count
        return morningQuotes[index]
    }

    static func todayFocus(
        for profile: GiftDiscoveryProfile,
        progressDays: Int,
        date: Date = .now
    ) -> GiftDailyFocus? {
        let orderedGifts = profile.orderedGifts
        guard let primary = orderedGifts.first else { return nil }
        let secondary = orderedGifts.dropFirst().first ?? primary
        let primaryNeed = profile.primaryNeed ?? .consistency

        let path = buildFormationPath(primary: primary, secondary: secondary, need: primaryNeed)

        if progressDays < path.count {
            let draft = path[progressDays]
            return finalize(draft, dayNumber: progressDays + 1, totalSteps: path.count)
        }

        let advancedIndex = max(0, progressDays - path.count)
        let draft = advancedFocus(
            primary: primary,
            secondary: secondary,
            need: primaryNeed,
            cycleIndex: advancedIndex,
            date: date
        )
        return finalize(draft, dayNumber: path.count + advancedIndex + 1, totalSteps: path.count)
    }

    private static func finalize(_ draft: GiftFocusDraft, dayNumber: Int, totalSteps: Int) -> GiftDailyFocus {
        GiftDailyFocus(
            gift: draft.gift,
            title: draft.title,
            detail: draft.detail,
            whyItMatters: draft.whyItMatters,
            actionStep: draft.actionStep,
            reflectionPrompt: draft.reflectionPrompt,
            habitIDs: draft.habitIDs,
            reference: draft.reference,
            dayNumber: dayNumber,
            totalSteps: totalSteps
        )
    }

    private static func buildFormationPath(
        primary: SpiritualGiftKind,
        secondary: SpiritualGiftKind,
        need: GiftFormationNeed
    ) -> [GiftFocusDraft] {
        let primaryHabits = primary.habits
        let secondaryHabits = secondary.habits

        return [
            GiftFocusDraft(
                gift: primary,
                title: "See the gift clearly",
                detail: "Pay attention to where \(primary.title.lowercased()) already shows up in real life, not only where you wish it did.",
                whyItMatters: primary.shortSummary,
                actionStep: primary.dailyActionIdeas[0],
                reflectionPrompt: primary.reflectionPrompts[0],
                habitIDs: [primaryHabits[0].id],
                reference: primary.anchorReference
            ),
            GiftFocusDraft(
                gift: primary,
                title: "Start surrendered",
                detail: "Do not use the gift on autopilot. Submit it to God before you put it into action.",
                whyItMatters: "Gifts stay healthy when they stay surrendered.",
                actionStep: "Pray \(primary.dailyPrayer.lowercased())",
                reflectionPrompt: "Did I move first, or did I let God shape the gift before using it?",
                habitIDs: [primaryHabits[0].id],
                reference: primary.anchorReference
            ),
            GiftFocusDraft(
                gift: primary,
                title: "Anchor it in Scripture",
                detail: "Let God’s Word define how the gift sounds, serves, creates, or leads.",
                whyItMatters: primary.growthLine,
                actionStep: "Read \(primary.anchorReference), then obey one part of it on purpose today.",
                reflectionPrompt: primary.reflectionPrompts[1],
                habitIDs: [primaryHabits[2].id],
                reference: primary.anchorReference
            ),
            GiftFocusDraft(
                gift: primary,
                title: "Face your growth edge",
                detail: need.shortSummary,
                whyItMatters: "Strong gifts still need formation in the place where you drift the easiest.",
                actionStep: need.coachPrompt,
                reflectionPrompt: "Where did \(need.title.lowercased()) feel hardest for me today?",
                habitIDs: [primaryHabits[0].id, primaryHabits[1].id],
                reference: primary.anchorReference
            ),
            GiftFocusDraft(
                gift: primary,
                title: "Do one small act on purpose",
                detail: "Take the gift out of theory today. Let one person actually feel the strength of it.",
                whyItMatters: "Potential grows through real people, not private ideas.",
                actionStep: primary.dailyActionIdeas[1],
                reflectionPrompt: primary.reflectionPrompts[0],
                habitIDs: [primaryHabits[1].id],
                reference: primary.anchorReference
            ),
            GiftFocusDraft(
                gift: primary,
                title: "Reflect honestly",
                detail: "Do not only ask whether you showed up. Ask how you showed up.",
                whyItMatters: "Reflection keeps discipline from becoming empty motion.",
                actionStep: "Write one honest sentence tonight about how your gift felt in real life today.",
                reflectionPrompt: primary.reflectionPrompts[2],
                habitIDs: [primaryHabits[3].id],
                reference: primary.anchorReference
            ),
            GiftFocusDraft(
                gift: primary,
                title: "Build your first weekly rhythm",
                detail: "Choose one habit you can repeat this week instead of waiting for inspiration every day.",
                whyItMatters: "Consistency usually grows through rhythm, not intensity.",
                actionStep: "Pick the one habit from this week that you know you can keep repeating.",
                reflectionPrompt: "What part of this first week already feels sustainable in my real life?",
                habitIDs: [primaryHabits[0].id, primaryHabits[1].id],
                reference: primary.anchorReference
            ),
            GiftFocusDraft(
                gift: primary,
                title: "Use it for one real person",
                detail: "Put the gift where it costs a little more and matters a little more.",
                whyItMatters: "Real ministry begins when the gift starts touching actual people.",
                actionStep: primary.dailyActionIdeas[2],
                reflectionPrompt: "Who actually felt my gift today, and what happened?",
                habitIDs: [primaryHabits[1].id],
                reference: primary.anchorReference
            ),
            GiftFocusDraft(
                gift: primary,
                title: "Stay faithful when unseen",
                detail: "Use the gift in hidden faithfulness, not only when the moment feels obvious or rewarding.",
                whyItMatters: "Quiet consistency is usually where character is built.",
                actionStep: "Use your gift today in a way that may never be noticed by most people.",
                reflectionPrompt: "Did I need recognition in order to stay faithful today?",
                habitIDs: [primaryHabits[3].id],
                reference: primary.anchorReference
            ),
            GiftFocusDraft(
                gift: secondary,
                title: "Train your support gift too",
                detail: "Your support gift can strengthen your main one instead of staying unused in the background.",
                whyItMatters: secondary.shortSummary,
                actionStep: secondary.dailyActionIdeas[0],
                reflectionPrompt: secondary.reflectionPrompts[0],
                habitIDs: [secondaryHabits[0].id],
                reference: secondary.anchorReference
            ),
            GiftFocusDraft(
                gift: primary,
                title: "Let both gifts work together",
                detail: "\(primary.title) gets stronger when \(secondary.title.lowercased()) supports it in a real act of faithfulness.",
                whyItMatters: "Mature people rarely serve God through only one lane at a time.",
                actionStep: combineAction(primary: primary, secondary: secondary),
                reflectionPrompt: "What changed when I let both gifts work together instead of only using one?",
                habitIDs: [primaryHabits[1].id, secondaryHabits[1].id],
                reference: primary.anchorReference
            ),
            GiftFocusDraft(
                gift: primary,
                title: "Watch the weak spot early",
                detail: primary.caution,
                whyItMatters: "Every strength can bend the wrong way if it is not watched with humility.",
                actionStep: "Use \(primary.title.lowercased()) today with extra humility and attention.",
                reflectionPrompt: "Where did I feel drift today, and how quickly did I correct it?",
                habitIDs: [primaryHabits[0].id, primaryHabits[3].id],
                reference: primary.anchorReference
            ),
            GiftFocusDraft(
                gift: primary,
                title: "Repeat under pressure",
                detail: "Use the gift even when the day feels ordinary, messy, or inconvenient.",
                whyItMatters: "A useful gift keeps working outside ideal conditions.",
                actionStep: primary.dailyActionIdeas[3],
                reflectionPrompt: "How did I respond when using the gift felt inconvenient today?",
                habitIDs: [primaryHabits[1].id, primaryHabits[3].id],
                reference: primary.anchorReference
            ),
            GiftFocusDraft(
                gift: primary,
                title: "Ask for honest feedback",
                detail: "Let someone trusted name what they see, not only what you think about yourself.",
                whyItMatters: "Humility keeps the gift open to growth.",
                actionStep: "Ask one trusted person where they already see this gift in you and where it still needs maturity.",
                reflectionPrompt: "What did I learn about myself when I invited honest feedback?",
                habitIDs: [primaryHabits[0].id, primaryHabits[2].id],
                reference: primary.anchorReference
            ),
            GiftFocusDraft(
                gift: primary,
                title: "Review the second week",
                detail: "Look back before you rush ahead. Growth is easier to miss when you never stop to name it.",
                whyItMatters: "Review turns scattered effort into clearer formation.",
                actionStep: "Write down one place you grew and one place that still feels weak.",
                reflectionPrompt: "What changed in me this week, and what still needs work?",
                habitIDs: [primaryHabits[2].id, primaryHabits[3].id],
                reference: primary.anchorReference
            ),
            GiftFocusDraft(
                gift: primary,
                title: "Choose two habits to keep",
                detail: "You do not need to carry everything at once. Choose the habits that matter most.",
                whyItMatters: "A smaller plan kept well beats a bigger plan abandoned quickly.",
                actionStep: "Choose the two habits from this path that feel most important for your next month.",
                reflectionPrompt: "Which two habits will actually change my life if I stay with them?",
                habitIDs: [primaryHabits[0].id, primaryHabits[1].id],
                reference: primary.anchorReference
            ),
            GiftFocusDraft(
                gift: primary,
                title: "Use the gift in community",
                detail: "Move beyond private growth. Practice the gift where other people can genuinely benefit.",
                whyItMatters: "Gifts were given to bless people, not only to shape private identity.",
                actionStep: "Use your gift in a real setting today: church, family, work, school, or community.",
                reflectionPrompt: "Where did I use this gift in a real shared space today?",
                habitIDs: [primaryHabits[1].id, primaryHabits[2].id],
                reference: primary.anchorReference
            ),
            GiftFocusDraft(
                gift: secondary,
                title: "Sharpen the support lane",
                detail: "Do not keep the support gift as a side note. Practice it until it becomes available to God on demand.",
                whyItMatters: secondary.growthLine,
                actionStep: secondary.dailyActionIdeas[1],
                reflectionPrompt: secondary.reflectionPrompts[1],
                habitIDs: [secondaryHabits[1].id, secondaryHabits[2].id],
                reference: secondary.anchorReference
            ),
            GiftFocusDraft(
                gift: primary,
                title: "Protect peace and health",
                detail: "Strong gifts still need wisdom, pace, and clean motives.",
                whyItMatters: "Long-term usefulness depends on not burning out or bending the gift the wrong way.",
                actionStep: need == .boundaries ? "Keep one healthy limit today and still stay faithful." : "Serve today in a way that keeps your peace and motive clean.",
                reflectionPrompt: "What kept my gift healthy today, and what almost pulled it off center?",
                habitIDs: [primaryHabits[0].id, primaryHabits[3].id],
                reference: primary.anchorReference
            ),
            GiftFocusDraft(
                gift: primary,
                title: "Finish what you start",
                detail: "Bring one faithful act to completion instead of stopping at a good intention.",
                whyItMatters: "A mature gift does not only begin things well. It carries them through.",
                actionStep: "Complete one act of obedience connected to your gift before the day ends.",
                reflectionPrompt: "What did I complete today that I might usually leave unfinished?",
                habitIDs: [primaryHabits[1].id, primaryHabits[3].id],
                reference: primary.anchorReference
            ),
            GiftFocusDraft(
                gift: primary,
                title: "Live it as part of your walk",
                detail: "By now this should feel less like a test and more like a way of walking with God on purpose.",
                whyItMatters: "The gift was never meant to stay as a label. It is meant to become faithful obedience.",
                actionStep: "Use your main gift and support gift together in one intentional act today.",
                reflectionPrompt: "Where do I now feel more available to God than when I started this path?",
                habitIDs: [primaryHabits[0].id, primaryHabits[1].id, primaryHabits[2].id, primaryHabits[3].id],
                reference: primary.anchorReference
            )
        ]
    }

    private static func advancedFocus(
        primary: SpiritualGiftKind,
        secondary: SpiritualGiftKind,
        need: GiftFormationNeed,
        cycleIndex: Int,
        date: Date
    ) -> GiftFocusDraft {
        let primaryHabits = primary.habits
        let secondaryHabits = secondary.habits
        let slot = cycleIndex % 8
        let weekIndex = (cycleIndex / 8) + 1

        switch slot {
        case 0:
            return GiftFocusDraft(
                gift: primary,
                title: "Advanced focus: sharpen the main lane",
                detail: "Week \(weekIndex) is about cleaner execution. Use your main gift with more intention than last time.",
                whyItMatters: primary.growthLine,
                actionStep: primary.dailyActionIdeas[(weekIndex - 1) % primary.dailyActionIdeas.count],
                reflectionPrompt: primary.reflectionPrompts[(weekIndex - 1) % primary.reflectionPrompts.count],
                habitIDs: [primaryHabits[0].id, primaryHabits[2].id],
                reference: primary.anchorReference
            )
        case 1:
            return GiftFocusDraft(
                gift: secondary,
                title: "Advanced focus: strengthen the support lane",
                detail: "Keep the support gift available too. Mature people rarely serve through only one lane.",
                whyItMatters: secondary.growthLine,
                actionStep: secondary.dailyActionIdeas[(weekIndex - 1) % secondary.dailyActionIdeas.count],
                reflectionPrompt: secondary.reflectionPrompts[(weekIndex - 1) % secondary.reflectionPrompts.count],
                habitIDs: [secondaryHabits[1].id, secondaryHabits[3].id],
                reference: secondary.anchorReference
            )
        case 2:
            return GiftFocusDraft(
                gift: primary,
                title: "Advanced focus: train the growth edge",
                detail: need.shortSummary,
                whyItMatters: "Long-term fruit usually grows where honest weakness meets steady practice.",
                actionStep: need.coachPrompt,
                reflectionPrompt: "How did \(need.title.lowercased()) show up in my gift today?",
                habitIDs: [primaryHabits[0].id, primaryHabits[1].id],
                reference: primary.anchorReference
            )
        case 3:
            return GiftFocusDraft(
                gift: primary,
                title: "Advanced focus: hidden faithfulness",
                detail: "Train the gift in quiet obedience, not only when the moment feels visible or rewarding.",
                whyItMatters: "Quiet consistency is still real ministry.",
                actionStep: "Use your gift today in a way that probably will not be noticed by most people.",
                reflectionPrompt: "Would I still use this gift if nobody clapped for it?",
                habitIDs: [primaryHabits[3].id],
                reference: primary.anchorReference
            )
        case 4:
            return GiftFocusDraft(
                gift: primary,
                title: "Advanced focus: deeper Scripture",
                detail: "Let truth shape the gift again before the day fills up.",
                whyItMatters: "The healthiest gifts stay rooted in God’s Word.",
                actionStep: "Read \(primary.anchorReference) and write one way it should shape your gift today.",
                reflectionPrompt: "What part of Scripture corrected or sharpened my gift today?",
                habitIDs: [primaryHabits[2].id],
                reference: primary.anchorReference
            )
        case 5:
            return GiftFocusDraft(
                gift: primary,
                title: "Advanced focus: bless a real person",
                detail: "Do not let the gift stay inward. Put it back in motion for someone today.",
                whyItMatters: "People are where the gift becomes useful, not only impressive.",
                actionStep: combineAction(primary: primary, secondary: secondary),
                reflectionPrompt: "Who was actually served by my gift today, and how?",
                habitIDs: [primaryHabits[1].id, secondaryHabits[1].id],
                reference: primary.anchorReference
            )
        case 6:
            return GiftFocusDraft(
                gift: primary,
                title: "Advanced focus: correct drift early",
                detail: primary.caution,
                whyItMatters: "Long-term usefulness depends on catching drift while it is still small.",
                actionStep: "Notice the weak spot in your gift today and respond differently on purpose.",
                reflectionPrompt: "Where did I feel drift today, and what did I do with it?",
                habitIDs: [primaryHabits[0].id, primaryHabits[3].id],
                reference: primary.anchorReference
            )
        default:
            return GiftFocusDraft(
                gift: secondary,
                title: "Advanced focus: review and reset",
                detail: "Slow down and look back. Strong rhythms stay strong when they are reviewed honestly.",
                whyItMatters: "Reflection keeps discipline from becoming empty motion.",
                actionStep: "Review your last seven days, then choose the next habit that needs the most attention.",
                reflectionPrompt: "What has grown most in me lately, and what still feels weak or inconsistent?",
                habitIDs: [secondaryHabits[0].id, secondaryHabits[2].id],
                reference: secondary.anchorReference
            )
        }
    }

    private static func combineAction(primary: SpiritualGiftKind, secondary: SpiritualGiftKind) -> String {
        switch (primary, secondary) {
        case (.encouragement, .teaching), (.teaching, .encouragement):
            return "Give one person a clear biblical encouragement instead of only a nice word."
        case (.service, .mercy), (.mercy, .service):
            return "Care for one person in a way that is both practical and tender."
        case (.leadership, .service), (.service, .leadership):
            return "Take responsibility for one need and help carry it through, not only start it."
        case (.creativity, .encouragement), (.encouragement, .creativity):
            return "Make one small creative piece that strengthens somebody’s faith today."
        case (.creativity, .teaching), (.teaching, .creativity):
            return "Turn one truth from Scripture into something simple, clear, and memorable."
        default:
            return "Use your main gift and support gift together in one honest act of obedience today."
        }
    }
}
