import Foundation

/// Missing field the parser or classifier needs one spoken answer for.
enum ClarificationKind: String, Equatable, Sendable {
    case date
    case time
    case destination
    case garbled
}

/// In-memory parse of one utterance. Not persisted. `rawTranscript` is never logged.
struct ParsedIntent: Equatable, Sendable {
    var rawTranscript: String
    var taskText: String
    var date: Date?
    var hasExplicitTime: Bool
    var durationMinutes: Int?
    var needsClarification: Bool
    var clarificationKind: ClarificationKind?
    var destination: CaptureDestination?
    var confidence: Double

    init(
        rawTranscript: String,
        taskText: String = "",
        date: Date? = nil,
        hasExplicitTime: Bool = false,
        durationMinutes: Int? = nil,
        needsClarification: Bool = false,
        clarificationKind: ClarificationKind? = nil,
        destination: CaptureDestination? = nil,
        confidence: Double = 0
    ) {
        self.rawTranscript = rawTranscript
        self.taskText = taskText
        self.date = date
        self.hasExplicitTime = hasExplicitTime
        self.durationMinutes = durationMinutes
        self.needsClarification = needsClarification
        self.clarificationKind = clarificationKind
        self.destination = destination
        self.confidence = confidence
    }
}
