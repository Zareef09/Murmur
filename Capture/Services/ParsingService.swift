import Foundation
import NaturalLanguage

protocol ParsingServicing: Sendable {
    func parse(_ transcript: String) -> ParsedIntent
}

/// Date fields from `NSDataDetector`, then date phrase + leading fillers stripped from `taskText`.
struct ParsingService: ParsingServicing {
    func parse(_ transcript: String) -> ParsedIntent {
        let trimmed = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return ParsedIntent(
                rawTranscript: transcript,
                needsClarification: true,
                clarificationKind: .garbled
            )
        }

        let matches = dateMatches(in: trimmed)

        // "at 5" carries a real time to a person but not to NSDataDetector, which needs "5pm" or
        // "5:00". Fall back to a bare hour only when the detector found nothing at all.
        if matches.isEmpty, let bare = BareClockTime.firstMatch(in: trimmed) {
            let taskText = TaskTextCleanup.cleaned(from: trimmed, removing: [bare.range])
            return ParsedIntent(
                rawTranscript: transcript,
                taskText: taskText,
                date: bare.date,
                hasExplicitTime: true,
                needsClarification: taskText.isEmpty,
                clarificationKind: taskText.isEmpty ? .garbled : nil
            )
        }

        let first = matches.first
        let twoDates = matches.count >= 2
        let matchedText = first.map { substring(trimmed, range: $0.range) } ?? ""
        let taskText = TaskTextCleanup.cleaned(
            from: trimmed,
            removing: matches.map(\.range)
        )

        var needsClarification = twoDates
        var kind: ClarificationKind? = twoDates ? .date : nil
        if taskText.isEmpty, !twoDates {
            needsClarification = true
            kind = .garbled
        }

        return ParsedIntent(
            rawTranscript: transcript,
            taskText: taskText,
            date: first?.date,
            hasExplicitTime: ClockTimePhrase.containsClockTime(matchedText),
            durationMinutes: durationMinutes(first),
            needsClarification: needsClarification,
            clarificationKind: kind
        )
    }

    private func dateMatches(in text: String) -> [NSTextCheckingResult] {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue) else {
            return []
        }
        let full = NSRange(text.startIndex..., in: text)
        return detector.matches(in: text, options: [], range: full)
    }

    private func substring(_ text: String, range: NSRange) -> String {
        guard let swiftRange = Range(range, in: text) else { return "" }
        return String(text[swiftRange])
    }

    private func durationMinutes(_ match: NSTextCheckingResult?) -> Int? {
        guard let match, match.duration >= 60 else { return nil }
        let minutes = Int((match.duration / 60).rounded())
        return minutes > 0 ? minutes : nil
    }
}

/// A spoken hour with no meridiem and no date word: "call mom at 5", "dinner at 8".
///
/// Resolved to the next time that hour comes round on a 12-hour clock, which is what a person
/// means by it. Said at 9am, "at 8" is tonight; said at 9pm, it is tomorrow morning.
enum BareClockTime {
    private static let pattern =
        #"\bat\s+(1[0-2]|[1-9])(?::([0-5]\d))?\b(?!\s*(a\.?m\.?|p\.?m\.?|o['’]?clock))"#

    static func firstMatch(
        in text: String,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> (range: NSRange, date: Date)? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }
        let full = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: full) else { return nil }
        guard let hour = intGroup(match, 1, in: text), (1...12).contains(hour) else { return nil }
        let minute = intGroup(match, 2, in: text) ?? 0
        guard let date = nextOccurrence(hour: hour, minute: minute, now: now, calendar: calendar) else {
            return nil
        }
        return (match.range, date)
    }

    /// Earliest of today/tomorrow at the AM and PM readings that is still ahead of `now`.
    private static func nextOccurrence(
        hour: Int,
        minute: Int,
        now: Date,
        calendar: Calendar
    ) -> Date? {
        let base = hour % 12
        let today = calendar.startOfDay(for: now)
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else { return nil }

        return [today, tomorrow]
            .flatMap { day in
                [base, base + 12].compactMap { h in
                    calendar.date(bySettingHour: h, minute: minute, second: 0, of: day)
                }
            }
            .filter { $0 > now }
            .min()
    }

    private static func intGroup(_ match: NSTextCheckingResult, _ index: Int, in text: String) -> Int? {
        let range = match.range(at: index)
        guard range.location != NSNotFound, let swiftRange = Range(range, in: text) else { return nil }
        return Int(text[swiftRange])
    }
}

