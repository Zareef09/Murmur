import SwiftUI

/// Session 38–39: all four Light Well states. Listening uses a simulated smoothed amplitude.
struct CaptureBloomCatalog: View {
    var body: some View {
        ScrollView {
            VStack(spacing: MurmurSpace.stackSection) {
                Text("Rings follow the voice 0 / 90 / 180ms apart. Raw jumps are smoothed so it reads as breath.")
                    .font(MurmurType.footnote)
                    .tracking(MurmurType.trackingFootnote)
                    .foregroundStyle(MurmurColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                listeningDemo
                CaptureBloom(state: .idle, size: 180, label: "Tap to speak")
                CaptureBloom(state: .thinking, size: 180, label: "One moment")
                CaptureBloom(state: .done, size: 180, label: "Saved")
            }
            .padding(MurmurSpace.gutterScreen)
        }
        .background(MurmurColor.bgBase.ignoresSafeArea())
    }

    private var listeningDemo: some View {
        TimelineView(.animation(minimumInterval: 1 / 20)) { context in
            CaptureBloom(
                state: .listening,
                level: Self.simulatedAmplitude(at: context.date),
                size: 180,
                label: "Listening"
            )
        }
    }

    /// Kit `useLevel` shape — catalog only. Capture home uses the live mic (Session 57).
    private static func simulatedAmplitude(at date: Date) -> CGFloat {
        let t = date.timeIntervalSinceReferenceDate
        let raw = 0.5 + 0.42 * sin(t) * sin(t * 0.41) + 0.06 * sin(t * 4.3)
        return min(1, max(0, raw))
    }
}

#Preview("Bloom · light") {
    CaptureBloomCatalog()
        .preferredColorScheme(.light)
}

#Preview("Bloom · dark") {
    CaptureBloomCatalog()
        .preferredColorScheme(.dark)
}
