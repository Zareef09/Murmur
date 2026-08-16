protocol ParsingServicing: Sendable {
    func parse(_ transcript: String) -> String
}

struct ParsingService: ParsingServicing {
    func parse(_ transcript: String) -> String { transcript }
}
