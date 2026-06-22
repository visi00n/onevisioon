import Foundation

struct BibleLocation: Hashable, Codable, Identifiable {
    let book: String
    let chapter: Int

    var id: String { "\(book)-\(chapter)" }
}

struct BibleReferenceTarget: Hashable, Identifiable {
    let location: BibleLocation
    let verse: Int?

    var id: String {
        if let verse {
            return "\(location.id)-\(verse)"
        }
        return location.id
    }
}

struct BibleVerse: Identifiable, Hashable {
    let verse: Int
    let text: String

    var id: Int { verse }
}

struct BibleChapter: Identifiable, Hashable {
    let book: String
    let chapter: Int
    let verses: [BibleVerse]

    var id: String { "\(book)-\(chapter)" }
    var title: String { "\(book) \(chapter)" }
    var verseCount: Int { verses.count }
}

struct BibleBook: Identifiable, Hashable {
    let name: String
    let chapters: [BibleChapter]

    var id: String { name }
    var chapterCount: Int { chapters.count }
    var verseCount: Int { chapters.reduce(0) { $0 + $1.verseCount } }
}

enum BibleVersion: String, CaseIterable, Codable, Hashable, Identifiable {
    case kjv
    case esv
    case asv
    case csb
    case niv
    case sblgnt

    static let storageKey = "ov_selected_bible_version"

    var id: String { rawValue }

    var shortName: String {
        switch self {
        case .sblgnt:
            return "Greek"
        default:
            return rawValue.uppercased()
        }
    }

    var title: String {
        switch self {
        case .kjv:
            return "King James Version (1769)"
        case .esv:
            return "English Standard Version"
        case .asv:
            return "American Standard Version"
        case .csb:
            return "Christian Standard Bible"
        case .niv:
            return "New International Version"
        case .sblgnt:
            return "Greek Bible (Septuagint + SBLGNT)"
        }
    }

    var resourceName: String {
        switch self {
        case .kjv:
            return "verses-1769"
        case .sblgnt:
            return "verses-greek"
        default:
            return "verses-\(rawValue)"
        }
    }

    var bibleGatewayCode: String {
        switch self {
        case .sblgnt:
            return "SBLGNT"
        default:
            return shortName
        }
    }

    var isNewTestamentOnly: Bool {
        false
    }

    var isOriginalLanguage: Bool {
        self == .sblgnt
    }

    static func fromStored(_ value: String?) -> BibleVersion {
        guard let value, let parsed = BibleVersion(rawValue: value.lowercased()) else {
            return .esv
        }
        return parsed
    }

    static func persistedSelection() -> BibleVersion {
        fromStored(UserDefaults.standard.string(forKey: storageKey))
    }
}

struct DailyBibleVerse: Hashable {
    let version: BibleVersion
    let location: BibleLocation
    let verse: BibleVerse

    var referenceText: String {
        "\(location.book) \(location.chapter):\(verse.verse)"
    }

    var shareText: String {
        "\"\(verse.text)\"\n\n\(referenceText) (\(version.shortName))\nShared from One Visioon"
    }
}

private struct DailyReferenceFeed: Codable {
    let referenceEpoch: String
    let entries: [DailyReferenceEntry]
}

private struct DailyReferenceEntry: Codable, Hashable {
    let date: String
    let referenceText: String
}

struct ResetChallengeProgress: Codable, Hashable {
    var startedAt: Date?
    var completedDays: [Int]

    static let empty = ResetChallengeProgress(startedAt: nil, completedDays: [])

    var normalized: ResetChallengeProgress {
        ResetChallengeProgress(
            startedAt: startedAt,
            completedDays: Array(
                Set(completedDays.filter { (1...7).contains($0) })
            )
            .sorted()
        )
    }
}

enum BibleDataProvider {
    private static let calendar = Calendar(identifier: .gregorian)
    private static let referenceEpoch = DateComponents(calendar: calendar, year: 2026, month: 1, day: 1).date ?? .now

