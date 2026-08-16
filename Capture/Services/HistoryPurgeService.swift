import Foundation
import SwiftData

/// Deletes in-app history older than 72 hours. Never touches EventKit.
enum HistoryPurgeService {
    static let ttl: TimeInterval = 72 * 60 * 60

    static func cutoff(now: Date) -> Date {
        now.addingTimeInterval(-ttl)
    }

    /// Removes SwiftData rows with `createdAt < now − 72 hours`. Apple reminders and events stay.
    @discardableResult
    @MainActor
    static func purgeExpired(in context: ModelContext, now: Date = Date()) throws -> Int {
        let limit = cutoff(now: now)
        let rows = try context.fetch(FetchDescriptor<Capture>())
        var removed = 0
        for row in rows where row.createdAt < limit {
            context.delete(row)
            removed += 1
        }
        if context.hasChanges {
            try context.save()
        }
        return removed
    }
}

extension ModelContext {
    /// Persist then drop expired history. Call after every successful save (S68+).
    @MainActor
    func saveAndPurgeHistory(now: Date = Date()) throws {
        try save()
        try HistoryPurgeService.purgeExpired(in: self, now: now)
    }
}