/// Clock time in the **matched date substring**, not on `Date` components.
enum ClockTimePhrase {
    static func containsClockTime(_ text: String) -> Bool {
        let folded = text.lowercased()
        let patterns = [
            #"\bnoon\b"#,
            #"\bmidnight\b"#,
            #"\bo['’]?clock\b"#,
            #"\b([01]?\d|2[0-3])([:.][0-5]\d)?\s*(a\.?m\.?|p\.?m\.?)\b"#,
            #"\b([01]?\d|2[0-3]):[0-5]\d\b"#,
            #"\bat\s+([01]?\d|2[0-3])\b"#,
            #"\b([01]?\d|2[0-3])\s*[-–—]\s*([01]?\d|2[0-3])\s*(a\.?m\.?|p\.?m\.?)\b"#
        ]
        return patterns.contains { pattern in
            folded.range(of: pattern, options: .regularExpression) != nil
        }
    }
}

/// Spec §6.2 steps 4–5. Frame verbs only — never strip the task verb (“call”).
enum TaskTextCleanup {
    private static let frameVerbs: Set<String> = ["remind", "remember", "forget"]
    private static let frameWords: Set<String> = [
        "me", "us", "please", "hey", "to", "that", "do", "don't", "dont", "not", "n't"
    ]
    private static let edgeGlue: Set<String> = [
        "at", "on", "by", "for", "in", "this", "next", "to", "and", "or", "the", "a", "an"
    ]

    static func cleaned(from text: String, removing dateRanges: [NSRange]) -> String {
        var working = text
        for range in dateRanges.sorted(by: { $0.location > $1.location }) {
            guard let swiftRange = Range(range, in: working) else { continue }
            working.removeSubrange(swiftRange)
        }
        working = working.replacingOccurrences(of: #"[\s,;:]+"#, with: " ", options: .regularExpression)
        working = working.trimmingCharacters(in: .whitespacesAndNewlines)
        working = unfoldContractions(working)
        working = stripLeadingFrame(working)
        working = stripEdgeGlue(working)
        return working
    }

    private static func unfoldContractions(_ text: String) -> String {
        text.replacingOccurrences(of: "n't", with: " not", options: .caseInsensitive)
            .replacingOccurrences(of: "n’t", with: " not", options: .caseInsensitive)
    }

    private static func stripLeadingFrame(_ text: String) -> String {
        guard !text.isEmpty else { return text }
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        tagger.setLanguage(.english, range: text.startIndex..<text.endIndex)
        var cut = text.startIndex
        let span = text.startIndex..<text.endIndex
        tagger.enumerateTags(
            in: span,
            unit: .word,
            scheme: .lexicalClass,
            options: [.omitPunctuation, .omitWhitespace]
        ) { tag, range in
            let word = String(text[range]).lowercased()
            if isLeadingFiller(word: word, tag: tag) {
                cut = range.upperBound
                return true
            }
            return false
        }
        return String(text[cut...]).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func isLeadingFiller(word: String, tag: NLTag?) -> Bool {
        if frameVerbs.contains(word) { return true }
        if frameWords.contains(word) { return true }
        if edgeGlue.contains(word), tag == .preposition || tag == .particle || tag == .determiner || tag == .conjunction {
            return true
        }
        return false
    }

    private static func stripEdgeGlue(_ text: String) -> String {
        let tokens = text.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        guard !tokens.isEmpty else { return "" }
        var start = 0
        var end = tokens.count
        while start < end, edgeGlue.contains(tokens[start].lowercased()) {
            start += 1
        }
        while end > start, edgeGlue.contains(tokens[end - 1].lowercased()) {
            end -= 1
        }
        return tokens[start..<end].joined(separator: " ")
    }
}