    static let canonicalBookOrder: [String] = [
        "Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy",
        "Joshua", "Judges", "Ruth", "1 Samuel", "2 Samuel",
        "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles", "Ezra",
        "Nehemiah", "Esther", "Job", "Psalms", "Proverbs",
        "Ecclesiastes", "Song of Solomon", "Isaiah", "Jeremiah", "Lamentations",
        "Ezekiel", "Daniel", "Hosea", "Joel", "Amos",
        "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk",
        "Zephaniah", "Haggai", "Zechariah", "Malachi",
        "Matthew", "Mark", "Luke", "John", "Acts",
        "Romans", "1 Corinthians", "2 Corinthians", "Galatians", "Ephesians",
        "Philippians", "Colossians", "1 Thessalonians", "2 Thessalonians", "1 Timothy",
        "2 Timothy", "Titus", "Philemon", "Hebrews", "James",
        "1 Peter", "2 Peter", "1 John", "2 John", "3 John",
        "Jude", "Revelation"
    ]

    private static let oldTestamentBookNames = Set(canonicalBookOrder.prefix(39))
    private static let newTestamentBookNames = Set(canonicalBookOrder.suffix(27))

    private static let canonicalBookAliases: [String: String] = [
        "psalm": "Psalms",
        "song of songs": "Song of Solomon",
        "solomon's song": "Song of Solomon",
        "canticles": "Song of Solomon"
    ]

    private static let expectedChapterCounts: [String: Int] = [
        "Genesis": 50, "Exodus": 40, "Leviticus": 27, "Numbers": 36, "Deuteronomy": 34,
        "Joshua": 24, "Judges": 21, "Ruth": 4, "1 Samuel": 31, "2 Samuel": 24,
        "1 Kings": 22, "2 Kings": 25, "1 Chronicles": 29, "2 Chronicles": 36, "Ezra": 10,
        "Nehemiah": 13, "Esther": 10, "Job": 42, "Psalms": 150, "Proverbs": 31,
        "Ecclesiastes": 12, "Song of Solomon": 8, "Isaiah": 66, "Jeremiah": 52, "Lamentations": 5,
        "Ezekiel": 48, "Daniel": 12, "Hosea": 14, "Joel": 3, "Amos": 9,
        "Obadiah": 1, "Jonah": 4, "Micah": 7, "Nahum": 3, "Habakkuk": 3,
        "Zephaniah": 3, "Haggai": 2, "Zechariah": 14, "Malachi": 4,
        "Matthew": 28, "Mark": 16, "Luke": 24, "John": 21, "Acts": 28,
        "Romans": 16, "1 Corinthians": 16, "2 Corinthians": 13, "Galatians": 6, "Ephesians": 6,
        "Philippians": 4, "Colossians": 4, "1 Thessalonians": 5, "2 Thessalonians": 3, "1 Timothy": 6,
        "2 Timothy": 4, "Titus": 3, "Philemon": 1, "Hebrews": 13, "James": 5,
        "1 Peter": 5, "2 Peter": 3, "1 John": 5, "2 John": 1, "3 John": 1,
        "Jude": 1, "Revelation": 22
    ]

    private static let expectedBookCount = 66
    private static let expectedChapterCount = 1189

    private static let searchableBookNames: [(alias: String, canonical: String)] = {
        let canonical = canonicalBookOrder.map { (alias: $0.lowercased(), canonical: $0) }
        let aliases = canonicalBookAliases.map { (alias: $0.key, canonical: $0.value) }
        return (canonical + aliases).sorted { lhs, rhs in
            lhs.alias.count > rhs.alias.count
        }
    }()

    private static var booksCache: [BibleVersion: [BibleBook]] = [:]
    private static var dailyReferenceFeedCache: DailyReferenceFeed?
    private static var didLoadDailyReferenceFeed = false

