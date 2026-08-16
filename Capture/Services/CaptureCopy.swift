import Foundation

/// Capture home copy. Kit: first-run / idle / listening / thinking / success.
enum CaptureCopy {
    static let firstRunTitle = "Say what you need to remember."
    static let firstRunCaption = "Tap, then just say it"
    static let firstRunFootnote =
        "Murmur files it as a reminder or an event. You can always check before it saves."
    static let idleCaption = "Tap to speak"
    static let listeningCaption = "Listening"
    static let thinkingCaption = "One moment"
    static let successCaption = "Saved"
    static let listeningPlaceholder = "I'm listening…"
}

enum CaptureFirstRun {
    static let defaultsKey = "murmur.capture.firstRunCompleted"
}
