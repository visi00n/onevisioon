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

    var localMeaning: String {
        if !alignedEnglish.isEmpty {
            return alignedEnglish
        }

        return glosses.first ?? "meaning shown by the selected English verse above"
    }

    var studyNote: String {
        if glosses.isEmpty {
            return "Use the selected English verse and the chapter context to read this Greek word carefully. Greek word studies are study helps, not one-word replacements for the whole verse."
        }

        return "In this verse, the local sense is \(localMeaning). The full recorded gloss range is \(glossSummary). Always read that range through the verse and chapter context rather than treating one English word as the whole meaning."
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

struct GreekWordSearchOccurrence: Hashable, Identifiable {
    let book: String
    let chapter: Int
    let verse: Int
    let surface: String
    let alignedEnglish: String

    var id: String {
        "\(reference)-\(surface)-\(alignedEnglish)"
    }

    var reference: String {
        "\(book) \(chapter):\(verse)"
    }

    init?(record: String) {
        let parts = record.components(separatedBy: "\t")
        guard parts.count >= 5,
              let chapter = Int(parts[1]),
              let verse = Int(parts[2]) else {
            return nil
        }

        self.book = parts[0]
        self.chapter = chapter
        self.verse = verse
        self.surface = parts[3]
        self.alignedEnglish = parts[4]
    }
}

struct GreekWordSearchEntry: Codable, Hashable, Identifiable {
    let key: String
    let displayGreek: String
    let lemma: String
    let strongs: String
    let transliteration: String
    let simpleDefinition: String
    let contextualDefinition: String
    let inDepthDefinition: String
    let usageSummary: String
    let primaryGlosses: [String]
    let relatedGlosses: [String]
    let glosses: [String]
    let searchTerms: [String]
    let occurrences: [String]

    var id: String { key }
    var occurrenceCount: Int { occurrences.count }

    var glossSummary: String {
        guard !glosses.isEmpty else { return simpleDefinition }
        return glosses.joined(separator: ", ")
    }

    var primaryGlossSummary: String {
        guard !primaryGlosses.isEmpty else { return simpleDefinition }
        return primaryGlosses.joined(separator: ", ")
    }

    var relatedGlossSummary: String {
        relatedGlosses.joined(separator: ", ")
    }

    static func canSearch(query: String) -> Bool {
        let normalized = normalizedSearchText(query)
        let compact = normalized.replacingOccurrences(of: " ", with: "")
        if containsGreek(query) || isStrongQuery(compact) {
            return !normalized.isEmpty
        }

        return normalized.count >= 2 && !isLowSignalQuery(normalized)
    }

    func matches(query: String) -> Bool {
        matchingScore(query: query) != nil
    }

    func matchingScore(query: String) -> Int? {
        let normalized = Self.normalizedSearchText(query)
        let compact = normalized.replacingOccurrences(of: " ", with: "")
        guard Self.canSearch(query: query) else { return nil }

        var bestScore = 0
        bestScore = max(
            bestScore,
            Self.scoreIdentifier(
                query: normalized,
                compactQuery: compact,
                values: [key, displayGreek, lemma],
                exact: 12_000,
                prefix: 9_500,
                contains: 6_500
            )
        )
        bestScore = max(bestScore, Self.scoreStrong(query: compact, strongs: strongs))
        bestScore = max(
            bestScore,
            Self.scoreIdentifier(
                query: normalized,
                compactQuery: compact,
                values: [transliteration],
                exact: 9_200,
                prefix: 7_000,
                contains: 5_500
            )
        )

        if !Self.containsGreek(query), !Self.isStrongQuery(compact) {
            bestScore = max(bestScore, englishMeaningScore(normalizedQuery: normalized))
        }

        return bestScore > 0 ? bestScore : nil
    }

    func hasOccurrence(in book: String) -> Bool {
        let prefix = "\(book)\t"
        return occurrences.contains(where: { $0.hasPrefix(prefix) })
    }

    func occurrenceCount(filteredBy book: String?) -> Int {
        guard let book else { return occurrenceCount }
        let prefix = "\(book)\t"
        return occurrences.reduce(0) { count, record in
            count + (record.hasPrefix(prefix) ? 1 : 0)
        }
    }

    func occurrenceList(filteredBy book: String?, limit: Int? = nil) -> [GreekWordSearchOccurrence] {
        var resolved: [GreekWordSearchOccurrence] = []
        let prefix = book.map { "\($0)\t" }

        for record in occurrences {
            if let prefix, !record.hasPrefix(prefix) {
                continue
            }

            guard let occurrence = GreekWordSearchOccurrence(record: record) else {
                continue
            }

            resolved.append(occurrence)

            if let limit, resolved.count >= limit {
                break
            }
        }

        return resolved
    }

    private func englishMeaningScore(normalizedQuery: String) -> Int {
        let queryWords = Self.words(in: normalizedQuery)
        guard !queryWords.isEmpty, !Self.isLowSignalQuery(normalizedQuery) else { return 0 }

        var bestScore = Self.scoreGloss(simpleDefinition, query: normalizedQuery, queryWords: queryWords, base: 10_000) ?? 0
        bestScore = max(
            bestScore,
            Self.scoreGlosses(primaryGlosses, query: normalizedQuery, queryWords: queryWords, base: 10_000, rankPenalty: 0)
        )
        bestScore = max(
            bestScore,
            Self.scoreGlosses(relatedGlosses, query: normalizedQuery, queryWords: queryWords, base: 7_400, rankPenalty: 55)
        )

        for term in searchTerms {
            if Self.normalizedSearchText(term) == normalizedQuery {
                bestScore = max(bestScore, 9_200)
            }
        }

        return bestScore
    }

    private static func scoreGlosses(
        _ values: [String],
        query: String,
        queryWords: [String],
        base: Int,
        rankPenalty: Int
    ) -> Int {
        var bestScore = 0
        for (index, value) in values.enumerated() {
            let adjustedBase = max(1, base - min(index, 20) * rankPenalty)
            if let score = scoreGloss(value, query: query, queryWords: queryWords, base: adjustedBase) {
                bestScore = max(bestScore, score)
            }
        }
        return bestScore
    }

    private static func scoreGloss(_ value: String, query: String, queryWords: [String], base: Int) -> Int? {
        let normalized = normalizedSearchText(value)
        guard !normalized.isEmpty else { return nil }

        if normalized == query {
            return base
        }

        let glossWords = words(in: normalized)
        guard !glossWords.isEmpty else { return nil }

        let glossWordSet = Set(glossWords)
        if queryWords.count > 1, queryWords.allSatisfy({ glossWordSet.contains($0) }) {
            return base - 450
        }

        if queryWords.count == 1, let queryWord = queryWords.first {
            if glossWordSet.contains(queryWord) {
                return base - 650
            }

            if queryWord.count >= 4,
               glossWords.contains(where: { glossWord in
                   glossWord.hasPrefix(queryWord)
                       || (
                           glossWord.count >= 6
                           && !isLowSignalQuery(glossWord)
                           && queryWord.hasPrefix(glossWord)
                       )
               }) {
                return base - 1_300
            }
        }

        if query.count >= 5, normalized.contains(query) {
            return base - 1_500
        }

        return nil
    }

    private static func scoreIdentifier(
        query: String,
        compactQuery: String,
        values: [String],
        exact: Int,
        prefix: Int,
        contains: Int
    ) -> Int {
        var bestScore = 0

        for value in values where !value.isEmpty {
            let normalized = normalizedSearchText(value)
            let compactValue = normalized.replacingOccurrences(of: " ", with: "")
            let valueWords = words(in: normalized)

            if normalized == query || compactValue == compactQuery {
                bestScore = max(bestScore, exact)
            } else if query.count >= 2,
                      normalized.hasPrefix(query) || compactValue.hasPrefix(compactQuery) || valueWords.contains(query) {
                bestScore = max(bestScore, prefix)
            } else if query.count >= 3, normalized.contains(query) || compactValue.contains(compactQuery) {
                bestScore = max(bestScore, contains)
            }
        }

        return bestScore
    }

    private static func scoreStrong(query: String, strongs: String) -> Int {
        guard isStrongQuery(query), !strongs.isEmpty else { return 0 }
        let normalizedStrong = normalizedSearchText(strongs).replacingOccurrences(of: " ", with: "")

        if normalizedStrong == query {
            return 11_000
        }

        if normalizedStrong.hasPrefix(query) {
            return 8_500
        }

        return 0
    }

    private static func normalizedSearchText(_ value: String) -> String {
        let folded = value
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "el_GR"))
            .lowercased()

        var result = ""
        for scalar in folded.unicodeScalars {
            if CharacterSet.alphanumerics.contains(scalar) {
                result.unicodeScalars.append(scalar)
            } else {
                result.append(" ")
            }
        }

        return result.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
    }

    private static func words(in value: String) -> [String] {
        value.split(whereSeparator: { $0.isWhitespace }).map(String.init)
    }

    private static func containsGreek(_ value: String) -> Bool {
        value.unicodeScalars.contains { scalar in
            (0x0370...0x03FF).contains(Int(scalar.value))
                || (0x1F00...0x1FFF).contains(Int(scalar.value))
        }
    }

    private static func isStrongQuery(_ compact: String) -> Bool {
        guard let first = compact.unicodeScalars.first,
              first == "g" || first == "h" else {
            return false
        }

        let rest = compact.unicodeScalars.dropFirst()
        return !rest.isEmpty && rest.allSatisfy { CharacterSet.decimalDigits.contains($0) }
    }

    private static func isLowSignalQuery(_ value: String) -> Bool {
        let lowSignalWords: Set<String> = [
            "a", "all", "also", "an", "and", "among", "as", "at", "be", "but",
            "by", "even", "for", "from", "he", "her", "herself", "him", "himself",
            "his", "i", "in", "into", "it", "itself", "me", "my", "not", "of",
            "on", "one", "or", "our", "same", "she", "that", "the", "their",
            "them", "themselves", "they", "this", "to", "we", "what", "which",
            "who", "whom", "with", "you", "your", "namely"
        ]
        let queryWords = words(in: value)
        return !queryWords.isEmpty && queryWords.allSatisfy { lowSignalWords.contains($0) }
    }

    private enum CodingKeys: String, CodingKey {
        case key
        case displayGreek
        case lemma
        case strongs
        case transliteration
        case simpleDefinition
        case contextualDefinition
        case inDepthDefinition
        case usageSummary
        case primaryGlosses
        case relatedGlosses
        case glosses
        case searchTerms
        case occurrences
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decode(String.self, forKey: .key)
        displayGreek = try container.decode(String.self, forKey: .displayGreek)
        lemma = try container.decodeIfPresent(String.self, forKey: .lemma) ?? ""
        strongs = try container.decodeIfPresent(String.self, forKey: .strongs) ?? ""
        transliteration = try container.decodeIfPresent(String.self, forKey: .transliteration) ?? ""
        simpleDefinition = try container.decodeIfPresent(String.self, forKey: .simpleDefinition) ?? "meaning shown by context"
        contextualDefinition = try container.decodeIfPresent(String.self, forKey: .contextualDefinition) ?? simpleDefinition
        inDepthDefinition = try container.decodeIfPresent(String.self, forKey: .inDepthDefinition) ?? contextualDefinition
        usageSummary = try container.decodeIfPresent(String.self, forKey: .usageSummary) ?? ""
        primaryGlosses = try container.decodeIfPresent([String].self, forKey: .primaryGlosses) ?? []
        relatedGlosses = try container.decodeIfPresent([String].self, forKey: .relatedGlosses) ?? []
        glosses = try container.decodeIfPresent([String].self, forKey: .glosses) ?? []
        searchTerms = try container.decodeIfPresent([String].self, forKey: .searchTerms) ?? []
        occurrences = try container.decodeIfPresent([String].self, forKey: .occurrences) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key, forKey: .key)
        try container.encode(displayGreek, forKey: .displayGreek)
        try container.encode(lemma, forKey: .lemma)
        try container.encode(strongs, forKey: .strongs)
        try container.encode(transliteration, forKey: .transliteration)
        try container.encode(simpleDefinition, forKey: .simpleDefinition)
        try container.encode(contextualDefinition, forKey: .contextualDefinition)
        try container.encode(inDepthDefinition, forKey: .inDepthDefinition)
        try container.encode(usageSummary, forKey: .usageSummary)
        try container.encode(primaryGlosses, forKey: .primaryGlosses)
        try container.encode(relatedGlosses, forKey: .relatedGlosses)
        try container.encode(glosses, forKey: .glosses)
        try container.encode(searchTerms, forKey: .searchTerms)
        try container.encode(occurrences, forKey: .occurrences)
    }
}

