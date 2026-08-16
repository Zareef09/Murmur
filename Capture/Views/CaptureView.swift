import SwiftUI

/// Capture home. Light Well / listening arrive in later sessions; this screen is unreachable while signed out.
struct CaptureView: View {
    var model: CaptureViewModel

    var body: some View {
        Group {
            if model.canCapture {
                Text("Tap to speak")
                    .font(MurmurType.footnote)
                    .tracking(MurmurType.trackingFootnote)
                    .foregroundStyle(MurmurColor.textTertiary)
            } else {
                Color.clear
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .murmurCanvas(wash: true)
        .allowsHitTesting(model.canCapture)
    }
}

#Preview("Capture · idle") {
    let model = CaptureViewModel()
    model.state = .idle
    return CaptureView(model: model)
}
