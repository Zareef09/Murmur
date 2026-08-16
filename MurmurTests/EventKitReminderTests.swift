import EventKit
import XCTest
@testable import Murmur

final class ReminderDueTests: XCTestCase {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    func testNoDueDateMeansNoComponents() {
        XCTAssertNil(ReminderDue.components(due: nil, hasExplicitTime: false, calendar: calendar))
    }

    func testDateOnlyOmitsClockFields() {
        let due = Date(timeIntervalSince1970: 1_800_086_400)
        let comps = ReminderDue.components(due: due, hasExplicitTime: false, calendar: calendar)
        XCTAssertNotNil(comps?.year)
        XCTAssertNotNil(comps?.month)
        XCTAssertNotNil(comps?.day)
        XCTAssertNil(comps?.hour)
        XCTAssertNil(comps?.minute)
    }

    func testExplicitTimeKeepsHourAndMinute() {
        var parts = DateComponents()
        parts.year = 2026
        parts.month = 8
        parts.day = 16
        parts.hour = 17
        parts.minute = 30
        let due = calendar.date(from: parts)!
        let comps = ReminderDue.components(due: due, hasExplicitTime: true, calendar: calendar)
        XCTAssertEqual(comps?.hour, 17)
        XCTAssertEqual(comps?.minute, 30)
        XCTAssertEqual(comps?.day, 16)
    }
}

@MainActor
final class EventKitReminderAuthTests: XCTestCase {
    func testCreateReminderThrowsWhenNotAuthorized() async {
        let service = EventKitService(reminderAuthorization: { .denied })
        do {
            _ = try await service.createReminder(title: "Call mom", due: nil, hasExplicitTime: false)
            XCTFail("expected notAuthorized")
        } catch let error as EventKitServiceError {
            XCTAssertEqual(error, .notAuthorized)
            XCTAssertEqual(EventKitCopy.reminderFact(for: error), EventKitCopy.remindersAccessNeeded)
        } catch {
            XCTFail("unexpected \(error)")
        }
    }

    func testEmptyTitleDoesNotSave() async {
        let service = EventKitService(reminderAuthorization: { .fullAccess })
        do {
            _ = try await service.createReminder(title: "  ", due: nil, hasExplicitTime: false)
            XCTFail("expected emptyTitle")
        } catch let error as EventKitServiceError {
            XCTAssertEqual(error, .emptyTitle)
            XCTAssertFalse(EventKitCopy.reminderFact(for: error).localizedCaseInsensitiveContains("error"))
        } catch {
            XCTFail("unexpected \(error)")
        }
    }
}