enum OriginalLanguageStudyProvider {
    private static var greekWordStudyCache: [String: [OriginalLanguageWordToken]]?
    private static var greekOldTestamentWordStudyCache: [String: [String: [OriginalLanguageWordToken]]] = [:]
    private static var greekWordSearchCache: [GreekWordSearchEntry]?

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

    static func greekWordSearchResults(
        matching query: String,
        bookFilter: String?,
        limit: Int = 80
    ) -> [GreekWordSearchEntry] {
        let cleaned = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard GreekWordSearchEntry.canSearch(query: cleaned) else { return [] }

        let matches = greekWordSearchIndex()
            .compactMap { entry -> (entry: GreekWordSearchEntry, score: Int)? in
                guard let score = entry.matchingScore(query: cleaned) else { return nil }
                guard let bookFilter else { return (entry, score) }
                return entry.hasOccurrence(in: bookFilter) ? (entry, score) : nil
            }
            .sorted { lhs, rhs in
                if lhs.score != rhs.score { return lhs.score > rhs.score }

                let lhsCount = lhs.entry.occurrenceCount(filteredBy: bookFilter)
                let rhsCount = rhs.entry.occurrenceCount(filteredBy: bookFilter)
                if lhsCount != rhsCount { return lhsCount > rhsCount }
                return lhs.entry.displayGreek.localizedCaseInsensitiveCompare(rhs.entry.displayGreek) == .orderedAscending
            }

        return Array(matches.prefix(limit).map(\.entry))
    }

    static func greekWordSearchEntryCount() -> Int {
        greekWordSearchIndex().count
    }

    private static func greekWordSearchIndex() -> [GreekWordSearchEntry] {
        if let greekWordSearchCache {
            return greekWordSearchCache
        }

        guard let url = resourceURL(named: "original-language-greek-search-index"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([GreekWordSearchEntry].self, from: data) else {
            greekWordSearchCache = []
            return []
        }

        greekWordSearchCache = decoded
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
