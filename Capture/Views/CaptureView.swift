import SwiftUI
import SwiftData

/// Capture home. Tap the well to listen; live words sit above. The well follows mic level.
struct CaptureView: View {
    @Bindable var model: CaptureViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var showSettings = false
    @State private var showHistory = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isConfirming: Bool {
        model.state == .confirming && model.pendingIntent != nil
    }

    private var canUseWell: Bool {
        model.canCapture && SpeechLocalePolicy.supportsOnDevice()
    }

    private var bloomState: CaptureBloom.BloomState {
        switch model.state {
        case .listening: .listening
        case .processing, .saving: .thinking
        case .success: .done
        default: .idle
        }
    }

    var body: some View {
        Group {
            if model.showsRouting {
                RoutingView(model: model)
            } else if model.showsClarification {
                ClarificationView(model: model)
            } else if model.canCapture {
                ZStack(alignment: .bottom) {
                    captureHome
                        .scaleEffect(isConfirming ? MurmurMotion.confirmScale : 1)
                        .opacity(isConfirming ? 1 - MurmurMotion.confirmDim : 1)
                    if isConfirming {
                        ConfirmationView(
                            intent: pendingIntentBinding,
                            onSave: { Task { await model.confirmSave() } },
                            onCancel: { model.confirmCancel() }
                        )
                        .transition(.murmurSheet)
                    }
                }
                .animation(
                    isConfirming
                        ? MurmurMotion.sheetInsertion(reduceMotion: reduceMotion)
                        : MurmurMotion.sheetRemoval(reduceMotion: reduceMotion),
                    value: isConfirming
                )
            } else {
                Color.clear
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .murmurCanvas(wash: true)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $showHistory) {
            HistoryView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(model: model)
        }
        .onChange(of: model.state) { _, newState in
            if newState == .success {
                MurmurHaptics.saved()
            }
        }
        .onAppear {
            model.attachHistory(modelContext)
        }
        .onDisappear {
            model.cancelListening()
        }
    }

    /// Kit `CaptureScreen`: transcript slot, well, footnote — centred as one stack with space-9
    /// between, and the success bar reserved below.
    private var captureHome: some View {
        VStack(spacing: 0) {
            chrome
            VStack(spacing: MurmurSpace.space9) {
                heroSlot
                CaptureBloom(
                    state: bloomState,
                    level: model.state == .listening ? model.listenLevel : 0,
                    size: 244,
                    label: caption,
                    isInteractive: wellInteractive,
                    onTap: { model.tapWell() }
                )
                .allowsHitTesting(wellInteractive)
                bloomFoot
                    .animation(
                        MurmurMotion.animation(.exhale, .normal, reduceMotion: reduceMotion),
                        value: footHint
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, MurmurSpace.gutterScreen)
            // Kit bottom padding plus a deliberate lift, so the well sits above centre.
            .padding(.bottom, MurmurSpace.space10 + MurmurSpace.space8)
            successSlot
        }
    }

    /// Listening is interactive too: tapping again ends the turn, which is the only way to stop a
    /// long list early.
    private var wellInteractive: Bool {
        canUseWell && !isConfirming
            && (model.state == .idle || model.state == .success || model.state == .listening)
    }

    private var chrome: some View {
        HStack {
            MurmurIconButton(name: .list, label: "History") {
                showHistory = true
            }
            Spacer(minLength: 0)
            // Kit chrome: 16pt medium, .14em, secondary — not the light wordmark used elsewhere.
            Text(Wordmark.text)
                .font(MurmurType.core(size: 16, relativeTo: .headline, weight: .medium))
                .tracking(16 * 0.14)
                .foregroundStyle(MurmurColor.textSecondary)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 0)
            MurmurIconButton(name: .settings, label: "Settings") {
                showSettings = true
            }
        }
        .padding(.horizontal, MurmurSpace.space4)
    }

    /// The kit's title sits above the well whenever the screen is at rest, not only on first run —
    /// once a capture is under way the transcript takes the slot.
    private var showsHeroTitle: Bool {
        model.showsFirstRun
            || (model.state == .idle && model.transcriptText.isEmpty && model.speechFact == nil)
    }

    @ViewBuilder
    private var heroSlot: some View {
        if showsHeroTitle {
            Text(CaptureCopy.firstRunTitle)
                .font(MurmurType.title)
                .tracking(MurmurType.trackingTitle)
                .multilineTextAlignment(.center)
                .foregroundStyle(MurmurColor.textPrimary)
                // Kit measure is 18ch. On a 393pt screen the gutters set the wrap before this does,
                // so it is a ceiling for wider devices rather than the break point.
                .frame(maxWidth: 340, alignment: .center)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
        } else {
            transcriptSlot
        }
    }

    /// Teaches the joining words, and explains the longer pause once they are heard.
    @ViewBuilder
    private var bloomFoot: some View {
        if let hint = footHint {
            Text(hint)
                .font(MurmurType.footnote)
                .tracking(MurmurType.trackingFootnote)
                .foregroundStyle(MurmurColor.textTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 26 * 10, alignment: .center)
                .fixedSize(horizontal: false, vertical: true)
                .transition(.opacity)
                .id(hint)
        } else {
            Color.clear
                .frame(height: 18)
                .accessibilityHidden(true)
        }
    }

    private var footHint: String? {
        if model.showsFirstRun {
            return CaptureCopy.firstRunFootnote
        }
        if model.isWaitingForMore {
            return CaptureCopy.listeningMoreHint
        }
        if model.state == .idle || model.state == .listening {
            return CaptureCopy.multiHint
        }
        return nil
    }

    private var successSlot: some View {
        Group {
            if model.state == .success, let message = model.successMessage {
                SuccessBar(
                    message: message,
                    destination: model.successDestination ?? .reminder,
                    onUndo: { Task { await model.undoSave() } }
                )
            }
        }
        .frame(maxWidth: .infinity, minHeight: 76, alignment: .top)
        .padding(.horizontal, MurmurSpace.gutterScreen)
    }

    private var transcriptSlot: some View {
        ZStack(alignment: .bottom) {
            Color.clear
                .frame(minHeight: 108)
                .frame(maxWidth: .infinity)
            if showsTranscript {
                TranscriptView(
                    text: model.transcriptText,
                    partial: model.transcriptPartial,
                    placeholder: CaptureCopy.listeningPlaceholder,
                    dimmed: model.state == .processing || model.state == .saving,
                    compact: model.state == .success
                )
            }
        }
        .accessibilityHidden(!showsTranscript)
    }

    private var showsTranscript: Bool {
        model.state == .listening || model.state == .success || !model.transcriptText.isEmpty
    }

    private var caption: String {
        if !SpeechLocalePolicy.supportsOnDevice() {
            return SpeechCopy.unsupportedLocale
        }
        if let fact = model.speechFact {
            return fact
        }
        switch model.state {
        case .listening: return CaptureCopy.listeningCaption
        case .processing, .saving: return CaptureCopy.thinkingCaption
        case .success: return CaptureCopy.successCaption
        case .clarifying: return model.speechFact ?? ClarifyCopy.quietHint
        default:
            return model.showsFirstRun ? CaptureCopy.firstRunCaption : CaptureCopy.idleCaption
        }
    }

    private var pendingIntentBinding: Binding<ParsedIntent> {
        Binding(
            get: {
                model.pendingIntent ?? ParsedIntent(rawTranscript: "", taskText: "")
            },
            set: { newValue in
                model.pendingIntent = newValue
                model.transcriptText = newValue.taskText
            }
        )
    }
}

#Preview("Capture · first run · light") {
    let suite = "preview.capture.firstRun.light"
    let defaults = UserDefaults(suiteName: suite)!
    defaults.removePersistentDomain(forName: suite)
    let model = CaptureViewModel(defaults: defaults)
    model.state = .idle
    return NavigationStack {
        CaptureView(model: model)
    }
    .modelContainer(for: Capture.self, inMemory: true)
    .environment(AuthService())
    .preferredColorScheme(.light)
}

