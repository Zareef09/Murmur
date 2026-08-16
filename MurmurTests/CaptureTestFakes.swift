import SwiftData
import XCTest
@testable import Murmur

@MainActor
final class FakeSpeechService: SpeechServicing {
    var isOnDeviceAvailable = true
    var committedText = ""
    var partialText = ""
    var onTranscriptChange: (() -> Void)?
    var onTurnEnded: (() -> Void)?
    var onLevelChange: ((Float) -> Void)?
    var startCount = 0

    func start() async throws {
        startCount += 1
    }

    func stop() {}
}

@MainActor
final class FakePermissionsService: PermissionsServicing {
    var microphone: PermissionAccess = .granted
    var speech: PermissionAccess = .granted
    var reminders: PermissionAccess = .granted
    var calendar: PermissionAccess = .granted
    var allGranted: Bool {
        microphone == .granted && speech == .granted && reminders == .granted && calendar == .granted
    }

    func refresh() {}
    func requestAll() async {}
    func request(_ kind: PermissionKind) async {}
    func openSystemSettings() {}
}

@MainActor
final class FakeEventKitService: EventKitServicing {
    var reminderTitles: [String] = []
    var reminderDues: [(Date?, Bool)] = []
    var eventTitles: [String] = []
    var eventStarts: [Date] = []
    var createError: EventKitServiceError?
    var openedIdentifier: String?
    var openingURLResult = EventKitDeepLink.reminders
    var deletedIdentifiers: [String] = []
    var deleteError: EventKitServiceError?

    func createReminder(title: String, due: Date?, hasExplicitTime: Bool) async throws -> String {
        if let createError { throw createError }
        reminderTitles.append(title)
        reminderDues.append((due, hasExplicitTime))
        return "stored-reminder"
    }

    func createEvent(title: String, start: Date, durationMinutes: Int?) async throws -> String {
        if let createError { throw createError }
        eventTitles.append(title)
        eventStarts.append(start)
        return "stored-event"
    }

    func deleteItem(identifier: String) async throws {
        if let deleteError { throw deleteError }
        deletedIdentifiers.append(identifier)
    }

    func openingURL(identifier: String, destination: CaptureDestination) throws -> URL {
        if let createError { throw createError }
        openedIdentifier = identifier
        return openingURLResult
    }
}

@MainActor
final class FakeSettingsSync: SettingsSyncing {
    var alwaysConfirm: Bool = SettingsRepository.defaultAlwaysConfirm
    var setCount = 0

    func loadCached() {}
    func fetchRemote() async throws {}
    func setAlwaysConfirm(_ value: Bool) {
        alwaysConfirm = value
        setCount += 1
    }
    func cancelPendingUpsert() {}
}

@MainActor
final class FakeSpeechSynth: SpeechSynthServicing {
    var spoken: [String] = []
    var stopCount = 0

    func speak(_ text: String) async {
        spoken.append(text)
    }

    func stop() {
        stopCount += 1
    }
}