    private static let fallbackDailyReferencePool = [
        "Genesis 1:1", "Exodus 14:14", "Numbers 6:24", "Deuteronomy 6:5",
        "Joshua 1:9", "Ruth 1:16", "1 Samuel 16:7", "2 Chronicles 7:14",
        "Job 19:25", "Psalms 23:1", "Psalms 27:1", "Psalms 34:8",
        "Psalms 46:1", "Psalms 46:10", "Psalms 51:10", "Psalms 91:1",
        "Psalms 100:4", "Psalms 119:105", "Proverbs 3:5", "Proverbs 4:23",
        "Isaiah 9:6", "Isaiah 26:3", "Isaiah 40:31", "Isaiah 41:10",
        "Isaiah 53:5", "Jeremiah 29:11", "Lamentations 3:22", "Micah 6:8",
        "Matthew 5:14", "Matthew 6:33", "Matthew 11:28", "Matthew 28:6",
        "Mark 11:24", "Luke 1:37", "Luke 2:10", "Luke 2:11",
        "John 1:5", "John 1:14", "John 3:16", "John 8:12",
        "John 14:6", "John 15:5", "Romans 5:8", "Romans 8:28",
        "Romans 12:2", "1 Corinthians 13:4", "2 Corinthians 5:17", "Galatians 5:22",
        "Ephesians 2:8", "Ephesians 6:11", "Philippians 2:10", "Philippians 4:6",
        "Philippians 4:13", "Colossians 3:15", "1 Thessalonians 5:18", "2 Timothy 1:7",
        "Hebrews 11:1", "Hebrews 12:2", "James 1:5", "1 Peter 5:7",
        "1 John 1:9", "1 John 4:19", "Revelation 21:4"
    ]

    private static let dailyReferenceDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static var books: [BibleBook] {
        books(for: currentSelectedVersion())
    }

    static var oldTestamentBooks: [BibleBook] {
        oldTestamentBooks(for: currentSelectedVersion())
    }

    static var newTestamentBooks: [BibleBook] {
        newTestamentBooks(for: currentSelectedVersion())
    }

    static func oldTestamentBooks(for version: BibleVersion = currentSelectedVersion()) -> [BibleBook] {
        books(for: version).filter { oldTestamentBookNames.contains($0.name) }
    }

    static func newTestamentBooks(for version: BibleVersion = currentSelectedVersion()) -> [BibleBook] {
        books(for: version).filter { newTestamentBookNames.contains($0.name) }
    }

    static func books(for version: BibleVersion = currentSelectedVersion()) -> [BibleBook] {
        if let cached = booksCache[version] {
            return cached
        }

        let loaded = loadBooks(for: version)
        booksCache[version] = loaded
        return loaded
    }

    static func book(named name: String, version: BibleVersion = currentSelectedVersion()) -> BibleBook? {
        books(for: version).first(where: { $0.name == name })
    }

    static func chapter(at location: BibleLocation, version: BibleVersion = currentSelectedVersion()) -> BibleChapter? {
        book(named: location.book, version: version)?.chapters.first(where: { $0.chapter == location.chapter })
    }

    static func nextChapter(after location: BibleLocation, version: BibleVersion = currentSelectedVersion()) -> BibleLocation? {
        let versionBooks = books(for: version)
        guard let currentBookIndex = versionBooks.firstIndex(where: { $0.name == location.book }),
              let currentBook = book(named: location.book, version: version) else { return nil }

        if let currentChapterIndex = currentBook.chapters.firstIndex(where: { $0.chapter == location.chapter }),
           currentChapterIndex + 1 < currentBook.chapters.count {
            return BibleLocation(
                book: location.book,
                chapter: currentBook.chapters[currentChapterIndex + 1].chapter
            )
        }

        guard currentBookIndex + 1 < versionBooks.count else { return nil }
        return BibleLocation(book: versionBooks[currentBookIndex + 1].name, chapter: 1)
    }

    static func previousChapter(before location: BibleLocation, version: BibleVersion = currentSelectedVersion()) -> BibleLocation? {
        let versionBooks = books(for: version)
        guard let currentBookIndex = versionBooks.firstIndex(where: { $0.name == location.book }),
              let currentBook = book(named: location.book, version: version) else { return nil }

        if let currentChapterIndex = currentBook.chapters.firstIndex(where: { $0.chapter == location.chapter }),
           currentChapterIndex > 0 {
            return BibleLocation(
                book: location.book,
                chapter: currentBook.chapters[currentChapterIndex - 1].chapter
            )
        }

        guard currentBookIndex > 0 else { return nil }
        let previousBook = versionBooks[currentBookIndex - 1]
        return BibleLocation(book: previousBook.name, chapter: previousBook.chapterCount)
    }

