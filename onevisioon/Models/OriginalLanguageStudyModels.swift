import Foundation

struct OriginalLanguageSelectedVerse: Identifiable, Hashable {
    let reference: String
    let text: String

    var id: String { reference }
}

struct OriginalLanguageStudyPassage: Identifiable, Hashable {
    let referenceTitle: String
    let languageTitle: String
    let selectedVersionName: String
    let selectedVerses: [OriginalLanguageSelectedVerse]
    let originalVerses: [OriginalLanguageStudyVerse]
    let attribution: String

    var id: String {
        "\(referenceTitle)-\(selectedVersionName)-\(languageTitle)"
    }
}

struct OriginalLanguageStudyVerse: Identifiable, Hashable {
    let reference: String
    let originalText: String
    let tokens: [OriginalLanguageWordToken]

    var id: String { reference }
}

struct OriginalLanguageWordToken: Codable, Hashable, Identifiable {
    let order: Int
    let surface: String
    let lemma: String
    let strongs: String
    let morphology: String
    let transliteration: String
    let glosses: [String]
    let alignedEnglish: String

    var id: String {
        "\(order)-\(surface)-\(strongs)"
    }

    var glossSummary: String {
        if glosses.isEmpty {
            return "Meaning in context is shown by the selected English verse above."
        }

        return glosses.joined(separator: ", ")
    }

    var studyNote: String {
        if glosses.isEmpty {
            return "Use the selected English verse and the chapter context to read this Greek word carefully. Greek word studies are study helps, not one-word replacements for the whole verse."
        }

        return "In this context, this word can carry the sense of \(glossSummary). Always read the gloss through the verse and chapter context rather than treating one English word as the whole meaning."
    }

    func ensuringMeaningData() -> OriginalLanguageWordToken {
        let pronunciation = transliteration.isEmpty ? OriginalLanguageStudyProvider.greekPronunciationGuide(for: surface) : transliteration
        let fallbackGloss = "Meaning in context is shown by the selected English verse above"
        let resolvedGlosses = glosses.isEmpty ? [fallbackGloss] : glosses
        let resolvedAlignedEnglish = alignedEnglish.isEmpty ? resolvedGlosses[0] : alignedEnglish

        return OriginalLanguageWordToken(
            order: order,
            surface: surface,
            lemma: lemma,
            strongs: strongs,
            morphology: morphology,
            transliteration: pronunciation,
            glosses: resolvedGlosses,
            alignedEnglish: resolvedAlignedEnglish
        )
    }
}

enum OriginalLanguageStudyProvider {
    private static var greekWordStudyCache: [String: [OriginalLanguageWordToken]]?
    private static var greekOldTestamentWordStudyCache: [String: [String: [OriginalLanguageWordToken]]] = [:]

    static func supportsOriginalLanguage(for location: BibleLocation) -> Bool {
        BibleDataProvider.chapter(at: location, version: .sblgnt) != nil
    }

    static func passage(
        for location: BibleLocation,
        selectedVerses: [BibleVerse],
        selectedVersion: BibleVersion
    ) -> OriginalLanguageStudyPassage? {
        guard supportsOriginalLanguage(for: location),
              let greekChapter = BibleDataProvider.chapter(at: location, version: .sblgnt) else {
            return nil
        }

        let verseNumbers = Set(selectedVerses.map(\.verse))
        let displayVersion: BibleVersion = selectedVersion.isOriginalLanguage ? .esv : selectedVersion
        let selectedDisplayVerses = selectedVerses.map { verse in
            OriginalLanguageSelectedVerse(
                reference: reference(for: location, verse: verse.verse),
                text: englishVerseText(
                    for: BibleLocation(book: location.book, chapter: location.chapter),
                    verse: verse.verse,
                    version: displayVersion
                ) ?? verse.text
            )
        }

        let originalVerses = greekChapter.verses
            .filter { verseNumbers.contains($0.verse) }
            .sorted(by: { $0.verse < $1.verse })
            .map { verse in
                let verseReference = reference(for: location, verse: verse.verse)
                let tokens = wordStudyTokens(for: verseReference, location: location) ?? fallbackTokens(from: verse.text)
                return OriginalLanguageStudyVerse(
                    reference: verseReference,
                    originalText: verse.text,
                    tokens: tokens
                )
            }

        guard !selectedDisplayVerses.isEmpty, !originalVerses.isEmpty else {
            return nil
        }

        return OriginalLanguageStudyPassage(
            referenceTitle: referenceTitle(for: location, selectedVerses: selectedVerses),
            languageTitle: "Greek",
            selectedVersionName: displayVersion.shortName,
            selectedVerses: selectedDisplayVerses,
            originalVerses: originalVerses,
            attribution: "Greek text: Septuagint Old Testament and SBL Greek New Testament. Word-study data: Open Greek New Testament Project and CenterBLC Septuagint linguistic features."
        )
    }

