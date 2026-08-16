import XCTest
@testable import Murmur

final class ClockTimePhraseTests: XCTestCase {
    func testClockTimeIsAboutTheSubstringNotTheDateObject() {
        XCTAssertFalse(ClockTimePhrase.containsClockTime("tomorrow"))
        XCTAssertFalse(ClockTimePhrase.containsClockTime("Friday"))
        XCTAssertFalse(ClockTimePhrase.containsClockTime("next week"))
        XCTAssertTrue(ClockTimePhrase.containsClockTime("tomorrow at 5"))
        XCTAssertTrue(ClockTimePhrase.containsClockTime("at 5"))
        XCTAssertTrue(ClockTimePhrase.containsClockTime("5pm"))
        XCTAssertTrue(ClockTimePhrase.containsClockTime("2-3pm"))
        XCTAssertTrue(ClockTimePhrase.containsClockTime("noon"))
        XCTAssertTrue(ClockTimePhrase.containsClockTime("midnight"))
        XCTAssertTrue(ClockTimePhrase.containsClockTime("5 o'clock"))
        XCTAssertTrue(ClockTimePhrase.containsClockTime("17:00"))
    }
}

final class ParsingServiceDateTests: XCTestCase {
    private let parser = ParsingService()

    func testNoDateLeavesDateNil() {
        let intent = parser.parse("call mom")
        XCTAssertEqual(intent.rawTranscript, "call mom")
        XCTAssertNil(intent.date)
        XCTAssertFalse(intent.hasExplicitTime)
        XCTAssertNil(intent.durationMinutes)
        XCTAssertFalse(intent.needsClarification)
    }

    func testTomorrowHasADateWithoutClockTime() {
        let intent = parser.parse("call mom tomorrow")
        XCTAssertNotNil(intent.date)
        XCTAssertFalse(intent.hasExplicitTime)
        XCTAssertNil(intent.durationMinutes)
    }

    func testTomorrowAtFiveHasExplicitTime() {
        let intent = parser.parse("remind me to call mom tomorrow at 5")
        XCTAssertNotNil(intent.date)
        XCTAssertTrue(intent.hasExplicitTime)
    }

    func testFridayRangeCanCarryDuration() {
        let intent = parser.parse("Friday 2-3pm")
        XCTAssertTrue(intent.hasExplicitTime)
        if let minutes = intent.durationMinutes {
            XCTAssertEqual(minutes, 60)
        }
    }

    func testNextFridayHasADateWithoutClockTime() {
        let intent = parser.parse("next Friday")
        XCTAssertNotNil(intent.date)
        XCTAssertFalse(intent.hasExplicitTime)
    }

    func testNextWeekIsNotClockTime() {
        let intent = parser.parse("next week")
        XCTAssertFalse(intent.hasExplicitTime)
        XCTAssertNil(intent.durationMinutes)
    }

    func testTwoDatesAskWhichDay() {
        let intent = parser.parse("Friday or Saturday")
        XCTAssertTrue(intent.needsClarification)
        XCTAssertEqual(intent.clarificationKind, .date)
    }

    func testTaskTextDropsDateAndRemindFrame() {
        let intent = parser.parse("remind me to call mom tomorrow at 5")
        XCTAssertEqual(intent.taskText.lowercased(), "call mom")
        XCTAssertTrue(intent.hasExplicitTime)
        XCTAssertNotNil(intent.date)
    }
}
