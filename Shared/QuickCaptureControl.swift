import AppIntents
import SwiftUI
import WidgetKit

/// Control Center is iOS 18+. Home and lock-screen widgets stay on iOS 17.
enum QuickCaptureControlSupport {
    static let kind = "app.murmur.capture.control.quickCapture"
    static let title = "Quick capture"
    static let symbolName = "waveform"

    static var isRuntimeAvailable: Bool {
        if #available(iOS 18.0, *) {
            true
        } else {
            false
        }
    }
}

/// Tap runs Quick capture (foreground). Waveform, not mic.
@available(iOS 18.0, *)
struct QuickCaptureControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: QuickCaptureControlSupport.kind) {
            ControlWidgetButton(action: QuickCaptureIntent()) {
                Label(QuickCaptureControlSupport.title, systemImage: QuickCaptureControlSupport.symbolName)
            }
        }
        .displayName("Quick capture")
        .description("Open Murmur and start listening.")
    }
}
