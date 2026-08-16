import Foundation

/// Spoken and on-screen clarification questions. Sentence case, no “error”.
enum ClarifyCopy {
    static let when = "When should this be?"
    static let time = "What time?"
    static let destination = "Should this go to Reminders, or Calendar?"
    static let whichDay = "Which day did you mean?"
    static let garbled = "Say that again, or tap to type it."
    static let quietHint = "Somewhere quiet? Tap an answer instead."
    static let asked = "Murmur asked"
    static let startOver = "Start over"
    static let today = "Today"
    static let tomorrow = "Tomorrow"
    static let reminders = "Reminders"
    static let calendar = "Calendar"

    static func tapChoices(for intent: ParsedIntent) -> [String] {
        switch intent.clarificationKind {
        case .destination:
            return [reminders, calendar]
        case .date:
            if let pair = ClarifyWeekdays.pair(in: intent.rawTranscript) {
                return [pair.0, pair.1]
            }
            return [today, tomorrow]
        case .time, .garbled, .none:
            return []
        }
    }

    static func fact(for kind: ClarificationKind?) -> String {
        question(kind: kind, transcript: "")
    }

    static func question(for intent: ParsedIntent) -> String {
        question(kind: intent.clarificationKind, transcript: intent.rawTranscript)
    }

    static func whichDay(first: String, second: String) -> String {
        "Which day did you mean — \(first) or \(second)?"
    }

    static func question(kind: ClarificationKind?, transcript: String) -> String {
        switch kind {
        case .date:
            if let pair = ClarifyWeekdays.pair(in: transcript) {
                return whichDay(first: pair.0, second: pair.1)
            }
            return when
        case .time:
            return time
        case .destination:
            return destination
        case .garbled, .none:
            return garbled
        }
    }
}

/// Weekday names as they appear in the utterance, title-cased. Never invents a second day.
enum ClarifyWeekdays {
    private static let names = [
        "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
    ]

    static func pair(in transcript: String) -> (String, String)? {
        let folded = transcript.lowercased()
        var found: [String] = []
        for name in names {
            let pattern = "\\b\(name.lowercased())s?\\b"
            if folded.range(of: pattern, options: .regularExpression) != nil {
                found.append(name)
            }
        }
        guard found.count >= 2 else { return nil }
        return (found[0], found[1])
    }
}
