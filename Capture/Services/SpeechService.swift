@MainActor
protocol SpeechServicing: AnyObject {
    func start() async throws
    func stop()
}

@MainActor
final class SpeechService: SpeechServicing {
    func start() async throws {}

    func stop() {}
}
