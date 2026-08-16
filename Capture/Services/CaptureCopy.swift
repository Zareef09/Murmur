import Foundation

/// Capture home copy. Kit: first-run / idle / listening / thinking / success.
enum CaptureCopy {
    static let firstRunTitle = "Say what you need to remember."
    static let firstRunCaption = "Tap, then just say it"
    static let firstRunFootnote =
        "Murmur files it as a reminder or an event. You can always check before it saves."
    static let idleCaption = "Tap to speak"
    /// Listening says what to do next, because the well already shows that it is listening.
    static let listeningCaption = "Tap again when you're done"
    static let thinkingCaption = "One moment"
    static let successCaption = "Saved"
    static let listeningPlaceholder = "Say it when you're ready"

    /// Teaches the joining words that hold several things in one breath.
    static let multiHint = "Say one thing, or join a few with and or then"
    /// Shown once joining words are heard, so the longer pause does not read as a stall.
    static let listeningMoreHint = "Take your time, Murmur is waiting for the rest"

    static var allLines: [String] {
        [
            firstRunTitle, firstRunCaption, firstRunFootnote, idleCaption, listeningCaption,
            thinkingCaption, successCaption, listeningPlaceholder, multiHint, listeningMoreHint
        ]
    }
}

enum CaptureFirstRun {
    static let defaultsKey = "murmur.capture.firstRunCompleted"
}
