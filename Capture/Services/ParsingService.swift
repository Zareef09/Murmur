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