#Preview("Capture · first run · dark") {
    let suite = "preview.capture.firstRun.dark"
    let defaults = UserDefaults(suiteName: suite)!
    defaults.removePersistentDomain(forName: suite)
    let model = CaptureViewModel(defaults: defaults)
    model.state = .idle
    return NavigationStack {
        CaptureView(model: model)
    }
    .modelContainer(for: Capture.self, inMemory: true)
    .environment(AuthService())
    .preferredColorScheme(.dark)
}

#Preview("Capture · idle · light") {
    let model = CaptureViewModel(defaults: leftFirstRunDefaults("preview.capture.idle.light"))
    model.state = .idle
    return NavigationStack {
        CaptureView(model: model)
    }
    .modelContainer(for: Capture.self, inMemory: true)
    .environment(AuthService())
    .preferredColorScheme(.light)
}

#Preview("Capture · idle · dark") {
    let model = CaptureViewModel(defaults: leftFirstRunDefaults("preview.capture.idle.dark"))
    model.state = .idle
    return NavigationStack {
        CaptureView(model: model)
    }
    .modelContainer(for: Capture.self, inMemory: true)
    .environment(AuthService())
    .preferredColorScheme(.dark)
}

#Preview("Capture · listening · light") {
    let model = CaptureViewModel(defaults: leftFirstRunDefaults("preview.capture.listen.light"))
    model.debugSetState(.listening)
    model.transcriptPartial = "Remind me to call mom"
    model.listenLevel = 0.55
    return NavigationStack {
        CaptureView(model: model)
    }
    .modelContainer(for: Capture.self, inMemory: true)
    .environment(AuthService())
    .preferredColorScheme(.light)
}

