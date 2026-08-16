import XCTest
@testable import Murmur

final class ConfirmationWhenFormatTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.locale = Locale(identifier: "en_US")
        return calendar
    }

    private var now: Date {
        calendar.date(from: DateComponents(year: 2026, month: 8, day: 16, hour: 12))!
    }

    func testNilDateIsEmptyForPlaceholder() {
        XCTAssertEqual(
            ConfirmationWhenFormat.display(date: nil, hasExplicitTime: false, now: now, calendar: calendar),
            ""
        )
        XCTAssertEqual(ConfirmationCopy.noDate, "No date")
    }

    func testTodayAndTomorrowWithoutClock() {
        XCTAssertEqual(
            ConfirmationWhenFormat.display(date: now, hasExplicitTime: false, now: now, calendar: calendar),
            "Today"
        )
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        XCTAssertEqual(
            ConfirmationWhenFormat.display(date: tomorrow, hasExplicitTime: false, now: now, calendar: calendar),
            "Tomorrow"
        )
    }

    func testTomorrowWithClockIncludesTime() {
        let when = calendar.date(from: DateComponents(year: 2026, month: 8, day: 17, hour: 17))!
        let text = ConfirmationWhenFormat.display(
            date: when,
            hasExplicitTime: true,
            now: now,
            calendar: calendar
        )
        let time = when.formatted(
            Date.FormatStyle(date: .omitted, time: .shortened).locale(calendar.locale!)
        )
        XCTAssertEqual(text, "Tomorrow, \(time)")
    }

    func testCopyMatchesKit() {
        XCTAssertEqual(ConfirmationCopy.headline, "Does this look right?")
        XCTAssertEqual(ConfirmationCopy.fixing, "Fix it up")
        XCTAssertEqual(ConfirmationCopy.hint, "Tap anything to change it.")
        XCTAssertEqual(ConfirmationCopy.saveTitle(for: .reminder), "Save reminder")
        XCTAssertEqual(ConfirmationCopy.saveTitle(for: .event), "Save event")
        XCTAssertEqual(ConfirmationCopy.destinationValue(.reminder), "Reminders")
        XCTAssertEqual(ConfirmationCopy.destinationValue(.event), "Calendar")
        XCTAssertEqual(ConfirmationCopy.includeTime, "Include time")
        XCTAssertEqual(ConfirmationCopy.dateOnly, "Date only")
    }
}
