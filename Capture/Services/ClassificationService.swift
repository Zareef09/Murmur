import Foundation

protocol ClassificationServicing: Sendable {
    func classify(_ intent: ParsedIntent) -> ParsedIntent
}

/// Spec §6.3. Does not guess date-only / no-keyword (open decision: clarify destination).
struct ClassificationService: ClassificationServicing {
    static let highConfidence = 0.85
    static let lowConfidence = 0.35

    func classify(_ intent: ParsedIntent) -> ParsedIntent {
        var result = intent
        let haystack = (intent.rawTranscript + " " + intent.taskText).lowercased()
        let eventLike = EventKeyword.contains(haystack)
        let vague = VagueTime.contains(haystack)

        if intent.needsClarification, intent.clarificationKind == .date {
            result.confidence = Self.lowConfidence
            result.destination = nil
            return result
        }
        if intent.taskText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || intent.clarificationKind == .garbled {
            return clarify(result, kind: .garbled)
        }
        if vague, intent.date == nil, !intent.hasExplicitTime {
            return clarify(result, kind: .date)
        }
        if eventLike, !intent.hasExplicitTime {
            result.destination = .event
            return clarify(result, kind: .time)
        }
        if intent.hasExplicitTime {
            result.destination = .event
            result.confidence = Self.highConfidence
            result.needsClarification = false
            result.clarificationKind = nil
            return result
        }
        if intent.date != nil, !eventLike {
            if intent.destination != nil {
                result.confidence = Self.highConfidence
                result.needsClarification = false
                result.clarificationKind = nil
                return result
            }
            // Open decision: do not pick reminder vs event.
            return clarify(result, kind: .destination)
        }
        result.destination = .reminder
        result.confidence = Self.highConfidence
        result.needsClarification = false
        result.clarificationKind = nil
        return result
    }

    private func clarify(_ intent: ParsedIntent, kind: ClarificationKind) -> ParsedIntent {
        var result = intent
        result.needsClarification = true
        result.clarificationKind = kind
        result.confidence = Self.lowConfidence
        if kind != .time {
            result.destination = kind == .garbled ? nil : result.destination
        }
        if kind == .garbled || kind == .destination || kind == .date {
            result.destination = nil
        }
        return result
    }
}

enum EventKeyword {
    static func contains(_ text: String) -> Bool {
        let phrases = ["lunch with", "dinner with", "breakfast with", "coffee with", "call with"]
        if phrases.contains(where: { text.contains($0) }) { return true }
        return text.range(of: #"\b(meeting|appointment|interview)\b"#, options: .regularExpression) != nil
    }
}

enum VagueTime {
    static func contains(_ text: String) -> Bool {
        if text.range(of: #"\b(soon|later|sometime)\b"#, options: .regularExpression) != nil {
            return true
        }
        if text.contains("this week") || text.contains("next week") {
            return !hasWeekday(text)
        }
        return false
    }

    private static func hasWeekday(_ text: String) -> Bool {
        text.range(
            of: #"\b(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b"#,
            options: .regularExpression
        ) != nil
    }
}
