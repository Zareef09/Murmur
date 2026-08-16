import XCTest
@testable import Murmur

@MainActor
final class AudioSessionManagerTests: XCTestCase {
    func testRecordThenPlaybackDeactivatesFirst() throws {
        let hardware = FakeAudioSession()
        let manager = AudioSessionManager(hardware: hardware)
        try manager.enterRecordMode()
        XCTAssertEqual(manager.mode, .recording)
        try manager.enterPlaybackMode()
        XCTAssertEqual(manager.mode, .playing)
        XCTAssertEqual(hardware.calls, ["record", "deactivate", "playback"])
    }

    func testPlaybackThenRecordDeactivatesFirst() throws {
        let hardware = FakeAudioSession()
        let manager = AudioSessionManager(hardware: hardware)
        try manager.enterPlaybackMode()
        try manager.enterRecordMode()
        XCTAssertEqual(manager.mode, .recording)
        XCTAssertEqual(hardware.calls, ["playback", "deactivate", "record"])
    }

    func testDeactivateFromRecord() throws {
        let hardware = FakeAudioSession()
        let manager = AudioSessionManager(hardware: hardware)
        try manager.enterRecordMode()
        try manager.deactivate()
        XCTAssertEqual(manager.mode, .inactive)
        XCTAssertEqual(hardware.calls, ["record", "deactivate"])
    }
}

@MainActor
private final class FakeAudioSession: AudioSessionControlling {
    var calls: [String] = []

    func configureRecord() throws { calls.append("record") }
    func configurePlayback() throws { calls.append("playback") }
    func deactivate() throws { calls.append("deactivate") }
}
