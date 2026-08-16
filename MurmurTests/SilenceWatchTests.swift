import XCTest
@testable import Murmur

final class SilenceWatchTests: XCTestCase {
    func testDoesNotStopBeforeFirstVoice() {
        let watch = SilenceWatch()
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        XCTAssertFalse(watch.shouldStop(now: now.addingTimeInterval(3)))
    }

    func testStopsAfter1500msOfSilence() {
        var watch = SilenceWatch()
        let voiced = Date(timeIntervalSince1970: 1_800_000_000)
        watch.heardVoice(at: voiced)
        XCTAssertFalse(watch.shouldStop(now: voiced.addingTimeInterval(1.49)))
        XCTAssertTrue(watch.shouldStop(now: voiced.addingTimeInterval(1.5)))
    }

    func testNormalizedLevelIsZeroAtOrBelowFloor() {
        XCTAssertEqual(SpeechEnergy.normalizedLevel(rms: 0), 0)
        XCTAssertEqual(SpeechEnergy.normalizedLevel(rms: SpeechEnergy.voiceFloor), 0)
    }

    func testNormalizedLevelOpensBetweenFloorAndPeak() {
        let mid = SpeechEnergy.voiceFloor + (SpeechEnergy.voicePeak - SpeechEnergy.voiceFloor) / 2
        let level = SpeechEnergy.normalizedLevel(rms: mid)
        XCTAssertEqual(level, 0.5, accuracy: 0.001)
        XCTAssertEqual(SpeechEnergy.normalizedLevel(rms: SpeechEnergy.voicePeak), 1)
        XCTAssertEqual(SpeechEnergy.normalizedLevel(rms: 1), 1)
    }
}
