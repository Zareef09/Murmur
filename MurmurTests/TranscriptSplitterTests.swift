import XCTest
@testable import Murmur

final class TranscriptSplitterTests: XCTestCase {
    func testSplitsTheThreePartExample() {
        let segments = TranscriptSplitter.segments("Call mom at 5, go to the gym at 7, dinner at 8")
        XCTAssertEqual(segments.count, 3)
        XCTAssertTrue(segments[0].lowercased().contains("call mom"))
        XCTAssertTrue(segments[1].lowercased().contains("gym"))
        XCTAssertTrue(segments[2].lowercased().contains("dinner"))
    }

    func testSingleCaptureStaysWhole() {
        let segments = TranscriptSplitter.segments("remind me to call the dentist tomorrow at 3")
        XCTAssertEqual(segments.count, 1)
        XCTAssertFalse(TranscriptSplitter.isMultiple("remind me to call the dentist tomorrow at 3"))
    }

    /// "and" inside a guest list must not split the capture.
    func testAndBetweenNamesDoesNotSplit() {
        XCTAssertEqual(TranscriptSplitter.segments("dinner with Sam and Alex at 8").count, 1)
        XCTAssertEqual(TranscriptSplitter.segments("buy milk and eggs").count, 1)
    }

    /// "and" between two timed clauses is a real separator.
    func testAndBetweenTimedClausesSplits() {
        let segments = TranscriptSplitter.segments("dinner at 8 and gym at 9")
        XCTAssertEqual(segments.count, 2)
    }

    func testThenSeparates() {
        XCTAssertEqual(TranscriptSplitter.segments("call mom then walk the dog").count, 2)
    }

    func testEmptyAndWhitespace() {
        XCTAssertTrue(TranscriptSplitter.segments("").isEmpty)
        XCTAssertTrue(TranscriptSplitter.segments("   ").isEmpty)
    }

    /// Trailing punctuation must not produce an empty extra capture.
    func testTrailingSeparatorIsDropped() {
        let segments = TranscriptSplitter.segments("call mom at 5, gym at 7,")
        XCTAssertEqual(segments.count, 2)
    }
}
