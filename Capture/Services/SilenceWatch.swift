import Foundation

/// Ends listening ~1.5s after the last voice. Does not stop before the first voice.
///
/// A turn that is building a list gets a longer pause: thinking of the next item takes longer than
/// the gap between words, and cutting someone off mid-list is the worst thing this can do.
struct SilenceWatch: Equatable, Sendable {
    static let duration: TimeInterval = 1.5
    static let listDuration: TimeInterval = 4

    private(set) var lastVoiceAt: Date?
    private(set) var window: TimeInterval = duration

    var isWaitingForMore: Bool {
        window > Self.duration
    }

    mutating func heardVoice(at date: Date) {
        lastVoiceAt = date
    }

    /// One way only. Once a turn looks like a list it keeps the longer pause to the end.
    mutating func allowLongerPause() {
        window = Self.listDuration
    }

    func shouldStop(now: Date) -> Bool {
        guard let lastVoiceAt else { return false }
        return now.timeIntervalSince(lastVoiceAt) >= window
    }
}

/// Words that say "there is more coming". Used to hold the mic open, never to split text.
enum ContinuationPhrase {
    static let words = ["and", "then", "also", "plus", "next", "after that", "as well as"]

    /// True once the turn so far reads as a list in progress.
    static func suggestsMore(_ text: String) -> Bool {
        let folded = text.lowercased()
        if folded.contains(",") { return true }
        return words.contains { word in
            folded.range(of: #"\b\#(word)\b"#, options: .regularExpression) != nil
        }
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
