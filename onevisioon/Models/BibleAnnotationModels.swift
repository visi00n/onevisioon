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
    var version: BibleVersion

    var id: String {
        "\(version.rawValue):\(reference)"
    }

    init(reference: String, style: BibleHighlightStyle, version: BibleVersion = .esv) {
        self.reference = reference
        self.style = style
        self.version = version
    }

    private enum CodingKeys: String, CodingKey {
        case reference
        case style
        case version
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        reference = try container.decode(String.self, forKey: .reference)
        style = try container.decode(BibleHighlightStyle.self, forKey: .style)
        version = try container.decodeIfPresent(BibleVersion.self, forKey: .version) ?? .esv
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(reference, forKey: .reference)
        try container.encode(style, forKey: .style)
        try container.encode(version, forKey: .version)
    }
}

struct BibleVerseNote: Identifiable, Hashable, Codable {
    let id: UUID
    let references: [String]
    var text: String
    let createdAt: Date
    var updatedAt: Date
    var version: BibleVersion

    init(
        id: UUID = UUID(),
        references: [String],
        text: String,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        version: BibleVersion = .esv
    ) {
        self.id = id
        self.references = references
        self.text = text
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.version = version
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

    private enum CodingKeys: String, CodingKey {
        case id
        case references
        case text
        case createdAt
        case updatedAt
        case version
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        references = try container.decodeIfPresent([String].self, forKey: .references) ?? []
        text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? .now
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? createdAt
        version = try container.decodeIfPresent(BibleVersion.self, forKey: .version) ?? .esv
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(references, forKey: .references)
        try container.encode(text, forKey: .text)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(version, forKey: .version)
    }
}
