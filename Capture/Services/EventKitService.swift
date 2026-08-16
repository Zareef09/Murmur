@MainActor
protocol EventKitServicing: AnyObject {
    func createReminder(title: String) async throws -> String
    func createEvent(title: String) async throws -> String
    func deleteItem(identifier: String) async throws
}

@MainActor
final class EventKitService: EventKitServicing {
    func createReminder(title: String) async throws -> String { "" }

    func createEvent(title: String) async throws -> String { "" }

    func deleteItem(identifier: String) async throws {}
}
