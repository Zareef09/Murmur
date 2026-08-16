import SwiftUI

/// Spoken question plus tap fallback. Start over returns to capture home.
struct ClarificationView: View {
    @Bindable var model: CaptureViewModel

    private var intent: ParsedIntent {
        model.pendingIntent ?? ParsedIntent(rawTranscript: "", taskText: "")
    }

    private var question: String {
        model.speechFact ?? ClarifyCopy.question(for: intent)
    }

    private var bloomState: CaptureBloom.BloomState {
        switch model.state {
        case .listening: .listening
        case .processing: .thinking
        case .clarifying: .listening
        default: .idle
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            MurmurIconButton(name: .chevronLeft, label: ClarifyCopy.startOver) {
                model.startOver()
            }
            .padding(.horizontal, MurmurSpace.space4)

            VStack(alignment: .leading, spacing: MurmurSpace.space8) {
                questionBlock
                answerRow
                Spacer(minLength: 0)
                tapFallback
            }
            .padding(.horizontal, MurmurSpace.gutterScreen)
            .padding(.bottom, MurmurSpace.space6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var questionBlock: some View {
        VStack(alignment: .leading, spacing: MurmurSpace.space4) {
            HStack(spacing: 8) {
                MurmurIcon(name: .volume, size: 14)
                    .foregroundStyle(MurmurColor.textTertiary)
                    .accessibilityHidden(true)
                Text(ClarifyCopy.asked)
                    .font(MurmurType.caption)
                    .tracking(MurmurType.trackingCaption)
                    .textCase(.uppercase)
                    .foregroundStyle(MurmurColor.textTertiary)
            }
            Text(question)
                .font(MurmurType.title)
                .tracking(MurmurType.trackingTitle)
                .foregroundStyle(MurmurColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 20 * 16, alignment: .leading)
                .accessibilityAddTraits(.isHeader)
        }
    }

    private var answerRow: some View {
        HStack(alignment: .top, spacing: MurmurSpace.space5) {
            CaptureBloom(
                state: bloomState,
                level: model.state == .listening ? model.listenLevel : 0,
                size: 64,
                isInteractive: false
            )
            .allowsHitTesting(false)
            TranscriptView(
                text: model.transcriptText,
                partial: model.transcriptPartial,
                placeholder: CaptureCopy.listeningPlaceholder,
                alignment: .leading,
                compact: true
            )
            .frame(maxWidth: 18 * 12, alignment: .leading)
        }
    }

    private var tapFallback: some View {
        VStack(spacing: MurmurSpace.space4) {
            Text(ClarifyCopy.quietHint)
                .font(MurmurType.footnote)
                .tracking(MurmurType.trackingFootnote)
                .foregroundStyle(MurmurColor.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)

            let choices = ClarifyCopy.tapChoices(for: intent)
            if !choices.isEmpty {
                HStack(spacing: MurmurSpace.space3) {
                    ForEach(choices, id: \.self) { choice in
                        MurmurButton(
                            title: choice,
                            variant: .secondary,
                            size: .md,
                            fullWidth: true
                        ) {
                            model.tapClarificationAnswer(choice)
                        }
                    }
                }
            }

            MurmurButton(
                title: ClarifyCopy.startOver,
                variant: .ghost,
                size: .md,
                fullWidth: true,
                action: { model.startOver() }
            )
        }
    }
}

#Preview("Clarify · destination · light") {
    let model = CaptureViewModel()
    model.debugSetState(.listening)
    model.pendingIntent = ParsedIntent(
        rawTranscript: "buy groceries on Friday",
        taskText: "buy groceries",
        needsClarification: true,
        clarificationKind: .destination
    )
    model.speechFact = ClarifyCopy.destination
    return ClarificationPreviewHost(model: model)
        .preferredColorScheme(.light)
}

#Preview("Clarify · answered · light") {
    let model = CaptureViewModel()
    model.debugSetState(.processing)
    model.debugArmClarificationLoop()
    model.pendingIntent = ParsedIntent(
        rawTranscript: "meet Friday or Saturday",
        taskText: "meet",
        needsClarification: true,
        clarificationKind: .date
    )
    model.speechFact = ClarifyCopy.whichDay(first: "Friday", second: "Saturday")
    model.transcriptText = "Friday, the early one"
    return ClarificationPreviewHost(model: model)
        .preferredColorScheme(.light)
}

#Preview("Clarify · two days · dark") {
    let model = CaptureViewModel()
    model.debugSetState(.listening)
    model.pendingIntent = ParsedIntent(
        rawTranscript: "meet Friday or Saturday",
        taskText: "meet",
        needsClarification: true,
        clarificationKind: .date
    )
    model.speechFact = ClarifyCopy.whichDay(first: "Friday", second: "Saturday")
    model.transcriptPartial = "Friday"
    return ClarificationPreviewHost(model: model)
        .preferredColorScheme(.dark)
}

private struct ClarificationPreviewHost: View {
    @State var model: CaptureViewModel

    var body: some View {
        ClarificationView(model: model)
            .murmurCanvas(wash: true)
    }
}
