import Foundation

/// User-facing speech facts. Sentence case, no “error” / “failed” / “invalid” / “!”.
enum SpeechCopy {
    static let unsupportedLocale = "On-device speech isn't available for this language."
    static let nothingCaptured = "Nothing captured."
    static let notAllowedYet = "Not allowed yet"

    static func fact(for error: SpeechServiceError) -> String? {
        switch error {
        case .onDeviceUnavailable, .recognizerUnavailable:
            unsupportedLocale
        case .notAuthorized:
            notAllowedYet
        }
    }
}
