import Foundation
import Observation

@MainActor
@Observable
final class CaptureViewModel {
    var state: CaptureState = .signedOut
    /// Last-known confirm-before-save. Default on. Cache first; remote is best-effort.
    var alwaysConfirm: Bool = SettingsRepository.defaultAlwaysConfirm

    private let settingsSync: SettingsSyncing

    init(settingsSync: SettingsSyncing = SettingsSyncService()) {
        self.settingsSync = settingsSync
    }

    /// Session 21: capture states are unreachable without a session.
    /// Session 22: load cached `always_confirm` synchronously so capture never waits on the network.
    func applySession(isSignedIn: Bool) {
        if isSignedIn {
            if state == .signedOut {
                state = .idle
            }
            settingsSync.loadCached()
            alwaysConfirm = settingsSync.alwaysConfirm
        } else {
            settingsSync.cancelPendingUpsert()
            state = .signedOut
            alwaysConfirm = SettingsRepository.defaultAlwaysConfirm
        }
    }

    /// Background fetch. Does not block capture. Failures leave the cache as-is.
    func refreshSettingsFromRemote() async {
        guard canCapture else { return }
        do {
            try await settingsSync.fetchRemote()
            alwaysConfirm = settingsSync.alwaysConfirm
        } catch {
            alwaysConfirm = settingsSync.alwaysConfirm
        }
    }

    func setAlwaysConfirm(_ value: Bool) {
        settingsSync.setAlwaysConfirm(value)
        alwaysConfirm = settingsSync.alwaysConfirm
    }

    /// Listening and later capture actions must no-op while signed out.
    var canCapture: Bool {
        state != .signedOut
    }

    #if DEBUG
    func debugSetState(_ state: CaptureState) {
        self.state = state
    }
    #endif
}
