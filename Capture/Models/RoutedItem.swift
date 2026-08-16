import Foundation

/// One capture out of a multi-part turn, with the destination the user picked for it.
///
/// `destination` starts at the classifier's read and stays changeable. Nothing saves until every
/// item has one, so an unsure classification asks instead of guessing.
struct RoutedItem: Identifiable, Equatable, Sendable {
    let id: UUID
    var intent: ParsedIntent
    var destination: CaptureDestination?

    init(id: UUID = UUID(), intent: ParsedIntent, destination: CaptureDestination? = nil) {
        self.id = id
        self.intent = intent
        self.destination = destination ?? intent.destination
    }

    var title: String {
        intent.taskText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isReady: Bool {
        destination != nil && !title.isEmpty
    }

    func when(now: Date = Date(), calendar: Calendar = .current) -> String {
        ConfirmationWhenFormat.display(
            date: intent.date,
            hasExplicitTime: intent.hasExplicitTime,
            now: now,
            calendar: calendar
        )
    }
}

extension Array where Element == RoutedItem {
    var allRouted: Bool {
        !isEmpty && allSatisfy(\.isReady)
    }

    var readyCount: Int {
        filter(\.isReady).count
    }
}
