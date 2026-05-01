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

struct DailyBibleVerse: Hashable {
    let location: BibleLocation
    let verse: BibleVerse

    var referenceText: String {
        "\(location.book) \(location.chapter):\(verse.verse)"
    }

    var shareText: String {
        "\"\(verse.text)\"\n\n\(referenceText) (KJV)\nShared from One Visioon"
    }
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
    private static let expectedVerseCount = 31_102
    private static let searchableBookNames: [(alias: String, canonical: String)] = {
        let canonical = canonicalBookOrder.map { (alias: $0.lowercased(), canonical: $0) }
        let aliases = canonicalBookAliases.map { (alias: $0.key, canonical: $0.value) }
        return (canonical + aliases).sorted { lhs, rhs in
            lhs.alias.count > rhs.alias.count
        }
    }()

    static let books: [BibleBook] = loadBooks()
    private static let allVerseEntries: [DailyBibleVerse] = books.flatMap { book in
        book.chapters.flatMap { chapter in
            chapter.verses.map { verse in
                DailyBibleVerse(
                    location: BibleLocation(book: book.name, chapter: chapter.chapter),
                    verse: verse
                )
            }
        }
    }

    static var oldTestamentBooks: [BibleBook] {
        Array(books.prefix(39))
    }

    static var newTestamentBooks: [BibleBook] {
        Array(books.suffix(27))
    }

    static func book(named name: String) -> BibleBook? {
        books.first(where: { $0.name == name })
    }

    static func chapter(at location: BibleLocation) -> BibleChapter? {
        book(named: location.book)?.chapters.first(where: { $0.chapter == location.chapter })
    }

    static func nextChapter(after location: BibleLocation) -> BibleLocation? {
        guard let currentBookIndex = canonicalBookOrder.firstIndex(of: location.book),
              let currentBook = book(named: location.book) else { return nil }

        if location.chapter < currentBook.chapterCount {
            return BibleLocation(book: location.book, chapter: location.chapter + 1)
        }

        guard currentBookIndex + 1 < books.count else { return nil }
        return BibleLocation(book: books[currentBookIndex + 1].name, chapter: 1)
    }

    static func previousChapter(before location: BibleLocation) -> BibleLocation? {
        guard let currentBookIndex = canonicalBookOrder.firstIndex(of: location.book) else { return nil }

        if location.chapter > 1 {
            return BibleLocation(book: location.book, chapter: location.chapter - 1)
        }

        guard currentBookIndex > 0 else { return nil }
        let previousBook = books[currentBookIndex - 1]
        return BibleLocation(book: previousBook.name, chapter: previousBook.chapterCount)
    }

