import XCTest
@testable import Murmur

final class MurmurMotionTests: XCTestCase {
    func testStoryboardBeats() {
        XCTAssertEqual(MurmurMotion.undoWindow, 5)
        XCTAssertEqual(MurmurMotion.coreTapDip, 0.96, accuracy: 0.0001)
        XCTAssertEqual(MurmurMotion.confirmScale, 0.985, accuracy: 0.0001)
        XCTAssertEqual(MurmurMotion.confirmDim, 0.08, accuracy: 0.0001)
        XCTAssertEqual(MurmurMotion.sheetRise, 40)
        XCTAssertEqual(MurmurMotion.transcriptRise, 8)
        XCTAssertEqual(MurmurMotion.fieldStagger, 0.040, accuracy: 0.0001)
        XCTAssertEqual(MurmurMotion.checkDelay, 0.120, accuracy: 0.0001)
        XCTAssertEqual(MurmurMotion.sheetExit, 0.300, accuracy: 0.0001)
    }

    func testReduceMotionCollapsesTimedMotionNotPressOrUndo() {
        XCTAssertEqual(MurmurMotion.seconds(.instant, reduceMotion: true), 0.120)
        XCTAssertEqual(MurmurMotion.seconds(.quick, reduceMotion: true), 0.001)
        XCTAssertEqual(MurmurMotion.seconds(.normal, reduceMotion: true), 0.001)
        XCTAssertEqual(MurmurMotion.seconds(.slow, reduceMotion: true), 0.001)
        XCTAssertEqual(MurmurMotion.seconds(.breath, reduceMotion: true), 0.001)
        XCTAssertEqual(MurmurMotion.seconds(.slow, reduceMotion: false), 0.620)
        XCTAssertEqual(MurmurMotion.seconds(.normal, reduceMotion: false), 0.380)
        XCTAssertEqual(MurmurMotion.undoWindow, 5)
    }
}
