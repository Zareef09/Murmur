import XCTest
@testable import Murmur

final class ConfirmationWhenEditTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private var now: Date {
        calendar.date(from: DateComponents(year: 2026, month: 8, day: 16, hour: 15, minute: 30))!
    }

    func testOpeningNilReminderIsTodayDateOnly() {
        let opened = ConfirmationWhenEdit.opening(
            date: nil,
            hasExplicitTime: false,
            destination: .reminder,
            now: now,
            calendar: calendar
        )
        XCTAssertEqual(opened.date, calendar.startOfDay(for: now))
        XCTAssertFalse(opened.hasExplicitTime)
    }

    func testOpeningNilEventUsesNowWithClock() {
        let opened = ConfirmationWhenEdit.opening(
            date: nil,
            hasExplicitTime: false,
            destination: .event,
            now: now,
            calendar: calendar
        )
        XCTAssertEqual(opened.date, now)
        XCTAssertTrue(opened.hasExplicitTime)
    }

    func testOpeningDateOnlyEventAddsClock() {
        let friday = calendar.startOfDay(
            for: calendar.date(from: DateComponents(year: 2026, month: 8, day: 21))!
        )
        let opened = ConfirmationWhenEdit.opening(
            date: friday,
            hasExplicitTime: false,
            destination: .event,
            now: now,
            calendar: calendar
        )
        XCTAssertTrue(opened.hasExplicitTime)
        XCTAssertEqual(calendar.component(.day, from: opened.date), 21)
        XCTAssertEqual(calendar.component(.hour, from: opened.date), 15)
        XCTAssertEqual(calendar.component(.minute, from: opened.date), 30)
    }

    func testStrippingClockKeepsTheDay() {
        let stripped = ConfirmationWhenEdit.strippingClock(now, calendar: calendar)
        XCTAssertEqual(stripped, calendar.startOfDay(for: now))
    }
}
