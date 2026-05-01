import Foundation

enum CreativeHabit: String, CaseIterable, Codable, Hashable, Identifiable {
    case worshipFirst
    case createSomething
    case refineWithCare
    case shareLight

    var id: String { rawValue }

    var title: String {
        switch self {
        case .worshipFirst:
            return "Worship first"
        case .createSomething:
            return "Create something"
        case .refineWithCare:
            return "Refine with care"
        case .shareLight:
            return "Share light"
        }
    }

    var detail: String {
        switch self {
        case .worshipFirst:
            return "Start your creativity from praise, not pressure."
        case .createSomething:
            return "Make one real thing instead of waiting for perfect."
        case .refineWithCare:
            return "Honor God by sharpening what He gave you."
        case .shareLight:
            return "Let someone see Christ through what you made."
        }
    }

    var symbol: String {
        switch self {
        case .worshipFirst:
            return "hands.sparkles"
        case .createSomething:
            return "paintpalette"
        case .refineWithCare:
            return "wand.and.stars"
        case .shareLight:
            return "sun.max"
        }
    }
}

struct CreativeCheckIn: Identifiable, Hashable, Codable {
    let id: UUID
    let dayKey: String
    var completedHabits: [CreativeHabit]
    var reflection: String
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        dayKey: String,
        completedHabits: [CreativeHabit] = [],
        reflection: String = "",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.dayKey = dayKey
        self.completedHabits = completedHabits
        self.reflection = reflection
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var completedCount: Int {
        Set(completedHabits).count
    }

    var hasMeaningfulProgress: Bool {
        completedCount > 0 || !reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

enum CreationPostKind: String, CaseIterable, Codable, Hashable, Identifiable {
    case artwork = "Artwork"
    case lyrics = "Lyrics"
    case design = "Design"
    case photography = "Photography"
    case testimony = "Testimony"
    case musicIdea = "Music idea"

    var id: String { rawValue }
}

struct CreationFeedComment: Identifiable, Hashable, Codable {
    let id: UUID
    let authorName: String
    let handle: String
    let text: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        authorName: String,
        handle: String,
        text: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.authorName = authorName
        self.handle = handle
        self.text = text
        self.createdAt = createdAt
    }
}

struct CreationFeedPost: Identifiable, Hashable, Codable {
    let id: UUID
    let authorName: String
    let handle: String
    let kind: CreationPostKind
    let caption: String
    let scriptureReference: String
    let createdAt: Date
    var hearts: Int
    var didHeart: Bool
    var comments: [CreationFeedComment]
    var attachmentFileNames: [String]

    init(
        id: UUID = UUID(),
        authorName: String,
        handle: String,
        kind: CreationPostKind,
        caption: String,
        scriptureReference: String,
        createdAt: Date = .now,
        hearts: Int = 0,
        didHeart: Bool = false,
        comments: [CreationFeedComment] = [],
        attachmentFileNames: [String] = []
    ) {
        self.id = id
        self.authorName = authorName
        self.handle = handle
        self.kind = kind
        self.caption = caption
        self.scriptureReference = scriptureReference
        self.createdAt = createdAt
        self.hearts = hearts
        self.didHeart = didHeart
        self.comments = comments
        self.attachmentFileNames = attachmentFileNames
    }
}
