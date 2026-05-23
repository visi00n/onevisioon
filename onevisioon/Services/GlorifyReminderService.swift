import Foundation
import UserNotifications

enum GlorifyReminderService {
    private static let identifierPrefix = "ov_glorify_morning_quote_"

    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    static func enableMorningQuotes(using settings: GlorifyReminderSettings) async -> Bool {
        let granted = await requestAuthorization()
        guard granted else { return false }

        do {
            try await scheduleMorningQuotes(using: settings)
            return true
        } catch {
            return false
        }
    }

    static func refreshMorningQuotesIfNeeded(using settings: GlorifyReminderSettings?) async {
        guard let settings, settings.isEnabled else {
            await disableMorningQuotes()
            return
        }

        let requests = await pendingRequests()
        let matchingRequests = requests.filter { $0.identifier.hasPrefix(identifierPrefix) }
        if matchingRequests.count < 14 {
            try? await scheduleMorningQuotes(using: settings)
        }
    }

    static func disableMorningQuotes() async {
        let center = UNUserNotificationCenter.current()
        let requests = await pendingRequests()
        let ids = requests
            .map(\.identifier)
            .filter { $0.hasPrefix(identifierPrefix) }

        guard !ids.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    static func scheduleMorningQuotes(
        using settings: GlorifyReminderSettings,
        from startDate: Date = .now,
        daysAhead: Int = 45
    ) async throws {
        await disableMorningQuotes()

        let center = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        let firstDay = firstEligibleDay(from: startDate, hour: settings.hour, minute: settings.minute, calendar: calendar)

        for offset in 0..<max(1, daysAhead) {
            guard let day = calendar.date(byAdding: .day, value: offset, to: firstDay) else {
                continue
            }

            var components = calendar.dateComponents([.year, .month, .day], from: day)
            components.hour = settings.hour
            components.minute = settings.minute

            guard let fireDate = calendar.date(from: components) else {
                continue
            }

            let quote = GiftDiscoveryCatalog.morningQuote(for: fireDate)
            let content = UNMutableNotificationContent()
            content.title = "One Visioon Morning Inspiration"
            content.body = quote.text
            content.subtitle = quote.reference
            content.sound = .default
            content.userInfo = [
                "source": quote.source,
                "reference": quote.reference,
                "kind": "glorify-morning-quote"
            ]

            let triggerDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let request = UNNotificationRequest(
                identifier: "\(identifierPrefix)\(dayKey(for: fireDate))",
                content: content,
                trigger: trigger
            )

            try await add(request, to: center)
        }
    }

    private static func firstEligibleDay(
        from startDate: Date,
        hour: Int,
        minute: Int,
        calendar: Calendar
    ) -> Date {
        let startOfDay = calendar.startOfDay(for: startDate)
        let currentComponents = calendar.dateComponents([.hour, .minute], from: startDate)
        let currentHour = currentComponents.hour ?? 0
        let currentMinute = currentComponents.minute ?? 0

        if currentHour > hour || (currentHour == hour && currentMinute >= minute) {
            return calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        }

        return startOfDay
    }

    private static func pendingRequests() async -> [UNNotificationRequest] {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                continuation.resume(returning: requests)
            }
        }
    }

    private static func add(_ request: UNNotificationRequest, to center: UNUserNotificationCenter) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            center.add(request) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    private static func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date)
    }
}
