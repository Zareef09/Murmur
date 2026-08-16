import XCTest
@testable import Murmur

final class ClarifyCopyTests: XCTestCase {
    func testSpecTemplates() {
        XCTAssertEqual(ClarifyCopy.when, "When should this be?")
        XCTAssertEqual(ClarifyCopy.time, "What time?")
        XCTAssertEqual(ClarifyCopy.destination, "Should this go to Reminders, or Calendar?")
        XCTAssertEqual(ClarifyCopy.garbled, "Say that again, or tap to type it.")
        XCTAssertEqual(ClarifyCopy.quietHint, "Somewhere quiet? Tap an answer instead.")
    }

    func testTwoWeekdaysUseTheSpecWhichDayShape() {
        let intent = ParsedIntent(
            rawTranscript: "meet Friday or Saturday",
            taskText: "meet",
            needsClarification: true,
            clarificationKind: .date
        )
        XCTAssertEqual(
            ClarifyCopy.question(for: intent),
            "Which day did you mean — Friday or Saturday?"
        )
    }

    func testVagueDateAsksWhen() {
        let intent = ParsedIntent(
            rawTranscript: "call mom later",
            taskText: "call mom",
            needsClarification: true,
            clarificationKind: .date
        )
        XCTAssertEqual(ClarifyCopy.question(for: intent), ClarifyCopy.when)
    }

    func testTimeAndDestinationAndGarbled() {
        XCTAssertEqual(
            ClarifyCopy.question(kind: .time, transcript: "lunch with Sam"),
            ClarifyCopy.time
        )
        XCTAssertEqual(
            ClarifyCopy.question(kind: .destination, transcript: "buy milk on Friday"),
            ClarifyCopy.destination
        )
        XCTAssertEqual(
            ClarifyCopy.question(kind: .garbled, transcript: ""),
            ClarifyCopy.garbled
        )
    }

    func testTapChoicesForDestinationAndTwoWeekdays() {
        let dest = ParsedIntent(
            rawTranscript: "buy milk on Friday",
            taskText: "buy milk",
            needsClarification: true,
            clarificationKind: .destination
        )
        XCTAssertEqual(ClarifyCopy.tapChoices(for: dest), ["Reminders", "Calendar"])

        let days = ParsedIntent(
            rawTranscript: "meet Friday or Saturday",
            taskText: "meet",
            needsClarification: true,
            clarificationKind: .date
        )
        XCTAssertEqual(ClarifyCopy.tapChoices(for: days), ["Friday", "Saturday"])
    }
}
