import Foundation
import SwiftData

/// History screen copy. Sentence case. Three-day memory, not an archive.
enum HistoryCopy {
    static let title = "History"
    static let emptyTitle = "Nothing captured yet"
    static let emptyBody = "Tap the well on the home screen and say the thing you keep almost forgetting."
    static let captureAction = "Capture something"
    static let today = "Today"
    static let yesterday = "Yesterday"
    static let justNow = "Just now"
    static let swipeHint = "Tap a row to swipe it aside, then delete."
    static let deleteTitle = "Remove this capture?"
    static let murmurOnly = "Delete from Murmur only"
    static let deleteNeeded = "This is still here. Try again."
    static let cancel = "Cancel"
    /// Spec §12: empty history is three-day memory, not an archive.
    static let ttlNote = "Murmur keeps three days here."

    static func openHint(for destination: CaptureDestination) -> String {
        destination == .event ? "Opens in Calendar" : "Opens in Reminders"
    }

    static func alsoExternal(for destination: CaptureDestination) -> String {
        destination == .event ? "Also delete the event" : "Also delete the reminder"
    }
}

/// Day groups and relative time for history rows. Newest-first lists stay in capture order.
enum HistoryListFormat {
    static func sectionTitle(
        createdAt: Date,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> String {
        let locale = calendar.locale ?? .current
        let startNow = calendar.startOfDay(for: now)
        let startCreated = calendar.startOfDay(for: createdAt)
        let days = calendar.dateComponents([.day], from: startCreated, to: startNow).day ?? 0
        switch days {
        case 0:
            return HistoryCopy.today
        case 1:
            return HistoryCopy.yesterday
        default:
            return createdAt.formatted(
                Date.FormatStyle().weekday(.abbreviated).month(.abbreviated).day().locale(locale)
            )
        }
    }

    static func relative(
        createdAt: Date,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> String {
        let startNow = calendar.startOfDay(for: now)
        let startCreated = calendar.startOfDay(for: createdAt)
        let days = calendar.dateComponents([.day], from: startCreated, to: startNow).day ?? 0
        if days >= 1 {
            return days == 1 ? HistoryCopy.yesterday : sectionTitle(createdAt: createdAt, now: now, calendar: calendar)
        }
        let seconds = max(0, now.timeIntervalSince(createdAt))
        let minutes = Int(seconds / 60)
        if minutes < 1 {
            return HistoryCopy.justNow
        }
        if minutes < 60 {
            return "\(minutes)m ago"
        }
        let hours = minutes / 60
        return "\(hours)h ago"
    }

    static func grouped(
        _ captures: [Capture],
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> [(title: String, items: [Capture])] {
        var result: [(title: String, items: [Capture])] = []
        for capture in captures {
            let title = sectionTitle(createdAt: capture.createdAt, now: now, calendar: calendar)
            if result.last?.title == title {
                result[result.count - 1].items.append(capture)
            } else {
                result.append((title, [capture]))
            }
        }
        return result
    }
}
