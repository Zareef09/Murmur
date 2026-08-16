import AppIntents

/// Opens Murmur and starts listening when a session exists. Sign-in first if signed out.
struct QuickCaptureIntent: AppIntent {
    static let title: LocalizedStringResource = "Quick capture"
    static let description = IntentDescription("Open Murmur and start listening.")
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        QuickCaptureFlag.arm()
        return .result()
    }
}
