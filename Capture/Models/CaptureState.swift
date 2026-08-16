enum CaptureState: String, Equatable, Hashable, Sendable, CaseIterable {
    case signedOut
    case idle
    case listening
    case processing
    case clarifying
    case confirming
    case saving
    case success
    case failed
}
