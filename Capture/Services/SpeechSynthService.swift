@MainActor
protocol SpeechSynthServicing: AnyObject {
    func speak(_ text: String) async
}

@MainActor
final class SpeechSynthService: SpeechSynthServicing {
    func speak(_ text: String) async {}
}
