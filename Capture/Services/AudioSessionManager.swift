import AVFoundation
import Foundation

enum AudioSessionMode: String, Equatable, Sendable {
    case inactive
    case recording
    case playing
}

@MainActor
protocol AudioSessionControlling: AnyObject {
    func configureRecord() throws
    func configurePlayback() throws
    func deactivate() throws
}

@MainActor
final class SystemAudioSession: AudioSessionControlling {
    func configureRecord() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: [.duckOthers])
        try session.setActive(true)
    }

    func configurePlayback() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try session.setActive(true)
    }

    func deactivate() throws {
        try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    }
}

@MainActor
protocol AudioSessionManaging: AnyObject {
    var mode: AudioSessionMode { get }
    func enterRecordMode() throws
    func enterPlaybackMode() throws
    func deactivate() throws
}

/// The only gate for mic vs speech. Recording or speaking, never both.
@MainActor
final class AudioSessionManager: AudioSessionManaging {
    private let hardware: AudioSessionControlling
    private(set) var mode: AudioSessionMode = .inactive

    init(hardware: AudioSessionControlling = SystemAudioSession()) {
        self.hardware = hardware
    }

    func enterRecordMode() throws {
        if mode == .recording { return }
        if mode == .playing {
            try hardware.deactivate()
            mode = .inactive
        }
        try hardware.configureRecord()
        mode = .recording
        LoggingPolicy.log(.audioMode(.recording), category: .speech)
    }

    func enterPlaybackMode() throws {
        if mode == .playing { return }
        if mode == .recording {
            try hardware.deactivate()
            mode = .inactive
        }
        try hardware.configurePlayback()
        mode = .playing
        LoggingPolicy.log(.audioMode(.playing), category: .speech)
    }

    func deactivate() throws {
        if mode == .inactive { return }
        try hardware.deactivate()
        mode = .inactive
        LoggingPolicy.log(.audioMode(.inactive), category: .speech)
    }
}
