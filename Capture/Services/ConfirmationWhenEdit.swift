import Foundation

/// Seeds and clock flags for the confirmation When editor. Does not invent a destination.
enum ConfirmationWhenEdit {
    static func opening(
        date: Date?,
        hasExplicitTime: Bool,
        destination: CaptureDestination,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> (date: Date, hasExplicitTime: Bool) {
        if let date {
            if destination == .event {
                if hasExplicitTime { return (date, true) }
                return (addingClock(to: date, now: now, calendar: calendar), true)
            }
            return (date, hasExplicitTime)
        }
        if destination == .event {
            return (now, true)
        }
        return (calendar.startOfDay(for: now), false)
    }

    static func addingClock(
        to date: Date,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Date {
        var parts = calendar.dateComponents([.year, .month, .day], from: date)
        let clock = calendar.dateComponents([.hour, .minute], from: now)
        parts.hour = clock.hour
        parts.minute = clock.minute
        return calendar.date(from: parts) ?? date
    }

    static func strippingClock(_ date: Date, calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: date)
    }
}
