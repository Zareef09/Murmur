import WidgetKit

/// Home screen plus lock-screen accessories. Control Center is `QuickCaptureControl`.
enum QuickCaptureWidgetSupport {
    static let families: [WidgetFamily] = [
        .systemSmall,
        .accessoryCircular,
        .accessoryInline,
        .accessoryRectangular
    ]

    static let lockScreen: [WidgetFamily] = [
        .accessoryCircular,
        .accessoryInline,
        .accessoryRectangular
    ]
}
