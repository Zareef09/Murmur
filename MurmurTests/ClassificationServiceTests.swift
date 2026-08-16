import XCTest
@testable import Murmur

final class ClassificationServiceTests: XCTestCase {
    private let classify = ClassificationService()
    private let tomorrow = Date(timeIntervalSince1970: 1_800_086_400)

    func testNoDateTodoIsReminder() {
        let intent = classify.classify(ParsedIntent(rawTranscript: "call mom", taskText: "call mom"))
        XCTAssertEqual(intent.destination, .reminder)
        XCTAssertGreaterThanOrEqual(intent.confidence, 0.8)
        XCTAssertFalse(intent.needsClarification)
    }

    func testExplicitClockTimeIsEvent() {
        let intent = classify.classify(
            ParsedIntent(
                rawTranscript: "remind me to call mom tomorrow at 5",
                taskText: "call mom",
                date: tomorrow,
                hasExplicitTime: true
            )
        )
        XCTAssertEqual(intent.destination, .event)
        XCTAssertGreaterThanOrEqual(intent.confidence, 0.8)
        XCTAssertFalse(intent.needsClarification)
    }

    func testDateOnlyWithChosenDestinationIsNotGuessedAway() {
        let intent = classify.classify(
            ParsedIntent(
                rawTranscript: "buy groceries on Friday",
                taskText: "buy groceries",
                date: tomorrow,
                hasExplicitTime: false,
                destination: .reminder
            )
        )
        XCTAssertEqual(intent.destination, .reminder)
        XCTAssertGreaterThanOrEqual(intent.confidence, 0.8)
        XCTAssertFalse(intent.needsClarification)
    }

    func testDateOnlyWithoutKeywordAsksDestination() {
        let intent = classify.classify(
            ParsedIntent(
                rawTranscript: "buy groceries on Friday",
                taskText: "buy groceries",
                date: tomorrow,
                hasExplicitTime: false
            )
        )
        XCTAssertNil(intent.destination)
        XCTAssertTrue(intent.needsClarification)
        XCTAssertEqual(intent.clarificationKind, .destination)
        XCTAssertLessThan(intent.confidence, 0.5)
    }

    func testEventKeywordWithoutTimeAsksTime() {
        let intent = classify.classify(
            ParsedIntent(
                rawTranscript: "meeting tomorrow",
                taskText: "meeting",
                date: tomorrow,
                hasExplicitTime: false
            )
        )
        XCTAssertEqual(intent.destination, .event)
        XCTAssertTrue(intent.needsClarification)
        XCTAssertEqual(intent.clarificationKind, .time)
    }

    func testVagueLaterAsksDate() {
        let intent = classify.classify(
            ParsedIntent(rawTranscript: "call mom later", taskText: "call mom later")
        )
        XCTAssertTrue(intent.needsClarification)
        XCTAssertEqual(intent.clarificationKind, .date)
        XCTAssertLessThan(intent.confidence, 0.5)
    }

    func testEmptyTaskIsGarbled() {
        let intent = classify.classify(ParsedIntent(rawTranscript: "tomorrow", taskText: ""))
        XCTAssertTrue(intent.needsClarification)
        XCTAssertEqual(intent.clarificationKind, .garbled)
        XCTAssertNil(intent.destination)
    }

    func testTwoDatesStayDateClarification() {
        let intent = classify.classify(
            ParsedIntent(
                rawTranscript: "Friday or Saturday",
                taskText: "",
                needsClarification: true,
                clarificationKind: .date
            )
        )
        XCTAssertEqual(intent.clarificationKind, .date)
        XCTAssertTrue(intent.needsClarification)
    }
}
