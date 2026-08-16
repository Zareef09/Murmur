protocol ClassificationServicing: Sendable {
    func classify(_ taskText: String) -> CaptureDestination
}

struct ClassificationService: ClassificationServicing {
    func classify(_ taskText: String) -> CaptureDestination { .reminder }
}
