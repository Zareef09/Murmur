import Foundation

/// Copy for the multi-capture routing screen. Sentence case, no exclamation, no blame.
enum RoutingCopy {
    static let title = "Where should these go?"
    static let subtitle = "Pick a place for each one."
    static let save = "Save all"
    static let cancel = "Start over"
    static let noTime = "No time set"

    static func heard(_ count: Int) -> String {
        count == 1 ? "Heard 1 thing" : "Heard \(count) things"
    }

    /// Shown on the save button's row while some items still need a destination.
    static func remaining(_ count: Int) -> String {
        count == 1 ? "1 still needs a place" : "\(count) still need a place"
    }

    static func savedMessage(_ count: Int) -> String {
        count == 1 ? "Saved 1 thing" : "Saved \(count) things"
    }

    static var allLines: [String] {
        [title, subtitle, save, cancel, noTime, heard(2), remaining(2), savedMessage(3)]
    }
}
