@MainActor
protocol AudioSessionManaging: AnyObject {
    func enterRecordMode() throws
    func enterPlaybackMode() throws
    func deactivate() throws
}

@MainActor
final class AudioSessionManager: AudioSessionManaging {
    func enterRecordMode() throws {}

    func enterPlaybackMode() throws {}

    func deactivate() throws {}
}
