import Foundation
import os

/// The only logging entry point. Typed events only — no transcript, title, tokens, or EventKit IDs.
enum LoggingPolicy {
    static let subsystem = "app.murmur.capture"

    enum Category: String, Sendable {
        case auth
        case settings
        case capture
        case speech
        case eventKit = "eventkit"
        case persistence
        case permissions
    }

    enum Event: Equatable, Sendable {
        case captureState(CaptureState)
        case settingsUpsertOK
        case httpStatus(Int)
        case persistenceReady
        case historyPurged(removed: Int)
        case authSignedIn(Bool)
        case notConfigured
        case permission(PermissionKind, PermissionAccess)
        case audioMode(AudioSessionMode)
        case speechOnDeviceRequest
        case speechStream
        case speechSilenceStop
        case speechOnDeviceUnavailable
        case speechSynth
        case reminderCreated
        case eventCreated
        case itemDeleted
        case itemOpened
    }

    static func log(_ event: Event, category: Category) {
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        logger.info("\(message(for: event), privacy: .public)")
    }

    static func message(for event: Event) -> String {
        switch event {
        case .captureState(let state):
            "state \(state.rawValue)"
        case .settingsUpsertOK:
            "settings upsert ok"
        case .httpStatus(let code):
            "http \(code)"
        case .persistenceReady:
            "persistence ready"
        case .historyPurged(let removed):
            "history purged \(removed)"
        case .authSignedIn(let signedIn):
            "auth signedIn \(signedIn)"
        case .notConfigured:
            "client not configured"
        case .permission(let kind, let access):
            "permission \(kind.rawValue) \(access.rawValue)"
        case .audioMode(let mode):
            "audio \(mode.rawValue)"
        case .speechOnDeviceRequest:
            "speech on-device request"
        case .speechStream:
            "speech stream"
        case .speechSilenceStop:
            "speech silence stop"
        case .speechOnDeviceUnavailable:
            "speech on-device unavailable"
        case .speechSynth:
            "speech synth"
        case .reminderCreated:
            "reminder created"
        case .eventCreated:
            "event created"
        case .itemDeleted:
            "item deleted"
        case .itemOpened:
            "item opened"
        }
    }

    /// Use when a string is user content. Never interpolate the original into a log.
    static func redactedUserContent() -> String { "<redacted>" }

    /// True if `text` looks like a banned payload (JWT, title/transcript samples, EventKit id shape).
    static func looksLikeBannedContent(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        if trimmed.contains("eyJ") { return true }
        let jwtParts = trimmed.split(separator: ".")
        if jwtParts.count == 3, trimmed.count > 40 { return true }
        if trimmed.hasPrefix("ek-") { return true }
        return false
    }
}