    static func dailyVerse(for date: Date = .now, version: BibleVersion = currentSelectedVersion()) -> DailyBibleVerse? {
        guard let reference = dailyReference(for: date) else { return nil }
        return verse(reference: reference, version: version) ?? verse(reference: reference, version: .esv)
    }

    static func communityLikeCount(for verse: DailyBibleVerse) -> Int {
        let hash = stableHash(for: verse.referenceText)
        return 1200 + (hash % 6800)
    }

    static func resolveLocation(from query: String) -> BibleLocation? {
        resolveReference(from: query)?.location
    }

    static func resolveReference(from query: String) -> BibleReferenceTarget? {
        let cleaned = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return nil }

        let lowercased = cleaned.lowercased()
        for entry in searchableBookNames {
            guard lowercased.hasPrefix(entry.alias) else { continue }

            let remainder = cleaned.dropFirst(entry.alias.count).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !remainder.isEmpty else {
                return BibleReferenceTarget(
                    location: BibleLocation(book: entry.canonical, chapter: 1),
                    verse: nil
                )
            }

            if let parsed = parseChapterAndVerse(from: remainder) {
                return BibleReferenceTarget(
                    location: BibleLocation(book: entry.canonical, chapter: parsed.chapter),
                    verse: parsed.verse
                )
            }
        }

