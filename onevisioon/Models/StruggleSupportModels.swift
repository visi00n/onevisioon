import Foundation

struct StruggleSupportTopic: Identifiable, Hashable {
    let id: String
    let title: String
    let courseTitle: String
    let overview: String
    let planLine: String
    let prayer: String
    let guideID: String
    let accentHex: String
    let verseReferences: [String]
    let actionSteps: [String]
}

enum StruggleSupportCatalog {
    static let currentStruggleTitles = [
        "I feel low on motivation",
        "I overthink everything",
        "I have been sleeping badly",
        "I feel alone",
        "My confidence is low",
        "I keep procrastinating",
        "I feel lost about direction"
    ]

    static let spiritualStruggleTitles = [
        "Lust or impurity",
        "Pride",
        "Greed",
        "Envy",
        "Anger",
        "Laziness",
        "Overeating or lack of control",
        "Gossip or careless words",
        "Lying",
        "Worry or anxiety",
        "Hypocrisy"
    ]

    static var allSelectionTitles: [String] {
        currentStruggleTitles + spiritualStruggleTitles
    }

    static func selectedTopic(for profile: OnboardingAnswerSet) -> StruggleSupportTopic {
        if let spiritual = topic(matching: profile.spiritualStruggle) {
            return spiritual
        }

        if let selected = profile.currentStruggles.compactMap({ topic(matching: $0) }).first {
            return selected
        }

        if let challenge = topic(matching: profile.biggestChallenge) {
            return challenge
        }

        return topic(withID: "direction")
    }

    static func topic(matching title: String) -> StruggleSupportTopic? {
        let key = normalized(title)
        return all.first { topic in
            normalized(topic.title) == key || topic.aliases.contains(key)
        }
    }

    static func topic(withID id: String) -> StruggleSupportTopic {
        all.first(where: { $0.id == id }) ?? all[0]
    }

    static func isSpiritualSelection(_ title: String) -> Bool {
        let key = normalized(title)
        return spiritualStruggleTitles.contains { normalized($0) == key }
    }

