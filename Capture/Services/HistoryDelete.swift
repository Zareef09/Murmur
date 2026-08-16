import Foundation
import SwiftData

enum HistoryDeleteScope: Equatable, Sendable {
    case murmurOnly
    case alsoExternal
}

/// Removes a history row. EventKit is touched only for `alsoExternal`, by stored identifier.
enum HistoryDelete {
    @MainActor
    static func apply(
        _ capture: Capture,
        scope: HistoryDeleteScope,
        context: ModelContext,
        eventKit: EventKitServicing
    ) async throws {
        if scope == .alsoExternal {
            let identifier = capture.eventKitIdentifier?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !identifier.isEmpty {
                try await eventKit.deleteItem(identifier: identifier)
            }
        }
        context.delete(capture)
        try context.save()
    }
}
