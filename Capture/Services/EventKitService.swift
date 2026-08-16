import EventKit
import Foundation

enum EventKitServiceError: Error, Equatable {
    case notAuthorized
    case emptyTitle
    case missingStart
    case noReminderCalendar
    case noEventCalendar
    case missingIdentifier
    case itemNotFound
}

enum EventKitCopy {
    static let remindersAccessNeeded = "Reminders access is needed to save this."
    static let calendarAccessNeeded = "Calendar access is needed to save this."
    static let nothingToSave = "Nothing to save yet."
    static let aTimeIsNeeded = "A time is needed to save this."
    static let nothingToRemove = "Nothing to remove."
    static let nothingToOpen = "Nothing to open yet."
    static let reminderGone = "That reminder is no longer in Reminders."
    static let eventGone = "That event is no longer in Calendar."

    static func reminderFact(for error: EventKitServiceError) -> String {
        switch error {
        case .notAuthorized, .noReminderCalendar:
            remindersAccessNeeded
        case .emptyTitle, .missingStart:
            nothingToSave
        case .noEventCalendar:
            calendarAccessNeeded
        case .missingIdentifier:
            nothingToRemove
        case .itemNotFound:
            reminderGone
        }
    }

    static func eventFact(for error: EventKitServiceError) -> String {
        switch error {
        case .notAuthorized, .noEventCalendar:
            calendarAccessNeeded
        case .emptyTitle:
            nothingToSave
        case .missingStart:
            aTimeIsNeeded
        case .noReminderCalendar:
            remindersAccessNeeded
        case .missingIdentifier:
            nothingToRemove
        case .itemNotFound:
            eventGone
        }
    }

    static func openFact(for error: EventKitServiceError, destination: CaptureDestination) -> String {
        switch error {
        case .missingIdentifier:
            nothingToOpen
        case .itemNotFound:
            destination == .event ? eventGone : reminderGone
        default:
            destination == .event ? eventFact(for: error) : reminderFact(for: error)
        }
    }
}

/// Due date for an `EKReminder`. Date-only omits hour/minute so it is not a fake clock time.
enum ReminderDue {
    static func components(
        due: Date?,
        hasExplicitTime: Bool,
        calendar: Calendar = .current
    ) -> DateComponents? {
        guard let due else { return nil }
        if hasExplicitTime {
            return calendar.dateComponents([.year, .month, .day, .hour, .minute], from: due)
        }
        return calendar.dateComponents([.year, .month, .day], from: due)
    }
}

/// Event end. Spec default is 60 minutes when `durationMinutes` is missing.
enum EventSpan {
    static let defaultMinutes = 60

    static func end(start: Date, durationMinutes: Int?) -> Date {
        let minutes = max(1, durationMinutes ?? defaultMinutes)
        return start.addingTimeInterval(TimeInterval(minutes * 60))
    }
}

@MainActor
protocol EventKitServicing: AnyObject {
    func createReminder(title: String, due: Date?, hasExplicitTime: Bool) async throws -> String
    func createEvent(title: String, start: Date, durationMinutes: Int?) async throws -> String
    func deleteItem(identifier: String) async throws
    func openingURL(identifier: String, destination: CaptureDestination) throws -> URL
}

@MainActor
final class EventKitService: EventKitServicing {
    private let store: EKEventStore
    private let reminderAuthorization: () -> EKAuthorizationStatus
    private let eventAuthorization: () -> EKAuthorizationStatus

    init(
        store: EKEventStore = EKEventStore(),
        reminderAuthorization: @escaping () -> EKAuthorizationStatus = {
            EKEventStore.authorizationStatus(for: .reminder)
        },
        eventAuthorization: @escaping () -> EKAuthorizationStatus = {
            EKEventStore.authorizationStatus(for: .event)
        }
    ) {
        self.store = store
        self.reminderAuthorization = reminderAuthorization
        self.eventAuthorization = eventAuthorization
    }

    func createReminder(title: String, due: Date?, hasExplicitTime: Bool) async throws -> String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw EventKitServiceError.emptyTitle }
        guard reminderAuthorization() == .fullAccess else { throw EventKitServiceError.notAuthorized }
        guard let calendar = store.defaultCalendarForNewReminders() else {
            throw EventKitServiceError.noReminderCalendar
        }

        let reminder = EKReminder(eventStore: store)
        reminder.title = trimmed
        reminder.calendar = calendar
        reminder.dueDateComponents = ReminderDue.components(due: due, hasExplicitTime: hasExplicitTime)
        try store.save(reminder, commit: true)
        LoggingPolicy.log(.reminderCreated, category: .eventKit)
        return reminder.calendarItemIdentifier
    }

    func createEvent(title: String, start: Date, durationMinutes: Int?) async throws -> String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw EventKitServiceError.emptyTitle }
        guard eventAuthorization() == .fullAccess else { throw EventKitServiceError.notAuthorized }
        guard let calendar = store.defaultCalendarForNewEvents else {
            throw EventKitServiceError.noEventCalendar
        }

        let event = EKEvent(eventStore: store)
        event.title = trimmed
        event.calendar = calendar
        event.startDate = start
        event.endDate = EventSpan.end(start: start, durationMinutes: durationMinutes)
        try store.save(event, span: .thisEvent, commit: true)
        LoggingPolicy.log(.eventCreated, category: .eventKit)
        return event.calendarItemIdentifier
    }

    func deleteItem(identifier: String) async throws {
        let trimmed = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw EventKitServiceError.missingIdentifier }

        guard let item = store.calendarItem(withIdentifier: trimmed) else {
            LoggingPolicy.log(.itemDeleted, category: .eventKit)
            return
        }

        if let reminder = item as? EKReminder {
            guard reminderAuthorization() == .fullAccess else { throw EventKitServiceError.notAuthorized }
            try store.remove(reminder, commit: true)
        } else if let event = item as? EKEvent {
            guard eventAuthorization() == .fullAccess else { throw EventKitServiceError.notAuthorized }
            try store.remove(event, span: .thisEvent, commit: true)
        } else {
            return
        }
        LoggingPolicy.log(.itemDeleted, category: .eventKit)
    }

    /// Opens the stored item in Calendar or Reminders. Looks up by identifier only — never scans the library.
    func openingURL(identifier: String, destination: CaptureDestination) throws -> URL {
        let trimmed = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw EventKitServiceError.missingIdentifier }

        switch destination {
        case .reminder:
            guard reminderAuthorization() == .fullAccess else { throw EventKitServiceError.notAuthorized }
        case .event:
            guard eventAuthorization() == .fullAccess else { throw EventKitServiceError.notAuthorized }
        }

        guard let item = store.calendarItem(withIdentifier: trimmed) else {
            throw EventKitServiceError.itemNotFound
        }

        LoggingPolicy.log(.itemOpened, category: .eventKit)
        if let event = item as? EKEvent, let start = event.startDate {
            return EventKitDeepLink.calendar(start: start)
        }
        if item is EKReminder {
            return EventKitDeepLink.reminders
        }
        throw EventKitServiceError.itemNotFound
    }
}

/// Public URL schemes for Apple’s Calendar and Reminders apps. Never embeds titles or identifiers.
enum EventKitDeepLink {
    static let reminders = URL(string: "x-apple-reminderkit://")!

    static func calendar(start: Date) -> URL {
        URL(string: "calshow:\(Int(start.timeIntervalSinceReferenceDate))")!
    }
}