    private static func normalized(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    static let all: [StruggleSupportTopic] = [
        StruggleSupportTopic(
            id: "motivation",
            title: "Low motivation",
            courseTitle: "Motivation",
            overview: "This path starts by bringing your attention back to God before your energy level. The daily work is simple: receive truth, pray honestly, and take one faithful step.",
            planLine: "We will build a rhythm of Scripture, prayer, and small obedience so motivation is not the only thing carrying you.",
            prayer: "Father, wake up what has gone dull in me. Help me stop waiting for perfect motivation and give me grace for one faithful step with You today. In Jesus' name, amen.",
            guideID: "discipline",
            accentHex: "D9EBDD",
            verseReferences: ["Psalm 1:2", "Galatians 6:9", "Colossians 3:23"],
            actionSteps: [
                "Open one short passage before any other app.",
                "Name the next faithful action out loud.",
                "Do it for ten minutes before judging how you feel."
            ]
        ),
        StruggleSupportTopic(
            id: "overthinking",
            title: "Overthinking",
            courseTitle: "Overthinking",
            overview: "This helper slows the mind down under Scripture. The goal is to bring repeated thoughts into prayer, truth, and obedience instead of letting them run the whole day.",
            planLine: "We will practice turning mental loops into prayer, renewed thinking, and one clear next step.",
            prayer: "Lord, quiet the loops in my mind. Teach me to trust You with what I cannot solve right now and to obey what You have already made clear. In Jesus' name, amen.",
            guideID: "anxious",
            accentHex: "DDEAF2",
            verseReferences: ["Philippians 4:6", "Romans 12:2", "2 Corinthians 10:5"],
            actionSteps: [
                "Write the thought that keeps repeating.",
                "Turn it into one honest prayer.",
                "Choose one wise action instead of replaying the same fear."
            ]
        ),
        StruggleSupportTopic(
            id: "rest",
            title: "Rest",
            courseTitle: "Rest",
            overview: "When sleep and energy are off, the app will guide you gently back to God without adding shame. Start with Scripture that restores trust and lowers hurry.",
            planLine: "We will build evening honesty, morning Scripture, and small rhythms that help your soul slow down with God.",
            prayer: "Father, restore my body and my soul. Help me receive rest as a gift and bring my worries to You before I carry them into the night. In Jesus' name, amen.",
            guideID: "far-from-god",
            accentHex: "E7E1F0",
            verseReferences: ["Matthew 11:28", "Psalm 4:8", "Psalm 23:3"],
            actionSteps: [
                "Pray one sentence about what you are carrying.",
                "Read one Psalm slowly before bed.",
                "Put tomorrow's worry into God's hands for tonight."
            ]
        ),
        StruggleSupportTopic(
            id: "alone",
            title: "Loneliness",
            courseTitle: "Loneliness",
            overview: "This path meets loneliness with God's nearness and honest connection. You are guided back to Scripture, prayer, and one brave step toward healthy community.",
            planLine: "We will practice receiving God's presence and taking small steps out of isolation.",
            prayer: "God, meet me where I feel unseen. Remind me that You know me fully and give me courage to move toward healthy connection. In Jesus' name, amen.",
            guideID: "alone",
            accentHex: "DDEAF2",
            verseReferences: ["Psalm 139:1", "John 14:18", "Hebrews 13:5"],
            actionSteps: [
                "Read one verse that reminds you God sees you.",
                "Tell God honestly what kind of alone you feel.",
                "Message one safe person instead of disappearing."
            ]
        ),
        StruggleSupportTopic(
            id: "confidence",
            title: "Confidence",
            courseTitle: "Confidence",
            overview: "Confidence is rebuilt around who Christ is and what He says, not performance. This helper points you back to identity, courage, and obedience.",
            planLine: "We will replace self-measuring with Scripture, prayer, and action rooted in Christ.",
            prayer: "Jesus, anchor my confidence in You. Help me stop living under fear of people and teach me to walk as someone loved and called by God. In Your name, amen.",
            guideID: "purpose",
            accentHex: "ECDDAB",
            verseReferences: ["Ephesians 2:10", "2 Timothy 1:7", "Romans 8:1"],
            actionSteps: [
                "Read one identity verse slowly.",
                "Reject one lie you have been agreeing with.",
                "Take one step you would take if Christ's approval mattered most."
            ]
        ),
        StruggleSupportTopic(
            id: "procrastination",
            title: "Procrastination",
            courseTitle: "Procrastination",
            overview: "This path turns delay into one faithful act of obedience. The aim is not pressure, but becoming available to God in the next small thing.",
            planLine: "We will use Scripture, prayer, and small deadlines to close the gap between intention and obedience.",
            prayer: "Father, help me stop hiding in delay. Give me humility, focus, and grace to do the next right thing with You. In Jesus' name, amen.",
            guideID: "discipline",
            accentHex: "D9EBDD",
            verseReferences: ["Proverbs 6:6", "James 4:17", "Colossians 3:23"],
            actionSteps: [
                "Name the task you are avoiding.",
                "Pray before starting, not after feeling ready.",
                "Work for ten honest minutes."
            ]
        ),
        StruggleSupportTopic(
            id: "direction",
            title: "Direction",
            courseTitle: "Direction",
            overview: "When direction feels unclear, this helper brings you back to trust, wisdom, and the next obedient step God has already placed in front of you.",
            planLine: "We will seek God for wisdom without demanding the whole future at once.",
            prayer: "Lord, guide me in truth. Help me trust You with the path and obey the next step You make clear. In Jesus' name, amen.",
            guideID: "purpose",
            accentHex: "ECDDAB",
            verseReferences: ["Proverbs 3:5", "James 1:5", "Psalm 25:4"],
            actionSteps: [
                "Ask God for wisdom plainly.",
                "Write the next step that is already clear.",
                "Take that step before chasing five more answers."
            ]
        ),
        StruggleSupportTopic(
            id: "lust",
            title: "Lust or impurity",
            courseTitle: "Lust",
            overview: "This helper starts with honesty before God and quick movement away from temptation. The daily path points you toward Christ, confession, and replacing hidden patterns with light.",
            planLine: "We will practice fleeing temptation, walking in the light, and seeking God with a clean heart.",
            prayer: "Father, cleanse my desires and bring what is hidden into the light. Help me flee what pulls me from You and pursue Christ with my whole heart. In Jesus' name, amen.",
            guideID: "falling-into-sin",
            accentHex: "F5D2C6",
            verseReferences: ["2 Timothy 2:22", "1 Corinthians 6:18", "1 John 1:9"],
            actionSteps: [
                "Name the trigger without making excuses.",
                "Move away from the access point immediately.",
                "Pray and pursue something righteous in its place."
            ]
        ),
        StruggleSupportTopic(
            id: "pride",
            title: "Pride",
            courseTitle: "Pride",
            overview: "This helper turns the heart back toward humility, repentance, and serving God without needing to be seen as impressive.",
            planLine: "We will practice confession, humility, and quiet obedience before God.",
            prayer: "Lord, humble me without hardening me. Teach me to receive correction, serve quietly, and value Your glory more than my image. In Jesus' name, amen.",
            guideID: "purpose",
            accentHex: "ECDDAB",
            verseReferences: ["James 4:6", "Philippians 2:3", "Proverbs 16:18"],
            actionSteps: [
                "Ask where pride is protecting your image.",
                "Receive one correction without defending yourself.",
                "Do one hidden act of service."
            ]
        ),
        StruggleSupportTopic(
            id: "greed",
            title: "Greed",
            courseTitle: "Greed",
            overview: "This helper brings desire, money, and wanting more under the lordship of Christ through gratitude, generosity, and trust.",
            planLine: "We will practice contentment, stewardship, and worship over constant wanting.",
            prayer: "Father, free me from being ruled by more. Teach me contentment, generosity, and trust in Your provision. In Jesus' name, amen.",
            guideID: "purpose",
            accentHex: "D9EBDD",
            verseReferences: ["Matthew 6:24", "1 Timothy 6:6", "Luke 12:15"],
            actionSteps: [
                "Name what you are afraid to lack.",
                "Thank God for one provision you have treated as ordinary.",
                "Practice one concrete act of generosity."
            ]
        ),
        StruggleSupportTopic(
            id: "envy",
            title: "Envy",
            courseTitle: "Envy",
            overview: "This helper moves comparison into gratitude, trust, and love. Scripture trains the heart to stop measuring God's goodness by someone else's life.",
            planLine: "We will replace comparison with gratitude, prayer, and faithful attention to your own calling.",
            prayer: "God, free me from comparison. Teach me to rejoice in Your goodness to others and trust Your care for me. In Jesus' name, amen.",
            guideID: "purpose",
            accentHex: "DDEAF2",
            verseReferences: ["Galatians 5:26", "Psalm 37:4", "Romans 12:15"],
            actionSteps: [
                "Name the comparison honestly.",
                "Thank God for one gift in that person's life.",
                "Return to one responsibility God has given you."
            ]
        ),
        StruggleSupportTopic(
            id: "anger",
            title: "Anger",
            courseTitle: "Anger",
            overview: "This helper slows anger down under Scripture so your words, timing, and response can come under Christ instead of impulse.",
            planLine: "We will practice slowness, honest prayer, and words that heal instead of inflame.",
            prayer: "Lord, slow me down. Show me what is selfish and what is righteous, and teach me to respond with wisdom and self-control. In Jesus' name, amen.",
            guideID: "angry",
            accentHex: "F5D2C6",
            verseReferences: ["James 1:19", "Proverbs 15:1", "Ephesians 4:26"],
            actionSteps: [
                "Pause before answering.",
                "Pray for wisdom before speaking.",
                "Choose words that lower heat instead of raising it."
            ]
        ),
        StruggleSupportTopic(
            id: "laziness",
            title: "Laziness",
            courseTitle: "Laziness",
            overview: "This helper treats laziness as a discipleship issue, not an identity. Scripture will guide you into diligence, stewardship, and one faithful task at a time.",
            planLine: "We will practice small obedience, diligence, and serving God with the day in front of you.",
            prayer: "Father, wake up diligence in me. Help me stop wasting what You gave me and teach me to work faithfully with You. In Jesus' name, amen.",
            guideID: "discipline",
            accentHex: "D9EBDD",
            verseReferences: ["Proverbs 6:6", "Proverbs 13:4", "Colossians 3:23"],
            actionSteps: [
                "Choose one neglected responsibility.",
                "Start before you feel ready.",
                "Offer the work to God as worship."
            ]
        ),
        StruggleSupportTopic(
            id: "self-control",
            title: "Self-control",
            courseTitle: "Self-control",
            overview: "This helper brings appetite and impulse back under the Spirit's formation through prayer, truth, and wise limits.",
            planLine: "We will practice Spirit-led self-control, honest limits, and worship that reorders desire.",
            prayer: "Holy Spirit, grow self-control in me. Teach me to honor God with my body, choices, and desires today. In Jesus' name, amen.",
            guideID: "discipline",
            accentHex: "ECDDAB",
            verseReferences: ["Galatians 5:22", "1 Corinthians 10:13", "Titus 2:11"],
            actionSteps: [
                "Name the impulse before obeying it.",
                "Put one wise limit in place.",
                "Ask God for strength in the exact moment of choice."
            ]
        ),
        StruggleSupportTopic(
            id: "words",
            title: "Careless words",
            courseTitle: "Words",
            overview: "This helper trains speech under Christ so your words become truthful, careful, and life-giving instead of careless or harmful.",
            planLine: "We will practice slow speech, truthful words, and prayer before conversations.",
            prayer: "Lord, guard my mouth. Make my words truthful, gracious, and useful for building people up. In Jesus' name, amen.",
            guideID: "angry",
            accentHex: "DDEAF2",
            verseReferences: ["Ephesians 4:29", "James 3:5", "Proverbs 18:21"],
            actionSteps: [
                "Pause before repeating something.",
                "Ask if the words are true, loving, and needed.",
                "Speak one encouragement on purpose."
            ]
        ),
        StruggleSupportTopic(
            id: "lying",
            title: "Lying",
            courseTitle: "Truthfulness",
            overview: "This helper brings hidden fear into the light and builds a habit of truth before God and people.",
            planLine: "We will practice confession, truth-telling, and trusting God with the consequences of honesty.",
            prayer: "Father, make me truthful from the inside out. Free me from hiding and help me walk in the light. In Jesus' name, amen.",
            guideID: "falling-into-sin",
            accentHex: "E7E1F0",
            verseReferences: ["Ephesians 4:25", "Psalm 51:6", "John 8:32"],
            actionSteps: [
                "Name what you are tempted to hide.",
                "Tell the truth plainly where it is needed.",
                "Ask God to make honesty safer to you than image."
            ]
        ),
        StruggleSupportTopic(
            id: "anxiety",
            title: "Worry or anxiety",
            courseTitle: "Anxiety",
            overview: "This helper turns worry toward prayer, trust, and disciplined thought. The path begins with the Father's care and one burden surrendered at a time.",
            planLine: "We will practice prayer over spiraling, gratitude over fear, and truth over anxious rehearsal.",
            prayer: "Father, my heart is restless. Teach me to bring my worries to You and receive the peace that guards my heart in Christ. In Jesus' name, amen.",
            guideID: "anxious",
            accentHex: "DDEAF2",
            verseReferences: ["Matthew 6:33", "Philippians 4:6", "1 Peter 5:7"],
            actionSteps: [
                "Write down the worry.",
                "Turn it into a prayer.",
                "Choose the next faithful action instead of spiraling."
            ]
        ),
        StruggleSupportTopic(
            id: "hypocrisy",
            title: "Hypocrisy",
            courseTitle: "Integrity",
            overview: "This helper brings the public and private life together before God through repentance, honesty, and secret obedience.",
            planLine: "We will practice integrity, confession, and worship when no one is watching.",
            prayer: "Jesus, make me whole. Close the gap between what I say and how I live, and teach me to follow You in secret and in public. In Your name, amen.",
            guideID: "far-from-god",
            accentHex: "E7E1F0",
            verseReferences: ["Matthew 23:26", "Psalm 139:23", "James 1:22"],
            actionSteps: [
                "Ask God to search the gap honestly.",
                "Confess one private compromise.",
                "Do one hidden act of obedience."
            ]
        )
    ]
}

private extension StruggleSupportTopic {
    var aliases: Set<String> {
        switch id {
        case "motivation":
            return ["i feel low on motivation", "fresh motivation"]
        case "overthinking":
            return ["i overthink everything", "controlling thoughts"]
        case "rest":
            return ["i have been sleeping badly", "health and energy"]
        case "alone":
            return ["i feel alone"]
        case "confidence":
            return ["my confidence is low", "more confidence in christ"]
        case "procrastination":
            return ["i keep procrastinating"]
        case "direction":
            return ["i feel lost about direction", "purpose and direction", "clear direction"]
        case "self-control":
            return ["overeating or lack of control", "i want more self-control"]
        case "words":
            return ["gossip or careless words"]
        default:
            return [title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()]
        }
    }
}
