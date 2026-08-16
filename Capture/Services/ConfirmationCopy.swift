import CoreGraphics
import Foundation

/// Confirmation sheet copy. Sentence case. Fields stay facts, never “error”.
enum ConfirmationCopy {
    static let headline = "Does this look right?"
    static let fixing = "Fix it up"
    static let hint = "Tap anything to change it."
    static let cancel = "Cancel"
    static let titleLabel = "Title"
    static let whenLabel = "When"
    static let goesToLabel = "Goes to"
    static let noDate = "No date"
    static let pastDay = "This day has passed."
    static let includeTime = "Include time"
    static let dateOnly = "Date only"
    static let reminders = "Reminders"
    static let calendar = "Calendar"
    /// Brief: 120 on the confirmation header. Capture home stays 240.
    static let headerBloomSize: CGFloat = 120

    static func saveTitle(for destination: CaptureDestination) -> String {
        destination == .event ? "Save event" : "Save reminder"
    }

    static func destinationValue(_ destination: CaptureDestination) -> String {
        destination == .event ? calendar : reminders
    }
}

/// Day and optional clock for the When row. Empty string means the calm “No date” placeholder.
enum ConfirmationWhenFormat {
    static func display(
        date: Date?,
        hasExplicitTime: Bool,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> String {
        guard let date else { return "" }
        let locale = calendar.locale ?? .current
        let day = dayPhrase(date: date, now: now, calendar: calendar, locale: locale)
        guard hasExplicitTime else { return day }
        let time = date.formatted(
            Date.FormatStyle(date: .omitted, time: .shortened).locale(locale)
        )
        return "\(day), \(time)"
    }

    static func isPast(
        date: Date?,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Bool {
        guard let date else { return false }
        return calendar.startOfDay(for: date) < calendar.startOfDay(for: now)
    }

    private static func dayPhrase(
        date: Date,
        now: Date,
        calendar: Calendar,
        locale: Locale
    ) -> String {
        let startNow = calendar.startOfDay(for: now)
        let startDate = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: startNow, to: startDate).day ?? 0
        switch days {
        case 0:
            return "Today"
        case 1:
            return "Tomorrow"
        case -1:
            return "Yesterday"
        case 2...6:
            return date.formatted(Date.FormatStyle().weekday(.wide).locale(locale))
        default:
            var style = Date.FormatStyle().day().month(.abbreviated).locale(locale)
            if calendar.component(.year, from: date) != calendar.component(.year, from: now) {
                style = style.year()
            }
            return date.formatted(style)
        }
    }
}
