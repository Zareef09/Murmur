import XCTest
@testable import Murmur

final class BareClockTimeTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    private func at(_ hour: Int, _ minute: Int = 0, dayOffset: Int = 0) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 8
        components.day = 16 + dayOffset
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components)!
    }

    /// Said in the morning, "at 8" means tonight, not eight days from now.
    func testEveningReadingWhenMorningHasPassed() {
        let now = at(9)
        let match = BareClockTime.firstMatch(in: "dinner at 8", now: now, calendar: calendar)
        XCTAssertEqual(match?.date, at(20))
    }

    /// Said at night, the same words mean tomorrow morning.
    func testRollsToTomorrowWhenBothReadingsHavePassed() {
        let now = at(21)
        let match = BareClockTime.firstMatch(in: "gym at 8", now: now, calendar: calendar)
        XCTAssertEqual(match?.date, at(8, dayOffset: 1))
    }

    func testPicksTheSoonestFutureReading() {
        let now = at(9)
        let match = BareClockTime.firstMatch(in: "call mom at 5", now: now, calendar: calendar)
        XCTAssertEqual(match?.date, at(17))
    }

    func testMinutesAreKept() {
        let match = BareClockTime.firstMatch(in: "standup at 9:45", now: at(6), calendar: calendar)
        XCTAssertEqual(match?.date, at(9, 45))
    }

    /// The detector already handles these, so the fallback must stay out of the way.
    func testIgnoresTimesThatCarryAMeridiem() {
        XCTAssertNil(BareClockTime.firstMatch(in: "dinner at 8pm", now: at(9), calendar: calendar))
        XCTAssertNil(BareClockTime.firstMatch(in: "dinner at 8 p.m.", now: at(9), calendar: calendar))
        XCTAssertNil(BareClockTime.firstMatch(in: "call at 5 o'clock", now: at(9), calendar: calendar))
    }

    func testIgnoresTextWithNoBareHour() {
        XCTAssertNil(BareClockTime.firstMatch(in: "buy milk", now: at(9), calendar: calendar))
        XCTAssertNil(BareClockTime.firstMatch(in: "at the gym", now: at(9), calendar: calendar))
    }

    func testParserProducesAnExplicitTimeForABareHour() {
        let intent = ParsingService().parse("dinner at 8")
        XCTAssertNotNil(intent.date)
        XCTAssertTrue(intent.hasExplicitTime)
        XCTAssertEqual(intent.taskText, "dinner")
    }

    /// A bare hour is a real time, so classification sends it to the calendar.
    func testBareHourClassifiesAsEvent() {
        let intent = ClassificationService().classify(ParsingService().parse("dinner at 8"))
        XCTAssertEqual(intent.destination, .event)
    }
}
