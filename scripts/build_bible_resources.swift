import Foundation

struct Canon {
    static let bookOrder: [String] = [
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

    static let aliases: [String: String] = [
        "psalm": "Psalms",
        "psalms": "Psalms",
        "song of songs": "Song of Solomon",
        "song of solomon": "Song of Solomon",
        "canticles": "Song of Solomon",
        "solomon's song": "Song of Solomon",
        "i samuel": "1 Samuel",
        "ii samuel": "2 Samuel",
        "i kings": "1 Kings",
        "ii kings": "2 Kings",
        "i chronicles": "1 Chronicles",
        "ii chronicles": "2 Chronicles",
        "i corinthians": "1 Corinthians",
        "ii corinthians": "2 Corinthians",
        "i thessalonians": "1 Thessalonians",
        "ii thessalonians": "2 Thessalonians",
        "i timothy": "1 Timothy",
        "ii timothy": "2 Timothy",
        "i peter": "1 Peter",
        "ii peter": "2 Peter",
        "i john": "1 John",
        "ii john": "2 John",
        "iii john": "3 John",
        "revelation of john": "Revelation",
        "1st samuel": "1 Samuel",
        "st samuel": "1 Samuel",
        "2nd samuel": "2 Samuel",
        "nd samuel": "2 Samuel",
        "1st kings": "1 Kings",
        "st kings": "1 Kings",
        "2nd kings": "2 Kings",
        "nd kings": "2 Kings",
        "1st chronicles": "1 Chronicles",
        "st chronicles": "1 Chronicles",
        "2nd chronicles": "2 Chronicles",
        "nd chronicles": "2 Chronicles",
        "1st corinthians": "1 Corinthians",
        "st corinthians": "1 Corinthians",
        "2nd corinthians": "2 Corinthians",
        "nd corinthians": "2 Corinthians",
        "1st thessalonians": "1 Thessalonians",
        "st thessalonians": "1 Thessalonians",
        "2nd thessalonians": "2 Thessalonians",
        "nd thessalonians": "2 Thessalonians",
        "1st timothy": "1 Timothy",
        "st timothy": "1 Timothy",
        "2nd timothy": "2 Timothy",
        "nd timothy": "2 Timothy",
        "1st peter": "1 Peter",
        "st peter": "1 Peter",
        "2nd peter": "2 Peter",
        "nd peter": "2 Peter",
        "1st john": "1 John",
        "st john": "1 John",
        "2nd john": "2 John",
        "nd john": "2 John",
        "3rd john": "3 John",
        "rd john": "3 John"
    ]

    static var headingNames: Set<String> {
        Set(bookOrder.map { $0.lowercased() } + aliases.keys)
    }

    static func canonicalBookName(from raw: String) -> String? {
        let trimmed = raw
            .replacingOccurrences(of: "\u{feff}", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let normalized = trimmed.lowercased()
        if let direct = bookOrder.first(where: { $0.lowercased() == normalized }) {
            return direct
        }

        if let alias = aliases[normalized] {
            return alias
        }

        return nil
    }
}

private struct ExpectedVerseShape {
    let chapterVerseCounts: [String: [Int]]

    var totalVerses: Int {
        chapterVerseCounts.values.flatMap { $0 }.reduce(0, +)
    }

    static func load(from path: String) throws -> ExpectedVerseShape {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let map = try JSONDecoder().decode([String: String].self, from: data)

        var perBookChapter: [String: [Int: Int]] = [:]
        let pattern = try NSRegularExpression(pattern: "^(.*)\\s+(\\d+):(\\d+)$")

        for key in map.keys {
            guard let match = pattern.firstMatch(in: key, range: NSRange(key.startIndex..., in: key)),
                  let bookRange = Range(match.range(at: 1), in: key),
                  let chapterRange = Range(match.range(at: 2), in: key),
                  let verseRange = Range(match.range(at: 3), in: key),
                  let chapter = Int(key[chapterRange]),
                  let verse = Int(key[verseRange]),
                  let canonical = Canon.canonicalBookName(from: String(key[bookRange])) else {
                continue
            }

            let currentMax = perBookChapter[canonical]?[chapter] ?? 0
            if verse > currentMax {
                perBookChapter[canonical, default: [:]][chapter] = verse
            }
        }

        var result: [String: [Int]] = [:]
        for book in Canon.bookOrder {
            let chapterMap = perBookChapter[book] ?? [:]
            let maxChapter = chapterMap.keys.max() ?? 0
            if maxChapter == 0 { continue }
            var chapterCounts: [Int] = []
            chapterCounts.reserveCapacity(maxChapter)
            for chapter in 1...maxChapter {
                chapterCounts.append(chapterMap[chapter] ?? 0)
            }
            result[book] = chapterCounts
        }

        return ExpectedVerseShape(chapterVerseCounts: result)
    }
}

private enum BuildError: Error, CustomStringConvertible {
    case missingBooks(String)
    case malformed(String)

    var description: String {
        switch self {
        case .missingBooks(let message):
            return message
        case .malformed(let message):
            return message
        }
    }
}

private func cleanedVerseText(_ input: String) -> String {
    var text = input
        .replacingOccurrences(of: "<FI>", with: "")
        .replacingOccurrences(of: "<Fi>", with: "")
        .replacingOccurrences(of: "<FR>", with: "")
        .replacingOccurrences(of: "<Fr>", with: "")
        .replacingOccurrences(of: "\u{2014}", with: "-")
        .replacingOccurrences(of: "\u{2013}", with: "-")
        .replacingOccurrences(of: "\u{00a0}", with: " ")
        .replacingOccurrences(of: "\u{200b}", with: "")

    text = text.replacingOccurrences(
        of: "\\s+",
        with: " ",
        options: .regularExpression
    )

    text = text.replacingOccurrences(
        of: "\\s+([,.;:!?])",
        with: "$1",
        options: .regularExpression
    )

    return text.trimmingCharacters(in: .whitespacesAndNewlines)
}

private func flattenESVTokenVerse(_ verse: Any) -> String {
    guard let tokens = verse as? [Any] else {
        if let text = verse as? String {
            return cleanedVerseText(text)
        }
        return ""
    }

    var parts: [String] = []
    parts.reserveCapacity(tokens.count)

    for token in tokens {
        if let entry = token as? [Any], let first = entry.first as? String {
            parts.append(first)
        } else if let text = token as? String {
            parts.append(text)
        }
    }

    let joined = parts.joined(separator: " ")
        .replacingOccurrences(of: "\\s+([,.;:!?])", with: "$1", options: .regularExpression)
        .replacingOccurrences(of: "\\(\\s+", with: "(", options: .regularExpression)
        .replacingOccurrences(of: "\\s+\\)", with: ")", options: .regularExpression)
        .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)

    return cleanedVerseText(joined)
}

private func buildFromStructuredJSON(path: String, versionName: String, isESV: Bool) throws -> [String: String] {
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
          let books = root["books"] as? [String: Any] else {
        throw BuildError.malformed("\(versionName): Missing books object")
    }

    var output: [String: String] = [:]

    for (rawBook, chapterValue) in books {
        guard let canonicalBook = Canon.canonicalBookName(from: rawBook) else { continue }
        guard let chapters = chapterValue as? [Any] else { continue }

        for (chapterOffset, chapterValue) in chapters.enumerated() {
            guard let verses = chapterValue as? [Any] else { continue }
            for (verseOffset, verseValue) in verses.enumerated() {
                let verseText: String
                if isESV {
                    verseText = flattenESVTokenVerse(verseValue)
                } else {
                    verseText = cleanedVerseText((verseValue as? String) ?? "")
                }

                guard !verseText.isEmpty else { continue }
                let chapter = chapterOffset + 1
                let verse = verseOffset + 1
                output["\(canonicalBook) \(chapter):\(verse)"] = verseText
            }
        }
    }

    return output
}

private func parseReferencedTextFile(path: String, versionName: String) throws -> [String: String] {
    let rawData = try Data(contentsOf: URL(fileURLWithPath: path))
    guard var text = String(data: rawData, encoding: .utf8) ?? String(data: rawData, encoding: .utf16) else {
        throw BuildError.malformed("\(versionName): Could not decode text file")
    }

    text = text.replacingOccurrences(of: "\r", with: "\n")
    let lines = text.components(separatedBy: "\n")

    let pattern = try NSRegularExpression(pattern: "^(.+?)\\s+(\\d+):(\\d+)\\s+(.*)$")
    var output: [String: String] = [:]
    var lastReference: String?

    for line in lines {
        let cleanedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedLine.isEmpty else { continue }

        let range = NSRange(cleanedLine.startIndex..., in: cleanedLine)
        if let match = pattern.firstMatch(in: cleanedLine, range: range),
           let bookRange = Range(match.range(at: 1), in: cleanedLine),
           let chapterRange = Range(match.range(at: 2), in: cleanedLine),
           let verseRange = Range(match.range(at: 3), in: cleanedLine),
           let textRange = Range(match.range(at: 4), in: cleanedLine),
           let chapter = Int(cleanedLine[chapterRange]),
           let verse = Int(cleanedLine[verseRange]),
           let canonicalBook = Canon.canonicalBookName(from: String(cleanedLine[bookRange])) {

            let reference = "\(canonicalBook) \(chapter):\(verse)"
            output[reference] = cleanedVerseText(String(cleanedLine[textRange]))
            lastReference = reference
            continue
        }

        if cleanedLine.uppercased() == "OLD TESTAMENT" || cleanedLine.uppercased() == "NEW TESTAMENT" {
            continue
        }

        if let lastReference {
            let appended = cleanedVerseText((output[lastReference] ?? "") + " " + cleanedLine)
            output[lastReference] = appended
        }
    }

    return output
}

private func buildNIVFromReaderText(path: String, expectedShape: ExpectedVerseShape) throws -> [String: String] {
    let rawData = try Data(contentsOf: URL(fileURLWithPath: path))
    guard var text = String(data: rawData, encoding: .utf8) ?? String(data: rawData, encoding: .utf16) else {
        throw BuildError.malformed("NIV: Could not decode text file")
    }

    text = text
        .replacingOccurrences(of: "\r", with: "\n")
        .replacingOccurrences(of: "\u{feff}", with: "")

    let lines = text.components(separatedBy: "\n")
    var linesByBook: [String: [String]] = [:]
    var currentBook: String?

    for rawLine in lines {
        let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !line.isEmpty else { continue }

        if line.uppercased() == "OLD TESTAMENT" || line.uppercased() == "NEW TESTAMENT" {
            continue
        }

        if let canonical = Canon.canonicalBookName(from: line) {
            currentBook = canonical
            linesByBook[canonical, default: []] = []
            continue
        }

        guard let currentBook else { continue }
        linesByBook[currentBook, default: []].append(line)
    }

    var output: [String: String] = [:]
    var failureMessages: [String] = []

    for book in Canon.bookOrder {
        guard let rawLines = linesByBook[book] else {
            failureMessages.append("NIV: Missing book heading for \(book)")
            continue
        }

        let chapterCounts = expectedShape.chapterVerseCounts[book] ?? []
        let expectedTotal = chapterCounts.reduce(0, +)
        guard expectedTotal > 0 else { continue }

        var normalized = rawLines.map(cleanedVerseText).filter { !$0.isEmpty }

        func mergeLine(at index: Int) {
            guard index > 0, index < normalized.count else { return }
            normalized[index - 1] = cleanedVerseText(normalized[index - 1] + " " + normalized[index])
            normalized.remove(at: index)
        }

        func scoreForMerge(index: Int) -> Int {
            guard index > 0, index < normalized.count else { return Int.min }
            let previous = normalized[index - 1]
            let current = normalized[index]
            if current.isEmpty { return 1_000 }

            var score = 0

            if let first = current.first, first.isLowercase {
                score += 700
            }

            if previous.hasSuffix(",") || previous.hasSuffix(";") || previous.hasSuffix(":") || previous.hasSuffix("-") {
                score += 500
            }

            if previous.hasSuffix("(") || previous.hasSuffix("\"") || previous.hasSuffix("'\"") {
                score += 250
            }

            if current.count < 40 {
                score += 90
            }

            if let first = current.first, [")", ",", ".", ";", ":", "!", "?"].contains(first) {
                score += 500
            }

            if current.lowercased().hasPrefix("and ") || current.lowercased().hasPrefix("or ") || current.lowercased().hasPrefix("but ") {
                score += 120
            }

            return score
        }

        while normalized.count > expectedTotal {
            var bestIndex = -1
            var bestScore = Int.min

            for idx in 1..<normalized.count {
                let score = scoreForMerge(index: idx)
                if score > bestScore {
                    bestScore = score
                    bestIndex = idx
                }
            }

            if bestIndex <= 0 {
                mergeLine(at: normalized.count - 1)
            } else {
                mergeLine(at: bestIndex)
            }
        }

        if normalized.count < expectedTotal {
            failureMessages.append("NIV: \(book) has fewer lines (\(normalized.count)) than expected verses (\(expectedTotal))")
            normalized += Array(repeating: "", count: expectedTotal - normalized.count)
        }

        var cursor = 0
        for (chapterIndex, verseCount) in chapterCounts.enumerated() {
            let chapter = chapterIndex + 1
            for verse in 1...verseCount {
                guard cursor < normalized.count else { break }
                let reference = "\(book) \(chapter):\(verse)"
                let verseText = cleanedVerseText(normalized[cursor])
                output[reference] = verseText
                cursor += 1
            }
        }
    }

    if !failureMessages.isEmpty {
        for message in failureMessages {
            fputs("WARNING: \(message)\n", stderr)
        }
    }

    return output
}

private func writeVerseMap(_ map: [String: String], to path: String) throws {
    let cleaned = map
        .mapValues(cleanedVerseText)
        .filter { !$0.value.isEmpty }

    let sorted = cleaned
        .sorted { lhs, rhs in
            lhs.key < rhs.key
        }
        .reduce(into: [String: String]()) { partial, entry in
            partial[entry.key] = entry.value
        }

    let data = try JSONSerialization.data(withJSONObject: sorted, options: [.prettyPrinted, .sortedKeys])
    try data.write(to: URL(fileURLWithPath: path), options: .atomic)
}

private func report(version: String, map: [String: String], expected: ExpectedVerseShape) {
    let total = map.count
    let missing = max(0, expected.totalVerses - total)
    print("\(version): \(total) verses (missing vs KJV shape: \(missing))")
}

func main() throws {
    let repoRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let resourcesDir = repoRoot.appendingPathComponent("onevisioon/Resources")
    let downloadsDir = URL(fileURLWithPath: "/Users/laptcv/Downloads")

    let kjvPath = resourcesDir.appendingPathComponent("verses-1769.json").path
    let expectedShape = try ExpectedVerseShape.load(from: kjvPath)

    let asv = try buildFromStructuredJSON(
        path: downloadsDir.appendingPathComponent("ASV.json").path,
        versionName: "ASV",
        isESV: false
    )

    let esv = try buildFromStructuredJSON(
        path: downloadsDir.appendingPathComponent("ESV.json").path,
        versionName: "ESV",
        isESV: true
    )

    let csb = try parseReferencedTextFile(
        path: downloadsDir.appendingPathComponent("CSB_Full_Bible.txt").path,
        versionName: "CSB"
    )

    let niv = try buildNIVFromReaderText(
        path: downloadsDir.appendingPathComponent("bible-niv.txt").path,
        expectedShape: expectedShape
    )

    try writeVerseMap(asv, to: resourcesDir.appendingPathComponent("verses-asv.json").path)
    try writeVerseMap(esv, to: resourcesDir.appendingPathComponent("verses-esv.json").path)
    try writeVerseMap(csb, to: resourcesDir.appendingPathComponent("verses-csb.json").path)
    try writeVerseMap(niv, to: resourcesDir.appendingPathComponent("verses-niv.json").path)

    report(version: "ASV", map: asv, expected: expectedShape)
    report(version: "ESV", map: esv, expected: expectedShape)
    report(version: "CSB", map: csb, expected: expectedShape)
    report(version: "NIV", map: niv, expected: expectedShape)
}

try main()
