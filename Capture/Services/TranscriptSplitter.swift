import Foundation

/// Splits one spoken turn into separate captures.
///
/// "Call mom at 5, go to the gym at 7, dinner at 8" is three things, not one. Commas, semicolons and
/// "then" always separate. "and" only separates when what follows carries its own time, so
/// "dinner with Sam and Alex" stays one capture while "dinner at 8 and gym at 9" becomes two.
enum TranscriptSplitter {
    /// Shortest fragment worth treating as its own capture.
    static let minimumSegmentLength = 3

    /// One entry when the turn is a single capture. Never empty for non-empty input.
    static func segments(_ transcript: String) -> [String] {
        let trimmed = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        var pieces = splitOnHardSeparators(trimmed)
        pieces = pieces.flatMap(splitOnTimedAnd)

        let kept = pieces
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count >= minimumSegmentLength }

        return kept.isEmpty ? [trimmed] : kept
    }

    /// True when the turn holds more than one capture.
    static func isMultiple(_ transcript: String) -> Bool {
        segments(transcript).count > 1
    }

    private static func splitOnHardSeparators(_ text: String) -> [String] {
        let pattern = #"[,;]|\bthen\b|\balso\b"#
        return text
            .replacingOccurrences(of: pattern, with: "\u{0}", options: [.regularExpression, .caseInsensitive])
            .components(separatedBy: "\u{0}")
    }

    /// "and" is only a separator when the clause after it has its own clock time or day.
    private static func splitOnTimedAnd(_ text: String) -> [String] {
        var out: [String] = []
        var rest = text

        while let range = rest.range(of: #"\band\b"#, options: [.regularExpression, .caseInsensitive]) {
            let left = String(rest[rest.startIndex..<range.lowerBound])
            let right = String(rest[range.upperBound...])
            guard carriesOwnTime(right), carriesOwnTime(left) else { break }
            out.append(left)
            rest = right
        }

        out.append(rest)
        return out
    }

    private static func carriesOwnTime(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= minimumSegmentLength else { return false }
        if ClockTimePhrase.containsClockTime(trimmed) { return true }
        return trimmed.range(
            of: #"\b(today|tonight|tomorrow|monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b"#,
            options: [.regularExpression, .caseInsensitive]
        ) != nil
    }
}
