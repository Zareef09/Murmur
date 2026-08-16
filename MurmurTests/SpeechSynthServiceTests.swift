import XCTest
@testable import Murmur

@MainActor
final class SpeechSynthServiceTests: XCTestCase {
    func testSpeakEntersPlaybackThenDeactivates() async throws {
        let hardware = SynthFakeAudioSession()
        let audio = AudioSessionManager(hardware: hardware)
        let utterer = FakeSpeechUtterer()
        let synth = SpeechSynthService(audio: audio, utterer: utterer)

        await synth.speak("When should this be?")

        XCTAssertEqual(utterer.spoken, ["When should this be?"])
        XCTAssertEqual(hardware.calls, ["playback", "deactivate"])
        XCTAssertEqual(audio.mode, .inactive)
    }

    func testSpeakLeavesRecordBeforePlayback() async throws {
        let hardware = SynthFakeAudioSession()
        let audio = AudioSessionManager(hardware: hardware)
        let utterer = FakeSpeechUtterer()
        let synth = SpeechSynthService(audio: audio, utterer: utterer)

        try audio.enterRecordMode()
        await synth.speak("What time?")

        XCTAssertEqual(hardware.calls, ["record", "deactivate", "playback", "deactivate"])
        XCTAssertEqual(utterer.spoken, ["What time?"])
    }

    func testEmptyTextDoesNotTouchAudio() async {
        let hardware = SynthFakeAudioSession()
        let audio = AudioSessionManager(hardware: hardware)
        let utterer = FakeSpeechUtterer()
        let synth = SpeechSynthService(audio: audio, utterer: utterer)

        await synth.speak("   ")

        XCTAssertTrue(utterer.spoken.isEmpty)
        XCTAssertTrue(hardware.calls.isEmpty)
        XCTAssertEqual(audio.mode, .inactive)
    }

    func testSynthLogMessageHasNoUtterance() {
        let message = LoggingPolicy.message(for: .speechSynth)
        XCTAssertEqual(message, "speech synth")
        XCTAssertFalse(message.contains("When"))
        XCTAssertFalse(LoggingPolicy.looksLikeBannedContent(message))
    }
}

@MainActor
private final class FakeSpeechUtterer: SpeechUttering {
    var spoken: [String] = []

    func speak(_ text: String) async {
        spoken.append(text)
    }

    func stop() {}
}

@MainActor
private final class SynthFakeAudioSession: AudioSessionControlling {
    var calls: [String] = []

    func configureRecord() throws { calls.append("record") }
    func configurePlayback() throws { calls.append("playback") }
    func deactivate() throws { calls.append("deactivate") }
}