#Preview("Capture · listening · dark") {
    let model = CaptureViewModel(defaults: leftFirstRunDefaults("preview.capture.listen.dark"))
    model.debugSetState(.listening)
    model.transcriptPartial = "Remind me to call mom"
    model.listenLevel = 0.55
    return NavigationStack {
        CaptureView(model: model)
    }
    .modelContainer(for: Capture.self, inMemory: true)
    .environment(AuthService())
    .preferredColorScheme(.dark)
}

#Preview("Capture · thinking · light") {
    let model = CaptureViewModel(defaults: leftFirstRunDefaults("preview.capture.think.light"))
    model.debugSetState(.processing)
    model.transcriptText = "Remind me to call mom tomorrow at five"
    return NavigationStack {
        CaptureView(model: model)
    }
    .modelContainer(for: Capture.self, inMemory: true)
    .environment(AuthService())
    .preferredColorScheme(.light)
}

#Preview("Capture · success · light") {
    let model = CaptureViewModel(defaults: leftFirstRunDefaults("preview.capture.success.light"))
    model.debugSetState(.success)
    model.transcriptText = "Call mom"
    model.successMessage = "Saved to Reminders · tomorrow 5:00 PM"
    model.successDestination = .reminder
    return NavigationStack {
        CaptureView(model: model)
    }
    .modelContainer(for: Capture.self, inMemory: true)
    .environment(AuthService())
    .preferredColorScheme(.light)
}

#Preview("Capture · confirming · light") {
    let model = CaptureViewModel(defaults: leftFirstRunDefaults("preview.capture.confirm.light"))
    model.debugSetState(.confirming)
    model.pendingIntent = ParsedIntent(
        rawTranscript: "call mom",
        taskText: "call mom",
        destination: .reminder,
        confidence: 0.85
    )
    model.transcriptText = "call mom"
    return NavigationStack {
        CaptureView(model: model)
    }
    .modelContainer(for: Capture.self, inMemory: true)
    .environment(AuthService())
    .preferredColorScheme(.light)
}

private func leftFirstRunDefaults(_ suite: String) -> UserDefaults {
    let defaults = UserDefaults(suiteName: suite)!
    defaults.set(true, forKey: CaptureFirstRun.defaultsKey)
    return defaults
}
