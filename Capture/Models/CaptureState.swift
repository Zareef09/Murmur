enum CaptureState: String, Equatable, Hashable, Sendable, CaseIterable {
    case signedOut
    case idle
    case listening
    case processing
    case clarifying
    /// One turn held more than one capture. Each is waiting on a destination.
    case routing
    case confirming
    case saving
    case success
    case failed
}
