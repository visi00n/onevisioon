import SwiftUI
import WidgetKit

struct WidgetDailyVerse: Hashable, Codable {
    let referenceText: String
    let text: String
}

private struct WidgetDailyVerseEntry: Hashable, Codable {
    let date: String
    let referenceText: String
    let text: String

    var verse: WidgetDailyVerse {
        WidgetDailyVerse(referenceText: referenceText, text: text)
    }
}

private struct WidgetDailyVerseFeed: Codable {
    let referenceEpoch: String
    let entries: [WidgetDailyVerseEntry]
}

private enum WidgetDailyVerseStore {
    private static let decoder = JSONDecoder()

    static func verse(for date: Date = .now) -> WidgetDailyVerse {
        guard let feed = loadFeed() else {
            return fallbackVerse
        }

        let entries = feed.entries.filter(\.isWidgetReady)
        guard !entries.isEmpty else {
            return fallbackVerse
        }

        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        let formatter = isoFormatter
        let key = formatter.string(from: normalizedDate)

        if let exact = entries.first(where: { $0.date == key }) {
            return exact.verse
        }

        guard let epoch = formatter.date(from: feed.referenceEpoch) else {
            return entries.first?.verse ?? fallbackVerse
        }

        let offset = max(0, calendar.dateComponents([.day], from: calendar.startOfDay(for: epoch), to: normalizedDate).day ?? 0)
        let entry = entries[offset % entries.count]
        return entry.verse
    }

    private static func loadFeed() -> WidgetDailyVerseFeed? {
        guard let url = Bundle.main.url(forResource: "daily-verse-feed", withExtension: "json") else {
            return nil
        }

        guard let data = try? Data(contentsOf: url) else {
            return nil
        }

        return try? decoder.decode(WidgetDailyVerseFeed.self, from: data)
    }

    private static let isoFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let fallbackVerse = WidgetDailyVerse(
        referenceText: "Psalms 23:1",
        text: "The Lord is my shepherd; I shall not want."
    )
}

private extension WidgetDailyVerseEntry {
    var isWidgetReady: Bool {
        let normalized = text
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard (12...150).contains(normalized.count) else {
            return false
        }

        let lowercased = normalized.lowercased()
        let blockedTerms = [
            "begat",
            "burnt offering",
            "concubine",
            "destroyed",
            "famine",
            "pestilence",
            "plague",
            "slew",
            "sword",
            "vengeance",
            "wrath"
        ]

        return !blockedTerms.contains { lowercased.contains($0) }
    }
}

struct DailyVerseWidgetEntry: TimelineEntry {
    let date: Date
    let verse: WidgetDailyVerse
}

struct DailyVerseTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> DailyVerseWidgetEntry {
        DailyVerseWidgetEntry(date: .now, verse: placeholderVerse)
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyVerseWidgetEntry) -> Void) {
        completion(makeEntry(for: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyVerseWidgetEntry>) -> Void) {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)

        let entries = (0..<7).compactMap { offset -> DailyVerseWidgetEntry? in
            let entryDate: Date
            if offset == 0 {
                entryDate = now
            } else {
                guard let shifted = calendar.date(byAdding: .day, value: offset, to: startOfToday) else {
                    return nil
                }
                entryDate = shifted
            }

            return makeEntry(for: entryDate)
        }

        let nextRefresh = calendar.date(
            byAdding: .minute,
            value: 5,
            to: calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now) ?? now)
        ) ?? now.addingTimeInterval(86_400)

        completion(Timeline(entries: entries, policy: .after(nextRefresh)))
    }

    private func makeEntry(for date: Date) -> DailyVerseWidgetEntry {
        DailyVerseWidgetEntry(
            date: date,
            verse: WidgetDailyVerseStore.verse(for: date)
        )
    }

    private var placeholderVerse: WidgetDailyVerse {
        WidgetDailyVerseStore.verse(for: .now)
    }
}

struct DailyVerseWidget: Widget {
    private let kind = "DailyVerseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyVerseTimelineProvider()) { entry in
            DailyVerseWidgetEntryView(entry: entry)
                .widgetURL(deepLinkURL(for: entry.verse))
        }
        .configurationDisplayName("Daily Verse")
        .description("See a fresh Scripture verse each day on your Home Screen or Lock Screen.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryInline,
            .accessoryRectangular
        ])
    }

    private func deepLinkURL(for verse: WidgetDailyVerse) -> URL? {
        var components = URLComponents()
        components.scheme = "vsn.onevisioon"
        components.host = "bible"
        components.queryItems = [
            URLQueryItem(name: "ref", value: verse.referenceText)
        ]
        return components.url
    }
}

private struct DailyVerseWidgetEntryView: View {
    let entry: DailyVerseWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemMedium:
            mediumWidget
        case .accessoryInline:
            inlineWidget
        case .accessoryRectangular:
            rectangularWidget
        default:
            smallWidget
        }
    }

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(entry.verse.text)
                .font(adaptiveVerseFont(maxSize: 15, minSize: 10.5, comfortLength: 110))
                .foregroundStyle(.white)
                .lineLimit(6)
                .minimumScaleFactor(0.68)
                .allowsTightening(true)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)

            metadataRow
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(16)
        .containerBackground(for: .widget) {
            DailyVerseWidgetBackground()
        }
    }

    private var mediumWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(entry.verse.text)
                .font(adaptiveVerseFont(maxSize: 17, minSize: 12, comfortLength: 170))
                .foregroundStyle(.white)
                .lineLimit(7)
                .minimumScaleFactor(0.7)
                .allowsTightening(true)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)

            metadataRow
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(18)
        .containerBackground(for: .widget) {
            DailyVerseWidgetBackground()
        }
    }

    private var rectangularWidget: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.verse.text)
                .font(adaptiveVerseFont(maxSize: 12, minSize: 8.5, comfortLength: 62))
                .foregroundStyle(.white)
                .lineLimit(3)
                .minimumScaleFactor(0.65)
                .allowsTightening(true)

            Spacer(minLength: 0)

            metadataRow
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) {
            DailyVerseWidgetBackground()
        }
    }

    private var inlineWidget: some View {
        Text("\(entry.verse.text) • One Visioon")
    }

    private var metadataRow: some View {
        HStack {
            Text("Bible")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(DailyVerseWidgetPalette.gold)

            Spacer()

            Text("One Visioon")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(DailyVerseWidgetPalette.muted)
        }
    }

    private func adaptiveVerseFont(maxSize: CGFloat, minSize: CGFloat, comfortLength: Int) -> Font {
        let excessCharacters = max(0, entry.verse.text.count - comfortLength)
        let reduction = min(maxSize - minSize, CGFloat(excessCharacters) / 20)
        return .system(size: maxSize - reduction, weight: .medium)
    }
}

private struct DailyVerseWidgetBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                DailyVerseWidgetPalette.top,
                DailyVerseWidgetPalette.bottom
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private enum DailyVerseWidgetPalette {
    static let top = Color(red: 0.10, green: 0.11, blue: 0.15)
    static let bottom = Color(red: 0.05, green: 0.07, blue: 0.10)
    static let gold = Color(red: 0.86, green: 0.69, blue: 0.24)
    static let muted = Color.white.opacity(0.70)
}
