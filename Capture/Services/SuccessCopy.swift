import Foundation

/// Success is a statement, never a celebration. No “done”, “great”, or “!”.
enum SuccessCopy {
    static let caption = "Saved"
    static let undo = "Undo"

    static func message(
        destination: CaptureDestination,
        date: Date?,
        hasExplicitTime: Bool,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> String {
        let place = destination == .event ? "Calendar" : "Reminders"
        let when = ConfirmationWhenFormat.display(
            date: date,
            hasExplicitTime: hasExplicitTime,
            now: now,
            calendar: calendar
        )
        if when.isEmpty {
            return "Saved to \(place)"
        }
        return "Saved to \(place) · \(when)"
    }
}
