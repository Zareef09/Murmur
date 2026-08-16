import Foundation
import SwiftData

/// On-device SwiftData store. No CloudKit. History never leaves the device.
enum Persistence {
    /// Sentinel for the Session 41 store probe. Deleted immediately; never shown as history.
    static let probeTitle = "__murmur.persistence.probe__"

    static let container: ModelContainer = {
        do {
            return try makeContainer(inMemory: false)
        } catch {
            return try! makeContainer(inMemory: true)
        }
    }()

    static func makeContainer(inMemory: Bool) throws -> ModelContainer {
        let schema = Schema([Capture.self])
        let configuration: ModelConfiguration
        if inMemory {
            configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true,
                cloudKitDatabase: .none
            )
        } else {
            let directory = try historyDirectory()
            let url = directory.appendingPathComponent("MurmurHistory.store")
            configuration = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        }
        let container = try ModelContainer(for: schema, configurations: [configuration])
        if !inMemory {
            try applyFileProtection(at: configuration.url)
        }
        return container
    }

    /// Insert, fetch, delete. Leaves zero probe rows. Does not log titles or identifiers.
    @MainActor
    static func proveStoreThenRemove(_ container: ModelContainer) {
        let context = container.mainContext
        do {
            try deleteProbes(in: context)
            let probe = Capture(title: probeTitle, destination: .reminder)
            let probeID = probe.id
            context.insert(probe)
            try context.save()
            let found = try context.fetch(
                FetchDescriptor<Capture>(predicate: #Predicate { $0.id == probeID })
            )
            guard found.count == 1 else {
                try deleteProbes(in: context)
                return
            }
            context.delete(found[0])
            try context.save()
            try deleteProbes(in: context)
        } catch {
            try? deleteProbes(in: context)
        }
    }

    private static func historyDirectory() throws -> URL {
        let root = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let directory = root.appendingPathComponent("Murmur", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try FileManager.default.setAttributes(
            [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
            ofItemAtPath: directory.path
        )
        return directory
    }

    private static func applyFileProtection(at storeURL: URL) throws {
        let extras = ["", "-wal", "-shm"]
        for suffix in extras {
            let path = storeURL.path + suffix
            guard FileManager.default.fileExists(atPath: path) else { continue }
            try FileManager.default.setAttributes(
                [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
                ofItemAtPath: path
            )
        }
    }

    private static func deleteProbes(in context: ModelContext) throws {
        let sentinel = probeTitle
        let leftover = try context.fetch(
            FetchDescriptor<Capture>(predicate: #Predicate { $0.title == sentinel })
        )
        for row in leftover {
            context.delete(row)
        }
        if context.hasChanges {
            try context.save()
        }
    }
}
