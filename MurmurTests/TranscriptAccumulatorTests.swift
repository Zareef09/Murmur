import XCTest
@testable import Murmur

final class TranscriptAccumulatorTests: XCTestCase {
    /// The reported bug: a pause after "then" makes Speech finalise twice, and assigning the second
    /// result dropped the first. Both halves must survive.
    func testKeepsEverySegmentOfATurn() {
        var accumulator = TranscriptAccumulator()
        accumulator.append("gym at 7pm")
        accumulator.append("then dinner at 9pm")
        XCTAssertEqual(accumulator.text, "gym at 7pm then dinner at 9pm")
    }

    func testSplitTurnStillReadsAsMultipleCaptures() {
        var accumulator = TranscriptAccumulator()
        accumulator.append("gym at 7pm")
        accumulator.append("then dinner at 9pm")
        XCTAssertEqual(TranscriptSplitter.segments(accumulator.text).count, 2)
    }

    func testBlankSegmentsAreIgnored() {
        var accumulator = TranscriptAccumulator()
        accumulator.append("   ")
        accumulator.append("")
        XCTAssertTrue(accumulator.isEmpty)
        XCTAssertEqual(accumulator.text, "")
    }

    /// Tap-to-stop appends the trailing partial, which may repeat the final already recorded.
    func testRepeatedSegmentIsNotDoubled() {
        var accumulator = TranscriptAccumulator()
        accumulator.append("call mom")
        accumulator.append("call mom")
        XCTAssertEqual(accumulator.text, "call mom")
    }

    func testSegmentsAreTrimmed() {
        var accumulator = TranscriptAccumulator()
        accumulator.append("  gym at 7pm  ")
        accumulator.append(" then dinner ")
        XCTAssertEqual(accumulator.text, "gym at 7pm then dinner")
    }

    func testResetClearsTheTurn() {
        var accumulator = TranscriptAccumulator()
        accumulator.append("gym at 7pm")
        accumulator.reset()
        XCTAssertTrue(accumulator.isEmpty)
        XCTAssertEqual(accumulator.text, "")
    }
}