    static func dailyVerse(for date: Date = .now) -> DailyBibleVerse? {
        guard !allVerseEntries.isEmpty else { return nil }
        if let seasonalVerse = seasonalVerse(for: date) {
            return seasonalVerse
        }
        return nonRepeatingVerse(for: date)
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

    private static func loadBooks() -> [BibleBook] {
        guard let url = resourceURL(),
              let data = try? Data(contentsOf: url),
              let rawMap = try? JSONDecoder().decode([String: String].self, from: data) else {
            return []
        }

        var bookMap: [String: [Int: [BibleVerse]]] = [:]

        for (reference, verseText) in rawMap {
            guard let parsed = parse(reference: reference) else { continue }
            let cleanedText = verseText.replacingOccurrences(of: "# ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            bookMap[parsed.book, default: [:]][parsed.chapter, default: []].append(
                BibleVerse(verse: parsed.verse, text: cleanedText)
            )
        }

        let books: [BibleBook] = canonicalBookOrder.compactMap { bookName -> BibleBook? in
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

        validateBibleStructure(books)
        return books
    }

    private static func resourceURL() -> URL? {
        if let direct = Bundle.main.url(forResource: "verses-1769", withExtension: "json") {
            return direct
        }

        if let nested = Bundle.main.url(forResource: "verses-1769", withExtension: "json", subdirectory: "Resources") {
            return nested
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

    private static func validateBibleStructure(_ books: [BibleBook]) {
        let totalChapters = books.reduce(0) { $0 + $1.chapterCount }
        let totalVerses = books.reduce(0) { $0 + $1.verseCount }

        if books.count != expectedBookCount || totalChapters != expectedChapterCount || totalVerses != expectedVerseCount {
            assertionFailure(
                "Bible library mismatch. Expected \(expectedBookCount) books / \(expectedChapterCount) chapters / \(expectedVerseCount) verses, got \(books.count) / \(totalChapters) / \(totalVerses)."
            )
        }

        for book in books {
            if expectedChapterCounts[book.name] != book.chapterCount {
                assertionFailure("Unexpected chapter count for \(book.name): \(book.chapterCount)")
            }

            for chapter in book.chapters {
                let verseNumbers = chapter.verses.map(\.verse)
                if let lastVerse = verseNumbers.last,
                   verseNumbers != Array(1...lastVerse) {
                    assertionFailure("Verse gap found in \(chapter.title)")
                }
            }
        }
    }

    private static func nonRepeatingVerse(for date: Date) -> DailyBibleVerse? {
        let totalCount = allVerseEntries.count
        guard totalCount > 0 else { return nil }

        let dayOffset = max(0, calendar.dateComponents([.day], from: referenceEpoch, to: calendar.startOfDay(for: date)).day ?? 0)
        let multiplier = permutationMultiplier(for: totalCount)
        let offset = 7919 % totalCount
        let index = (multiplier * (dayOffset % totalCount) + offset) % totalCount
        return allVerseEntries[index]
    }

    private static func seasonalVerse(for date: Date) -> DailyBibleVerse? {
        let normalizedDate = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.year, .month, .day], from: normalizedDate)
        guard let year = components.year, let month = components.month, let day = components.day else { return nil }

        if month == 1 && day == 1 {
            return verse(from: ["Lamentations 3:22", "Proverbs 3:5", "Isaiah 43:19", "Psalm 90:12"], seed: year)
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
                return verse(from: [holyWeekReferences[max(0, min(offset, holyWeekReferences.count - 1))]], seed: year + offset)
            }
        }

        if isThanksgiving(date: normalizedDate) {
            return verse(from: ["Psalm 100:4", "1 Thessalonians 5:18", "Psalm 107:1", "Colossians 3:15"], seed: year)
        }

        if month == 12 && day >= 1 && day <= 23 {
            let adventReferences = [
                "Isaiah 9:6", "Micah 5:2", "Luke 1:37", "Matthew 1:23", "Luke 1:46", "Luke 1:49",
                "Psalm 27:1", "Isaiah 40:3", "John 1:5", "Romans 15:13", "Psalm 46:10", "Isaiah 40:31",
                "Luke 1:78", "Matthew 5:14", "John 8:12", "Psalm 119:105", "Isaiah 7:14", "Luke 2:10",
                "Luke 2:11", "Matthew 2:10", "John 1:14", "Galatians 4:4", "Philippians 2:10"
            ]
            return verse(from: [adventReferences[max(0, min(day - 1, adventReferences.count - 1))]], seed: year + day)
        }

        if month == 12 && day >= 24 && day <= 26 {
            return verse(from: ["Luke 2:11", "Isaiah 9:6", "Matthew 1:21", "John 1:14"], seed: year + day)
        }

        return nil
    }

    private static func verse(from references: [String], seed: Int) -> DailyBibleVerse? {
        guard !references.isEmpty else { return nil }
        let index = abs(seed) % references.count
        return verse(reference: references[index])
    }

    private static func verse(reference: String) -> DailyBibleVerse? {
        guard let target = resolveReference(from: reference),
              let chapter = chapter(at: target.location),
              let verseNumber = target.verse,
              let resolvedVerse = chapter.verses.first(where: { $0.verse == verseNumber }) else {
            return nil
        }

        return DailyBibleVerse(location: target.location, verse: resolvedVerse)
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
