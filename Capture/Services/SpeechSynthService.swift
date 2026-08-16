import AVFoundation
import Foundation

@MainActor
protocol SpeechSynthServicing: AnyObject {
    func speak(_ text: String) async
    func stop()
}

@MainActor
protocol SpeechUttering: AnyObject {
    func speak(_ text: String) async
    func stop()
}

/// On-device `AVSpeechSynthesizer`. Playback mode only; never logs the utterance.
@MainActor
final class SpeechSynthService: SpeechSynthServicing {
    private let audio: AudioSessionManaging
    private let utterer: SpeechUttering

    init(
        audio: AudioSessionManaging = AudioSessionManager(),
        utterer: SpeechUttering = SystemSpeechUtterer()
    ) {
        self.audio = audio
        self.utterer = utterer
    }

    func speak(_ text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        stop()
        do {
            try audio.enterPlaybackMode()
        } catch {
            return
        }
        LoggingPolicy.log(.speechSynth, category: .speech)
        await utterer.speak(trimmed)
        try? audio.deactivate()
    }

    func stop() {
        utterer.stop()
        if audio.mode == .playing {
            try? audio.deactivate()
        }
    }
}

@MainActor
final class SystemSpeechUtterer: NSObject, SpeechUttering {
    private let synthesizer = AVSpeechSynthesizer()
    private var continuation: CheckedContinuation<Void, Never>?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String) async {
        stopSpeaking()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: Locale.autoupdatingCurrent.identifier)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.92
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            synthesizer.speak(utterance)
        }
    }

    func stop() {
        stopSpeaking()
    }

    private func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        resumeIfNeeded()
    }

    private func resumeIfNeeded() {
        continuation?.resume()
        continuation = nil
    }
}

extension SystemSpeechUtterer: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        Task { @MainActor in
            self.resumeIfNeeded()
        }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        Task { @MainActor in
            self.resumeIfNeeded()
        }
    }
}
