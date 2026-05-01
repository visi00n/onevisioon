import Foundation

enum BibleHighlightStyle: String, Codable, CaseIterable, Hashable, Identifiable {
    case butter
    case mint
    case sky
    case lilac

    var id: String { rawValue }

    var title: String {
        switch self {
        case .butter:
            return "Butter"
        case .mint:
            return "Mint"
        case .sky:
            return "Sky"
        case .lilac:
            return "Lilac"
        }
    }
}

struct BibleVerseHighlight: Identifiable, Hashable, Codable {
    let reference: String
    var style: BibleHighlightStyle

    var id: String { reference }
}

struct BibleVerseNote: Identifiable, Hashable, Codable {
    let id: UUID
    let references: [String]
    var text: String
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        references: [String],
        text: String,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.references = references
        self.text = text
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var title: String {
        references.joined(separator: ", ")
    }

    var firstReference: String? {
        references.first
    }

    var previewText: String {
        text
    }
}
