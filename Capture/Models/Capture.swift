import Foundation
import SwiftData

/// On-device history row. No audio. No cloud id. TTL uses `createdAt` (Session 42).
@Model
final class Capture {
    var id: UUID
    var title: String
    var destination: CaptureDestination
    var startDate: Date?
    var hasExplicitTime: Bool
    var durationMinutes: Int?
    /// Opaque EventKit identifier. Never log it.
    var eventKitIdentifier: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        destination: CaptureDestination,
        startDate: Date? = nil,
        hasExplicitTime: Bool = false,
        durationMinutes: Int? = nil,
        eventKitIdentifier: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.destination = destination
        self.startDate = startDate
        self.hasExplicitTime = hasExplicitTime
        self.durationMinutes = durationMinutes
        self.eventKitIdentifier = eventKitIdentifier
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
