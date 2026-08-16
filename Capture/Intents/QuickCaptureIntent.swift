import AppIntents

struct QuickCaptureIntent: AppIntent {
    static let title: LocalizedStringResource = "Quick capture"
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}
