import Foundation

/// Ends listening ~1.5s after the last voice. Does not stop before the first voice.
struct SilenceWatch: Equatable, Sendable {
    static let duration: TimeInterval = 1.5

    private(set) var lastVoiceAt: Date?

    mutating func heardVoice(at date: Date) {
        lastVoiceAt = date
    }

    func shouldStop(now: Date) -> Bool {
        guard let lastVoiceAt else { return false }
        return now.timeIntervalSince(lastVoiceAt) >= Self.duration
    }
}

enum SpeechEnergy {
    /// RMS of a 16-bit-ish float buffer. Used only to detect voice, never stored.
    static func rms(samples: UnsafeBufferPointer<Float>) -> Float {
        guard !samples.isEmpty else { return 0 }
        var sum: Float = 0
        for sample in samples {
            sum += sample * sample
        }
        return sqrt(sum / Float(samples.count))
    }

    static let voiceFloor: Float = 0.015
    /// Conversational peak. Above this the well is fully open; Bloom still smooths.
    static let voicePeak: Float = 0.12

    /// 0…1 for the Light Well. Below the floor is silence (Bloom handles release).
    static func normalizedLevel(rms: Float) -> Float {
        guard rms > voiceFloor else { return 0 }
        let span = voicePeak - voiceFloor
        guard span > 0 else { return 1 }
        return min(1, max(0, (rms - voiceFloor) / span))
    }
}
