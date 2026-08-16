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
            if model.showsClarification {
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

    private var captureHome: some View {
        VStack(spacing: 0) {
            chrome
            VStack(spacing: MurmurSpace.space9) {
                heroSlot
                CaptureBloom(
                    state: bloomState,
                    level: model.state == .listening ? model.listenLevel : 0,
                    size: 240,
                    label: caption,
                    isInteractive: wellInteractive,
                    onTap: { model.tapWell() }
                )
                .allowsHitTesting(wellInteractive)
                bloomFoot
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, MurmurSpace.gutterScreen)
            .padding(.bottom, MurmurSpace.space10)
            successSlot
        }
    }

    private var wellInteractive: Bool {
        canUseWell && !isConfirming && (model.state == .idle || model.state == .success)
    }

    private var chrome: some View {
        HStack {
            MurmurIconButton(name: .list, label: "History") {
                showHistory = true
            }
            Spacer(minLength: 0)
            Wordmark(size: 19, tone: .tertiary, showsDot: false, trackingEm: 0.16)
            Spacer(minLength: 0)
            MurmurIconButton(name: .settings, label: "Settings") {
                showSettings = true
            }
        }
        .padding(.horizontal, MurmurSpace.space4)
    }

    @ViewBuilder
    private var heroSlot: some View {
        if model.showsFirstRun {
            Text(CaptureCopy.firstRunTitle)
                .font(MurmurType.title)
                .tracking(MurmurType.trackingTitle)
                .multilineTextAlignment(.center)
                .foregroundStyle(MurmurColor.textPrimary)
                .frame(maxWidth: 18 * 16, alignment: .center)
                .accessibilityAddTraits(.isHeader)
        } else {
            transcriptSlot
        }
    }

    @ViewBuilder
    private var bloomFoot: some View {
        if model.showsFirstRun {
            Text(CaptureCopy.firstRunFootnote)
                .font(MurmurType.footnote)
                .tracking(MurmurType.trackingFootnote)
                .foregroundStyle(MurmurColor.textTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 26 * 10, alignment: .center)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            Color.clear
                .frame(height: 18)
                .accessibilityHidden(true)
        }
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