        return nil
    }

    private static func currentSelectedVersion() -> BibleVersion {
        BibleVersion.persistedSelection()
    }

    private static func loadBooks(for version: BibleVersion) -> [BibleBook] {
        guard let url = resourceURL(for: version),
              let data = try? Data(contentsOf: url),
              let rawMap = try? JSONDecoder().decode([String: String].self, from: data) else {
            return []
        }

        var bookMap: [String: [Int: [BibleVerse]]] = [:]

        for (reference, verseText) in rawMap {
            guard let parsed = parse(reference: reference) else { continue }

            let cleanedText = cleanVerseText(verseText)
            guard !cleanedText.isEmpty else { continue }

            bookMap[parsed.book, default: [:]][parsed.chapter, default: []].append(
                BibleVerse(verse: parsed.verse, text: cleanedText)
            )
        }

        let loadedBooks: [BibleBook] = canonicalBookOrder.compactMap { bookName -> BibleBook? in
            guard let chaptersMap = bookMap[bookName] else { return nil }

            let chapters = chaptersMap.keys.sorted().map { chapterNumber in
                BibleChapter(
                    book: bookName,
                    chapter: chapterNumber,
                    verses: chaptersMap[chapterNumber, default: []].sorted(by: { $0.verse < $1.verse })
                )
            }

            return BibleBook(name: bookName, chapters: chapters)
        }

        validateBibleStructure(loadedBooks, version: version)
        return loadedBooks
    }

    private static func resourceURL(for version: BibleVersion) -> URL? {
        if let direct = Bundle.main.url(forResource: version.resourceName, withExtension: "json") {
            return direct
        }

        if let nested = Bundle.main.url(forResource: version.resourceName, withExtension: "json", subdirectory: "Resources") {
            return nested
        }

        if version == .sblgnt,
           let legacyGreek = Bundle.main.url(forResource: "verses-sblgnt", withExtension: "json") {
            return legacyGreek
        }

        if version == .sblgnt,
           let nestedLegacyGreek = Bundle.main.url(forResource: "verses-sblgnt", withExtension: "json", subdirectory: "Resources") {
            return nestedLegacyGreek
        }

        if version == .kjv,
           let legacy = Bundle.main.url(forResource: "verses-1769", withExtension: "json") {
            return legacy
        }

        if version == .kjv,
           let nestedLegacy = Bundle.main.url(forResource: "verses-1769", withExtension: "json", subdirectory: "Resources") {
            return nestedLegacy
        }

        return nil
    }

    private static func parse(reference: String) -> (book: String, chapter: Int, verse: Int)? {
        let pattern = #"^(.*)\s+(\d+):(\d+)$"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                in: reference,
                range: NSRange(reference.startIndex..., in: reference)
              ),
              let bookRange = Range(match.range(at: 1), in: reference),
              let chapterRange = Range(match.range(at: 2), in: reference),
              let verseRange = Range(match.range(at: 3), in: reference),
              let book = canonicalBookName(from: String(reference[bookRange])),
              let chapter = Int(reference[chapterRange]),
              let verse = Int(reference[verseRange]) else {
            return nil
        }

        return (book, chapter, verse)
    }

    private static func parseChapterAndVerse(from value: String) -> (chapter: Int, verse: Int?)? {
        let pattern = #"(\d+)(?::(\d+))?"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                in: value,
                range: NSRange(value.startIndex..., in: value)
              ),
              let chapterRange = Range(match.range(at: 1), in: value),
              let chapter = Int(value[chapterRange]),
              chapter > 0 else {
            return nil
        }

        if let verseRange = Range(match.range(at: 2), in: value),
           let verse = Int(value[verseRange]),
           verse > 0 {
            return (chapter, verse)
        }

        return (chapter, nil)
    }

    private static func canonicalBookName(from value: String) -> String? {
        let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return nil }

        if let canonical = canonicalBookOrder.first(where: {
            $0.localizedCaseInsensitiveCompare(cleaned) == .orderedSame
        }) {
            return canonical
        }

        return canonicalBookAliases[cleaned.lowercased()]
    }

    private static func validateBibleStructure(_ books: [BibleBook], version: BibleVersion) {
        if version.isOriginalLanguage {
            return
        }

        let totalChapters = books.reduce(0) { $0 + $1.chapterCount }

        let expectedBooks = version.isNewTestamentOnly ? 27 : expectedBookCount
        let expectedChapters = version.isNewTestamentOnly ? 260 : expectedChapterCount

        if books.count != expectedBooks || totalChapters != expectedChapters {
            assertionFailure(
                "\(version.shortName) structure mismatch. Expected \(expectedBooks) books / \(expectedChapters) chapters, got \(books.count) / \(totalChapters)."
            )
        }

        for book in books {
            if expectedChapterCounts[book.name] != book.chapterCount {
                assertionFailure("Unexpected chapter count for \(version.shortName) \(book.name): \(book.chapterCount)")
            }

            for chapter in book.chapters {
                let verseNumbers = chapter.verses.map(\.verse)
                guard verseNumbers == verseNumbers.sorted() else {
                    assertionFailure("Out-of-order verses in \(version.shortName) \(chapter.title)")
                    continue
                }

                if Set(verseNumbers).count != verseNumbers.count {
                    assertionFailure("Duplicate verse numbers in \(version.shortName) \(chapter.title)")
                }

                if let first = verseNumbers.first, first < 1 {
                    assertionFailure("Invalid verse number in \(version.shortName) \(chapter.title)")
                }
            }
        }
    }

    private static func dailyReference(for date: Date) -> String? {
        if let seasonalReference = seasonalReference(for: date) {
            return seasonalReference
        }

        return feedReference(for: date)
            ?? nonRepeatingReference(for: date, from: fallbackDailyReferencePool)
    }

    private static func feedReference(for date: Date) -> String? {
        guard let feed = dailyReferenceFeed(),
              !feed.entries.isEmpty else { return nil }

        let normalizedDate = calendar.startOfDay(for: date)
        let key = dailyReferenceDateFormatter.string(from: normalizedDate)

        if let exact = feed.entries.first(where: { $0.date == key }) {
            return exact.referenceText
        }

        guard let epoch = dailyReferenceDateFormatter.date(from: feed.referenceEpoch) else {
            return feed.entries.first?.referenceText
        }

        let dayOffset = max(0, calendar.dateComponents([.day], from: calendar.startOfDay(for: epoch), to: normalizedDate).day ?? 0)
        return feed.entries[dayOffset % feed.entries.count].referenceText
    }

    private static func dailyReferenceFeed() -> DailyReferenceFeed? {
        if didLoadDailyReferenceFeed {
            return dailyReferenceFeedCache
        }

        didLoadDailyReferenceFeed = true
        guard let url = dailyReferenceFeedURL(),
              let data = try? Data(contentsOf: url),
              let feed = try? JSONDecoder().decode(DailyReferenceFeed.self, from: data) else {
            return nil
        }

        let entries = feed.entries.filter { resolveReference(from: $0.referenceText) != nil }
        let parsedFeed = DailyReferenceFeed(referenceEpoch: feed.referenceEpoch, entries: entries)
        dailyReferenceFeedCache = parsedFeed
        return parsedFeed
    }

    private static func dailyReferenceFeedURL() -> URL? {
        if let direct = Bundle.main.url(forResource: "daily-verse-feed", withExtension: "json") {
            return direct
        }

        if let nested = Bundle.main.url(forResource: "daily-verse-feed", withExtension: "json", subdirectory: "Resources") {
            return nested
        }

        if let plugInsURL = Bundle.main.builtInPlugInsURL,
           let widgetBundle = Bundle(url: plugInsURL.appendingPathComponent("onevisioonWidgets.appex")),
           let widgetResource = widgetBundle.url(forResource: "daily-verse-feed", withExtension: "json") {
            return widgetResource
        }

        return nil
    }

    private static func nonRepeatingReference(for date: Date, from references: [String]) -> String? {
        let totalCount = references.count
        guard totalCount > 0 else { return nil }

        let dayOffset = max(0, calendar.dateComponents([.day], from: referenceEpoch, to: calendar.startOfDay(for: date)).day ?? 0)
        let multiplier = permutationMultiplier(for: totalCount)
        let offset = 7919 % totalCount
        let index = (multiplier * (dayOffset % totalCount) + offset) % totalCount
        return references[index]
    }

    private static func seasonalReference(for date: Date) -> String? {
        let normalizedDate = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.year, .month, .day], from: normalizedDate)
        guard let year = components.year, let month = components.month, let day = components.day else { return nil }

        if month == 1 && day == 1 {
            return reference(from: ["Lamentations 3:22", "Proverbs 3:5", "Isaiah 43:19", "Psalms 90:12"], seed: year)
        }

        if let easterSunday = easterSunday(in: year) {
            let holyWeekStart = calendar.date(byAdding: .day, value: -7, to: easterSunday) ?? easterSunday
            if normalizedDate >= holyWeekStart && normalizedDate <= easterSunday {
                let offset = calendar.dateComponents([.day], from: holyWeekStart, to: normalizedDate).day ?? 0
                let holyWeekReferences = [
                    "John 12:13",
                    "Mark 11:17",
                    "John 12:24",
                    "Matthew 26:41",
                    "Luke 22:19",
                    "Isaiah 53:5",
                    "Matthew 27:60",
                    "Matthew 28:6"
                ]
                return reference(
                    from: [holyWeekReferences[max(0, min(offset, holyWeekReferences.count - 1))]],
                    seed: year + offset
                )
            }
        }

        if isThanksgiving(date: normalizedDate) {
            return reference(from: ["Psalms 100:4", "1 Thessalonians 5:18", "Psalms 107:1", "Colossians 3:15"], seed: year)
        }

        if month == 12 && day >= 1 && day <= 23 {
            let adventReferences = [
                "Isaiah 9:6", "Micah 5:2", "Luke 1:37", "Matthew 1:23", "Luke 1:46", "Luke 1:49",
                "Psalms 27:1", "Isaiah 40:3", "John 1:5", "Romans 15:13", "Psalms 46:10", "Isaiah 40:31",
                "Luke 1:78", "Matthew 5:14", "John 8:12", "Psalms 119:105", "Isaiah 7:14", "Luke 2:10",
                "Luke 2:11", "Matthew 2:10", "John 1:14", "Galatians 4:4", "Philippians 2:10"
            ]
            return reference(
                from: [adventReferences[max(0, min(day - 1, adventReferences.count - 1))]],
                seed: year + day
            )
        }

        if month == 12 && day >= 24 && day <= 26 {
            return reference(from: ["Luke 2:11", "Isaiah 9:6", "Matthew 1:21", "John 1:14"], seed: year + day)
        }

        return nil
    }

    private static func reference(from references: [String], seed: Int) -> String? {
        guard !references.isEmpty else { return nil }
        let index = abs(seed) % references.count
        return references[index]
    }

    private static func verse(reference: String, version: BibleVersion) -> DailyBibleVerse? {
        guard let target = resolveReference(from: reference),
              let verseNumber = target.verse else {
            return nil
        }

        if let cachedBooks = booksCache[version],
           let cachedChapter = cachedBooks
            .first(where: { $0.name == target.location.book })?
            .chapters
            .first(where: { $0.chapter == target.location.chapter }),
           let cachedVerse = cachedChapter.verses.first(where: { $0.verse == verseNumber }) {
            return DailyBibleVerse(version: version, location: target.location, verse: cachedVerse)
        }

        guard let text = rawVerseText(reference: reference, version: version) else {
            return nil
        }

        return DailyBibleVerse(
            version: version,
            location: target.location,
            verse: BibleVerse(verse: verseNumber, text: text)
        )
    }

    private static func rawVerseText(reference: String, version: BibleVersion) -> String? {
        guard let url = resourceURL(for: version),
              let data = try? Data(contentsOf: url),
              let rawMap = try? JSONDecoder().decode([String: String].self, from: data),
              let rawText = rawMap[reference] else {
            return nil
        }

        let cleanedText = cleanVerseText(rawText)
        return cleanedText.isEmpty ? nil : cleanedText
    }

    private static func cleanVerseText(_ text: String) -> String {
        text
            .replacingOccurrences(of: "# ", with: "")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func referenceSortKey(_ reference: String) -> String {
        guard let target = resolveReference(from: reference) else { return reference }
        let bookIndex = canonicalBookOrder.firstIndex(of: target.location.book) ?? .max
        let verseNumber = target.verse ?? .max
        return String(format: "%03d-%03d-%03d", bookIndex, target.location.chapter, verseNumber)
    }

    private static func permutationMultiplier(for totalCount: Int) -> Int {
        guard totalCount > 1 else { return 1 }

        var multiplier = 8191 % totalCount
        if multiplier == 0 { multiplier = 1 }
        if multiplier % 2 == 0 { multiplier += 1 }

        while greatestCommonDivisor(multiplier, totalCount) != 1 {
            multiplier += 2
        }

        return multiplier
    }

    private static func greatestCommonDivisor(_ lhs: Int, _ rhs: Int) -> Int {
        var a = abs(lhs)
        var b = abs(rhs)

        while b != 0 {
            let remainder = a % b
            a = b
            b = remainder
        }

        return a
    }

    private static func stableHash(for text: String) -> Int {
        var value: UInt64 = 1469598103934665603
        let prime: UInt64 = 1099511628211

        for byte in text.utf8 {
            value ^= UInt64(byte)
            value &*= prime
        }

        return Int(value % UInt64(Int.max))
    }

    private static func easterSunday(in year: Int) -> Date? {
        let a = year % 19
        let b = year / 100
        let c = year % 100
        let d = b / 4
        let e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30
        let i = c / 4
        let k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7
        let m = (a + 11 * h + 22 * l) / 451
        let month = (h + l - 7 * m + 114) / 31
        let day = ((h + l - 7 * m + 114) % 31) + 1

        return calendar.date(from: DateComponents(year: year, month: month, day: day))
    }

    private static func isThanksgiving(date: Date) -> Bool {
        let components = calendar.dateComponents([.year, .month, .weekday, .weekdayOrdinal], from: date)
        return components.month == 11 && components.weekday == 5 && components.weekdayOrdinal == 4
    }
}
