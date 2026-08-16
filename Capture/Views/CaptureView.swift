import SwiftUI
import SwiftData

/// Capture home. Tap the well to listen; live words sit above. The well follows mic level.
struct CaptureView: View {
    @Bindable var model: CaptureViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var showSettings = false
    @State private var showHistory = false

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
                VStack(spacing: 0) {
                    chrome
                    VStack(spacing: MurmurSpace.space9) {
                        transcriptSlot
                        CaptureBloom(
                            state: bloomState,
                            level: model.state == .listening ? model.listenLevel : 0,
                            size: 240,
                            label: caption,
                            onTap: { model.tapWell() }
                        )
                        .allowsHitTesting(canUseWell)
                        Color.clear
                            .frame(height: 18)
                            .accessibilityHidden(true)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, MurmurSpace.gutterScreen)
                    .padding(.bottom, MurmurSpace.space10)
                }
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
        .overlay {
            if model.state == .confirming, model.pendingIntent != nil {
                ConfirmationView(
                    intent: pendingIntentBinding,
                    onSave: { Task { await model.confirmSave() } },
                    onCancel: { model.confirmCancel() }
                )
            }
        }
        .safeAreaInset(edge: .bottom) {
            if model.state == .success, let message = model.successMessage {
                SuccessBar(
                    message: message,
                    destination: model.successDestination ?? .reminder,
                    onUndo: { Task { await model.undoSave() } }
                )
                .padding(.horizontal, MurmurSpace.gutterScreen)
                .padding(.bottom, MurmurSpace.space4)
            }
        }
        .onAppear {
            model.attachHistory(modelContext)
        }
        .onDisappear {
            model.cancelListening()
        }
    }

    private var chrome: some View {
        HStack {
            MurmurIconButton(name: .list, label: "History") {
                showHistory = true
            }
            Spacer(minLength: 0)
            Wordmark(size: 19, tone: .tertiary, showsDot: false)
            Spacer(minLength: 0)
            MurmurIconButton(name: .settings, label: "Settings") {
                showSettings = true
            }
        }
        .padding(.horizontal, MurmurSpace.space4)
    }

    private var transcriptSlot: some View {
        ZStack(alignment: .bottom) {
            Color.clear
                .frame(minHeight: 108)
                .frame(maxWidth: .infinity)
            if showsTranscript {
                TranscriptView(
                    text: model.transcriptText,
                    partial: model.transcriptPartial
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
        case .listening: return "Listening"
        case .processing, .saving: return "One moment"
        case .success: return SuccessCopy.caption
        case .clarifying: return model.speechFact ?? ClarifyCopy.quietHint
        default: return "Tap to speak"
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

#Preview("Capture · idle · light") {
    let model = CaptureViewModel()
    model.state = .idle
    return NavigationStack {
        CaptureView(model: model)
    }
    .modelContainer(for: Capture.self, inMemory: true)
    .environment(AuthService())
    .preferredColorScheme(.light)
}

#Preview("Capture · idle · dark") {
    let model = CaptureViewModel()
    model.state = .idle
    return NavigationStack {
        CaptureView(model: model)
    }
    .modelContainer(for: Capture.self, inMemory: true)
    .environment(AuthService())
    .preferredColorScheme(.dark)
}

#Preview("Capture · listening · light") {
    let model = CaptureViewModel()
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
    let model = CaptureViewModel()
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

#Preview("Capture · confirming · light") {
    let model = CaptureViewModel()
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
