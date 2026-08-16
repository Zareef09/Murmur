import XCTest
@testable import Murmur

final class ParsingServiceCleanupTests: XCTestCase {
    private let parser = ParsingService()

    func testSpecExampleCallMom() {
        let intent = parser.parse("remind me to call mom tomorrow at 5")
        XCTAssertEqual(intent.taskText.lowercased(), "call mom")
    }

    func testRememberToIsStripped() {
        let intent = parser.parse("remember to buy milk")
        XCTAssertEqual(intent.taskText.lowercased(), "buy milk")
        XCTAssertNil(intent.date)
    }

    func testDateAtTheEndLeavesTheTask() {
        let intent = parser.parse("call mom tomorrow")
        XCTAssertEqual(intent.taskText.lowercased(), "call mom")
        XCTAssertNotNil(intent.date)
        XCTAssertFalse(intent.hasExplicitTime)
    }

    func testNoDateKeepsTheTask() {
        XCTAssertEqual(parser.parse("call mom").taskText.lowercased(), "call mom")
    }

    func testDateOnlyIsGarbledNotAGuessedTitle() {
        let intent = parser.parse("next Friday")
        XCTAssertTrue(intent.taskText.isEmpty)
        XCTAssertTrue(intent.needsClarification)
        XCTAssertEqual(intent.clarificationKind, .garbled)
    }
}
