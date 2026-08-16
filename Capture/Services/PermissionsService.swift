import AVFoundation
import EventKit
import Foundation
import Observation
import Speech
import UIKit

enum PermissionKind: String, CaseIterable, Sendable {
    case microphone
    case speech
    case reminders
    case calendar
}

enum PermissionAccess: String, Sendable {
    case granted
    case needed
}

@MainActor
protocol PermissionsServicing: AnyObject {
    var microphone: PermissionAccess { get }
    var speech: PermissionAccess { get }
    var reminders: PermissionAccess { get }
    var calendar: PermissionAccess { get }
    var allGranted: Bool { get }
    func refresh()
    func requestAll() async
    func request(_ kind: PermissionKind) async
    func openSystemSettings()
}

/// Speech, mic, Reminders, Calendar. Does not enumerate EventKit libraries.
@MainActor
@Observable
final class PermissionsService: PermissionsServicing {
    private let store = EKEventStore()

    private(set) var microphone: PermissionAccess = .needed
    private(set) var speech: PermissionAccess = .needed
    private(set) var reminders: PermissionAccess = .needed
    private(set) var calendar: PermissionAccess = .needed

    var allGranted: Bool {
        microphone == .granted
            && speech == .granted
            && reminders == .granted
            && calendar == .granted
    }

    init() {
        refresh()
    }

    func refresh() {
        microphone = Self.microphoneAccess(AVAudioApplication.shared.recordPermission)
        speech = Self.speechAccess(SFSpeechRecognizer.authorizationStatus())
        reminders = Self.eventKitAccess(EKEventStore.authorizationStatus(for: .reminder))
        calendar = Self.eventKitAccess(EKEventStore.authorizationStatus(for: .event))
    }

    func requestAll() async {
        await request(.microphone)
        await request(.speech)
        await request(.reminders)
        await request(.calendar)
    }

    func request(_ kind: PermissionKind) async {
        guard hasUsageDescription(for: kind) else {
            refresh()
            log(kind)
            return
        }
        switch kind {
        case .microphone:
            _ = await AVAudioApplication.requestRecordPermission()
        case .speech:
            await requestSpeech()
        case .reminders:
            _ = try? await store.requestFullAccessToReminders()
        case .calendar:
            _ = try? await store.requestFullAccessToEvents()
        }
        refresh()
        log(kind)
    }

    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    nonisolated static func microphoneAccess(_ permission: AVAudioApplication.recordPermission) -> PermissionAccess {
        permission == .granted ? .granted : .needed
    }

    nonisolated static func speechAccess(_ status: SFSpeechRecognizerAuthorizationStatus) -> PermissionAccess {
        status == .authorized ? .granted : .needed
    }

    nonisolated static func eventKitAccess(_ status: EKAuthorizationStatus) -> PermissionAccess {
        status == .fullAccess ? .granted : .needed
    }

    /// `nonisolated` on purpose: `requestAuthorization` hands back a non-`Sendable` closure, which would
    /// inherit `@MainActor` here and trap when Speech calls it on a background queue.
    private nonisolated func requestSpeech() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            SFSpeechRecognizer.requestAuthorization { _ in
                continuation.resume()
            }
        }
    }

    private func hasUsageDescription(for kind: PermissionKind) -> Bool {
        let key: String
        switch kind {
        case .microphone: key = "NSMicrophoneUsageDescription"
        case .speech: key = "NSSpeechRecognitionUsageDescription"
        case .reminders: key = "NSRemindersFullAccessUsageDescription"
        case .calendar: key = "NSCalendarsFullAccessUsageDescription"
        }
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            return false
        }
        return !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func log(_ kind: PermissionKind) {
        let access: PermissionAccess
        switch kind {
        case .microphone: access = microphone
        case .speech: access = speech
        case .reminders: access = reminders
        case .calendar: access = calendar
        }
        LoggingPolicy.log(.permission(kind, access), category: .permissions)
    }
}
