import Foundation

/// Spec §7: parse the answer for the missing field only, then merge into the pending intent.
enum ClarificationMerge {
    static func merging(
        _ answer: String,
        into pending: ParsedIntent,
        parser: ParsingServicing
    ) -> ParsedIntent {
        let trimmed = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        switch pending.clarificationKind {
        case .destination:
            return mergeDestination(trimmed, into: pending)
        case .date:
            return mergeDate(trimmed, into: pending, parser: parser)
        case .time:
            return mergeTime(trimmed, into: pending, parser: parser)
        case .garbled, .none:
            return parser.parse(trimmed)
        }
    }

    private static func mergeDestination(_ answer: String, into pending: ParsedIntent) -> ParsedIntent {
        var result = pending
        if let destination = destination(from: answer) {
            result.destination = destination
        }
        result.needsClarification = false
        result.clarificationKind = nil
        return result
    }

    private static func mergeDate(
        _ answer: String,
        into pending: ParsedIntent,
        parser: ParsingServicing
    ) -> ParsedIntent {
        let parsed = parser.parse(answer)
        var result = pending
        if let date = parsed.date {
            result.date = date
            result.hasExplicitTime = parsed.hasExplicitTime
            result.durationMinutes = parsed.durationMinutes ?? result.durationMinutes
        }
        result.needsClarification = false
        result.clarificationKind = nil
        return result
    }

    private static func mergeTime(
        _ answer: String,
        into pending: ParsedIntent,
        parser: ParsingServicing
    ) -> ParsedIntent {
        let parsed = parser.parse(answer)
        var result = pending
        if parsed.hasExplicitTime, let time = parsed.date {
            if let day = pending.date {
                result.date = combining(day: day, time: time)
            } else {
                result.date = time
            }
            result.hasExplicitTime = true
            result.durationMinutes = parsed.durationMinutes ?? result.durationMinutes
        }
        result.needsClarification = false
        result.clarificationKind = nil
        return result
    }

    static func destination(from answer: String) -> CaptureDestination? {
        let folded = answer.lowercased()
        if folded.range(of: #"\bcalendars?\b"#, options: .regularExpression) != nil {
            return .event
        }
        if folded.range(of: #"\breminders?\b"#, options: .regularExpression) != nil {
            return .reminder
        }
        return nil
    }

    private static func combining(day: Date, time: Date, calendar: Calendar = .current) -> Date {
        var parts = calendar.dateComponents([.year, .month, .day], from: day)
        let clock = calendar.dateComponents([.hour, .minute, .second], from: time)
        parts.hour = clock.hour
        parts.minute = clock.minute
        parts.second = clock.second
        return calendar.date(from: parts) ?? time
    }
}
