import SwiftUI

/// Live caption. Settled words at full contrast; the in-flight tail sits one step back.
/// Never truncates a sentence the user just spoke.
struct TranscriptView: View {
    enum Alignment {
        case center
        case leading

        var text: TextAlignment {
            switch self {
            case .center: .center
            case .leading: .leading
            }
        }

        var frame: SwiftUI.Alignment {
            switch self {
            case .center: .center
            case .leading: .leading
            }
        }
    }

    var text: String = ""
    var partial: String = ""
    var placeholder: String = "I'm listening…"
    var alignment: Alignment = .center
    /// Thinking uses secondary; success uses a slightly smaller size (kit 22).
    var dimmed: Bool = false
    var compact: Bool = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var risen = false

    var body: some View {
        (settled + inflight)
            .font(compact ? MurmurType.headline : MurmurType.transcript)
            .tracking(compact ? MurmurType.trackingHeadline : MurmurType.trackingTranscript)
            .multilineTextAlignment(alignment.text)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: 30 * 13, alignment: alignment.frame)
            .offset(y: risen ? 0 : MurmurMotion.transcriptRise)
            .onAppear {
                if reduceMotion {
                    risen = true
                } else {
                    withAnimation(MurmurMotion.animation(.exhale, .slow, reduceMotion: reduceMotion)) {
                        risen = true
                    }
                }
            }
            .animation(
                MurmurMotion.animation(.exhale, .normal, reduceMotion: reduceMotion),
                value: isEmpty
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spoken)
    }

    private var isEmpty: Bool { text.isEmpty && partial.isEmpty }

    private var spoken: String {
        if isEmpty { return placeholder }
        if partial.isEmpty { return text }
        if text.isEmpty { return partial }
        return text + " " + partial
    }

    private var settled: Text {
        Text(isEmpty ? placeholder : text)
            .foregroundColor(isEmpty ? MurmurColor.textTertiary : (dimmed ? MurmurColor.textSecondary : MurmurColor.textPrimary))
    }

    private var inflight: Text {
        guard !partial.isEmpty else { return Text("") }
        let gap = text.isEmpty ? "" : " "
        return Text(gap + partial)
            .foregroundColor(MurmurColor.textTertiary)
    }
}