    private static func wordStudyTokens(for reference: String, location: BibleLocation) -> [OriginalLanguageWordToken]? {
        if let tokens = greekWordStudy()[reference] {
            return tokens.map { $0.ensuringMeaningData() }
        }

        if let tokens = greekOldTestamentWordStudy(for: location.book)[reference] {
            return tokens.map { $0.ensuringMeaningData() }
        }

        return nil
    }

    private static func greekWordStudy() -> [String: [OriginalLanguageWordToken]] {
        if let greekWordStudyCache {
            return greekWordStudyCache
        }

        guard let url = resourceURL(named: "original-language-greek-nt"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: [OriginalLanguageWordToken]].self, from: data) else {
            greekWordStudyCache = [:]
            return [:]
        }

        greekWordStudyCache = decoded
        return decoded
    }

    private static func greekOldTestamentWordStudy(for book: String) -> [String: [OriginalLanguageWordToken]] {
        if let cached = greekOldTestamentWordStudyCache[book] {
            return cached
        }

        guard let url = resourceURL(named: "original-language-greek-ot-\(resourceSlug(for: book))"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: [OriginalLanguageWordToken]].self, from: data) else {
            greekOldTestamentWordStudyCache[book] = [:]
            return [:]
        }

        greekOldTestamentWordStudyCache[book] = decoded
        return decoded
    }

    private static func resourceURL(named resourceName: String) -> URL? {
        if let direct = Bundle.main.url(forResource: resourceName, withExtension: "json") {
            return direct
        }

        return Bundle.main.url(forResource: resourceName, withExtension: "json", subdirectory: "Resources")
    }

    private static func reference(for location: BibleLocation, verse: Int) -> String {
        "\(location.book) \(location.chapter):\(verse)"
    }

    private static func englishVerseText(for location: BibleLocation, verse: Int, version: BibleVersion) -> String? {
        BibleDataProvider.chapter(at: location, version: version)?
            .verses
            .first(where: { $0.verse == verse })?
            .text
    }

    private static func referenceTitle(for location: BibleLocation, selectedVerses: [BibleVerse]) -> String {
        let numbers = selectedVerses.map(\.verse).sorted()
        guard let first = numbers.first else {
            return "\(location.book) \(location.chapter)"
        }

        guard let last = numbers.last, last != first else {
            return "\(location.book) \(location.chapter):\(first)"
        }

        return "\(location.book) \(location.chapter):\(first)-\(last)"
    }

    private static func fallbackTokens(from text: String) -> [OriginalLanguageWordToken] {
        text.split(separator: " ")
            .enumerated()
            .map { index, rawWord in
                let surface = String(rawWord)
                    .trimmingCharacters(in: CharacterSet(charactersIn: ".,;·:!?“”\"'()[]{}"))

                return OriginalLanguageWordToken(
                    order: index + 1,
                    surface: surface,
                    lemma: "",
                    strongs: "",
                    morphology: "",
                    transliteration: greekPronunciationGuide(for: surface),
                    glosses: ["Meaning in context is shown by the selected English verse above"],
                    alignedEnglish: "See the selected English verse above"
                )
            }
            .filter { !$0.surface.isEmpty }
    }

    static func greekPronunciationGuide(for value: String) -> String {
        let folded = value
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "el_GR"))
            .lowercased()

        let replacements: [Character: String] = [
            "α": "a",
            "β": "b",
            "γ": "g",
            "δ": "d",
            "ε": "e",
            "ζ": "z",
            "η": "e",
            "θ": "th",
            "ι": "i",
            "κ": "k",
            "λ": "l",
            "μ": "m",
            "ν": "n",
            "ξ": "x",
            "ο": "o",
            "π": "p",
            "ρ": "r",
            "σ": "s",
            "ς": "s",
            "τ": "t",
            "υ": "u",
            "φ": "ph",
            "χ": "ch",
            "ψ": "ps",
            "ω": "o"
        ]

        return folded.map { replacements[$0] ?? String($0) }.joined()
    }

    private static func resourceSlug(for value: String) -> String {
        value
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
    }
}
