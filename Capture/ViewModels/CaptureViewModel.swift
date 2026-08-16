import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class CaptureViewModel {
    var state: CaptureState = .signedOut
    /// Last-known confirm-before-save. Default on. Cache first; remote is best-effort.
    var alwaysConfirm: Bool = SettingsRepository.defaultAlwaysConfirm
    var transcriptText = ""
    var transcriptPartial = ""
    var speechFact: String?
    /// 0…1 while listening. Bloom smooths; this is the latest normalised RMS, never stored.
    var listenLevel: CGFloat = 0
    /// Classified intent on the confirmation sheet or while clarifying. Nil in idle.
    var pendingIntent: ParsedIntent?
    var successMessage: String?
    var successDestination: CaptureDestination?

    private let settingsSync: SettingsSyncing
    private let speech: SpeechServicing
    private let permissions: PermissionsServicing
    private let parser: ParsingServicing
    private let classifier: ClassificationServicing
    private let eventKit: EventKitServicing
    private let synth: SpeechSynthServicing
    private var modelContext: ModelContext?
    private var isStartingListen = false
    private var listenStartTask: Task<Void, Never>?
    private var saveTask: Task<Void, Never>?
    private var speakTask: Task<Void, Never>?
    private var successTask: Task<Void, Never>?
    private var lastSave: LastSave?
    private let undoWindow: TimeInterval
    /// Spec: one spoken clarification, then confirmation.
    private var usedClarificationLoop = false
    private var isClarificationListen = false
    var clarificationAnswer: String?

    /// Full-screen clarify while speaking, listening for the answer, or thinking.
    var showsClarification: Bool {
        guard pendingIntent != nil, usedClarificationLoop else { return false }
        switch state {
        case .clarifying, .listening, .processing:
            return true
        default:
            return false
        }
    }

    init(
        settingsSync: SettingsSyncing = SettingsSyncService(),
        speech: SpeechServicing = SpeechService(),
        permissions: PermissionsServicing = PermissionsService(),
        parser: ParsingServicing = ParsingService(),
        classifier: ClassificationServicing = ClassificationService(),
        eventKit: EventKitServicing = EventKitService(),
        synth: SpeechSynthServicing = SpeechSynthService(),
        modelContext: ModelContext? = nil,
        undoWindow: TimeInterval = MurmurMotion.undoWindow
    ) {
        self.settingsSync = settingsSync
        self.speech = speech
        self.permissions = permissions
        self.parser = parser
        self.classifier = classifier
        self.eventKit = eventKit
        self.synth = synth
        self.modelContext = modelContext
        self.undoWindow = undoWindow
        self.speech.onTranscriptChange = { [weak self] in
            self?.pullTranscript()
        }
        self.speech.onTurnEnded = { [weak self] in
            self?.speechTurnEnded()
        }
        self.speech.onLevelChange = { [weak self] level in
            self?.listenLevel = CGFloat(level)
        }
    }

    func attachHistory(_ context: ModelContext) {
        modelContext = context
    }

    /// Session 21: capture states are unreachable without a session.
    /// Session 22: load cached `always_confirm` synchronously so capture never waits on the network.
    func applySession(isSignedIn: Bool) {
        if isSignedIn {
            if state == .signedOut {
                state = .idle
            }
            settingsSync.loadCached()
            alwaysConfirm = settingsSync.alwaysConfirm
        } else {
            cancelListening()
            settingsSync.cancelPendingUpsert()
            state = .signedOut
            alwaysConfirm = SettingsRepository.defaultAlwaysConfirm
            speechFact = nil
            transcriptText = ""
            transcriptPartial = ""
            listenLevel = 0
            pendingIntent = nil
            clarificationAnswer = nil
            usedClarificationLoop = false
            isClarificationListen = false
            successTask?.cancel()
            lastSave = nil
            successMessage = nil
            successDestination = nil
            synth.stop()
        }
    }

    /// Background fetch. Does not block capture. Failures leave the cache as-is.
    func refreshSettingsFromRemote() async {
        guard canCapture else { return }
        do {
            try await settingsSync.fetchRemote()
            alwaysConfirm = settingsSync.alwaysConfirm
        } catch {
            alwaysConfirm = settingsSync.alwaysConfirm
        }
    }

    func setAlwaysConfirm(_ value: Bool) {
        settingsSync.setAlwaysConfirm(value)
        alwaysConfirm = settingsSync.alwaysConfirm
    }

    /// Listening and later capture actions must no-op while signed out.
    var canCapture: Bool {
        state != .signedOut
    }

    func tapWell() {
        guard canCapture, !isStartingListen else { return }
        guard state == .idle || state == .clarifying || state == .success else { return }
        guard speech.isOnDeviceAvailable else { return }
        if state == .success {
            leaveSuccessKeepingSave()
        }
        if state == .clarifying {
            speakTask?.cancel()
            synth.stop()
            pendingIntent = nil
            speechFact = nil
            clarificationAnswer = nil
            usedClarificationLoop = false
            isClarificationListen = false
        }
        isStartingListen = true
        speechFact = nil
        listenStartTask = Task {
            await startListening()
            isStartingListen = false
        }
    }

    /// Shortcut / intent: start listening when idle. Leaves the flag armed if capture cannot start yet.
    @discardableResult
    func applyQuickCaptureIfPending() -> Bool {
        guard canCapture, QuickCaptureFlag.isArmed else { return false }
        switch state {
        case .listening:
            QuickCaptureFlag.consume()
            return true
        case .idle, .success, .clarifying:
            QuickCaptureFlag.consume()
            tapWell()
            return true
        default:
            return false
        }
    }

    func flushPendingListen() async {
        await listenStartTask?.value
    }

    func flushPendingSave() async {
        await saveTask?.value
    }

    func flushPendingSpeak() async {
        await speakTask?.value
    }

    func flushPendingSuccess() async {
        await successTask?.value
    }

    func cancelListening() {
        speakTask?.cancel()
        synth.stop()
        guard state == .listening else { return }
        speech.stop()
        listenLevel = 0
        isClarificationListen = false
        if pendingIntent != nil, usedClarificationLoop {
            state = .clarifying
            LoggingPolicy.log(.captureState(.clarifying), category: .capture)
            return
        }
        state = .idle
        LoggingPolicy.log(.captureState(.idle), category: .capture)
    }

    private func startListening() async {
        await permissions.request(.microphone)
        await permissions.request(.speech)
        permissions.refresh()
        if permissions.microphone == .needed || permissions.speech == .needed {
            speechFact = SpeechCopy.notAllowedYet
            return
        }
        transcriptText = ""
        transcriptPartial = ""
        listenLevel = 0
        do {
            try await speech.start()
            state = .listening
            LoggingPolicy.log(.captureState(.listening), category: .capture)
        } catch {
            if pendingIntent != nil, usedClarificationLoop {
                state = .clarifying
                LoggingPolicy.log(.captureState(.clarifying), category: .capture)
            } else {
                state = .idle
            }
            if let speechError = error as? SpeechServiceError {
                speechFact = SpeechCopy.fact(for: speechError)
            } else {
                speechFact = SpeechCopy.notAllowedYet
            }
        }
    }

    private func pullTranscript() {
        transcriptText = speech.committedText
        transcriptPartial = speech.partialText
    }

    private func speechTurnEnded() {
        pullTranscript()
        listenLevel = 0
        let spoken = transcriptText.trimmingCharacters(in: .whitespacesAndNewlines)
        if isClarificationListen {
            finishClarificationListen(spoken: spoken)
            return
        }
        if spoken.isEmpty {
            transcriptText = ""
            transcriptPartial = ""
            speechFact = SpeechCopy.nothingCaptured
            state = .idle
            LoggingPolicy.log(.captureState(.idle), category: .capture)
            return
        }
        transcriptPartial = ""
        state = .processing
        LoggingPolicy.log(.captureState(.processing), category: .capture)
        saveTask = Task { await finishCapture(spoken: spoken) }
    }

    /// Session 72: skip the sheet when confirm-before-save is off and the parse is confident.
    private func finishCapture(spoken: String) async {
        let classified = classifier.classify(parser.parse(spoken))
        transcriptText = classified.taskText
        if classified.needsClarification || classified.confidence < 0.5 || classified.destination == nil {
            if usedClarificationLoop {
                pendingIntent = classified
                speechFact = nil
                state = .confirming
                LoggingPolicy.log(.captureState(.confirming), category: .capture)
                return
            }
            beginClarifying(classified)
            return
        }
        guard let destination = classified.destination else { return }
        pendingIntent = classified
        speechFact = nil
        if alwaysConfirm {
            state = .confirming
            LoggingPolicy.log(.captureState(.confirming), category: .capture)
            return
        }
        await save(classified, destination: destination)
    }

    private func beginClarifying(_ classified: ParsedIntent) {
        pendingIntent = classified
        clarificationAnswer = nil
        usedClarificationLoop = true
        let question = ClarifyCopy.question(for: classified)
        speechFact = question
        state = .clarifying
        LoggingPolicy.log(.captureState(.clarifying), category: .capture)
        speakTask = Task { await speakThenListen(question) }
    }

    /// Playback, then record. Never both. One loop only.
    private func speakThenListen(_ question: String) async {
        await synth.speak(question)
        guard !Task.isCancelled, canCapture, state == .clarifying else { return }
        isClarificationListen = true
        await startListening()
        if state != .listening {
            isClarificationListen = false
        }
    }

    private func finishClarificationListen(spoken: String) {
        isClarificationListen = false
        listenLevel = 0
        if spoken.isEmpty {
            transcriptText = ""
            transcriptPartial = ""
            if let pending = pendingIntent {
                speechFact = ClarifyCopy.question(for: pending)
            }
            state = .clarifying
            LoggingPolicy.log(.captureState(.clarifying), category: .capture)
            return
        }
        clarificationAnswer = spoken
        guard let pending = pendingIntent else { return }
        let merged = ClarificationMerge.merging(spoken, into: pending, parser: parser)
        let classified = classifier.classify(merged)
        pendingIntent = classified
        transcriptText = classified.taskText
        transcriptPartial = ""
        speechFact = nil
        state = .confirming
        LoggingPolicy.log(.captureState(.confirming), category: .capture)
    }

    func tapClarificationAnswer(_ answer: String) {
        let trimmed = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard canCapture, pendingIntent != nil, usedClarificationLoop, !trimmed.isEmpty else { return }
        speakTask?.cancel()
        synth.stop()
        speech.stop()
        finishClarificationListen(spoken: trimmed)
    }

    func startOver() {
        guard canCapture else { return }
        speakTask?.cancel()
        synth.stop()
        speech.stop()
        listenLevel = 0
        pendingIntent = nil
        clarificationAnswer = nil
        usedClarificationLoop = false
        isClarificationListen = false
        speechFact = nil
        transcriptText = ""
        transcriptPartial = ""
        state = .idle
        LoggingPolicy.log(.captureState(.idle), category: .capture)
    }

    func confirmSave() async {
        guard state == .confirming, var intent = pendingIntent, let destination = intent.destination else {
            return
        }
        intent.taskText = intent.taskText.trimmingCharacters(in: .whitespacesAndNewlines)
        pendingIntent = intent
        await save(intent, destination: destination)
    }

    func confirmCancel() {
        guard state == .confirming else { return }
        pendingIntent = nil
        clarificationAnswer = nil
        usedClarificationLoop = false
        transcriptText = ""
        transcriptPartial = ""
        speechFact = nil
        state = .idle
        LoggingPolicy.log(.captureState(.idle), category: .capture)
    }

    private func save(_ intent: ParsedIntent, destination: CaptureDestination) async {
        state = .saving
        LoggingPolicy.log(.captureState(.saving), category: .capture)
        do {
            if destination == .reminder {
                await permissions.request(.reminders)
            } else {
                await permissions.request(.calendar)
            }
            let identifier: String
            switch destination {
            case .reminder:
                identifier = try await eventKit.createReminder(
                    title: intent.taskText,
                    due: intent.date,
                    hasExplicitTime: intent.hasExplicitTime
                )
            case .event:
                guard let start = intent.date else { throw EventKitServiceError.missingStart }
                identifier = try await eventKit.createEvent(
                    title: intent.taskText,
                    start: start,
                    durationMinutes: intent.durationMinutes
                )
            }
            let captureID = try persistHistory(intent, destination: destination, identifier: identifier)
            pendingIntent = nil
            clarificationAnswer = nil
            usedClarificationLoop = false
            speechFact = nil
            beginSuccess(
                captureID: captureID,
                identifier: identifier,
                destination: destination,
                date: intent.date,
                hasExplicitTime: intent.hasExplicitTime
            )
        } catch let error as EventKitServiceError {
            pendingIntent = nil
            clarificationAnswer = nil
            usedClarificationLoop = false
            speechFact = destination == .event
                ? EventKitCopy.eventFact(for: error)
                : EventKitCopy.reminderFact(for: error)
            state = .idle
            LoggingPolicy.log(.captureState(.idle), category: .capture)
        } catch {
            pendingIntent = nil
            clarificationAnswer = nil
            usedClarificationLoop = false
            speechFact = destination == .event
                ? EventKitCopy.calendarAccessNeeded
                : EventKitCopy.remindersAccessNeeded
            state = .idle
            LoggingPolicy.log(.captureState(.idle), category: .capture)
        }
    }

    private func persistHistory(
        _ intent: ParsedIntent,
        destination: CaptureDestination,
        identifier: String
    ) throws -> UUID? {
        guard let modelContext else { return nil }
        let row = Capture(
            title: intent.taskText,
            destination: destination,
            startDate: intent.date,
            hasExplicitTime: intent.hasExplicitTime,
            durationMinutes: intent.durationMinutes,
            eventKitIdentifier: identifier
        )
        modelContext.insert(row)
        try modelContext.saveAndPurgeHistory()
        return row.id
    }

    private func beginSuccess(
        captureID: UUID?,
        identifier: String,
        destination: CaptureDestination,
        date: Date?,
        hasExplicitTime: Bool
    ) {
        lastSave = LastSave(
            captureID: captureID,
            eventKitIdentifier: identifier,
            destination: destination
        )
        successDestination = destination
        successMessage = SuccessCopy.message(
            destination: destination,
            date: date,
            hasExplicitTime: hasExplicitTime
        )
        state = .success
        LoggingPolicy.log(.captureState(.success), category: .capture)
        successTask?.cancel()
        successTask = Task { [undoWindow] in
            let nanos = UInt64(max(0, undoWindow) * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanos)
            guard !Task.isCancelled else { return }
            finishSuccessWindow()
        }
    }

    func undoSave() async {
        guard state == .success, let save = lastSave else { return }
        successTask?.cancel()
        do {
            if let context = modelContext, let captureID = save.captureID {
                let id = captureID
                var descriptor = FetchDescriptor<Capture>(
                    predicate: #Predicate { $0.id == id }
                )
                descriptor.fetchLimit = 1
                if let row = try context.fetch(descriptor).first {
                    try await HistoryDelete.apply(
                        row,
                        scope: .alsoExternal,
                        context: context,
                        eventKit: eventKit
                    )
                } else {
                    try await eventKit.deleteItem(identifier: save.eventKitIdentifier)
                }
            } else {
                try await eventKit.deleteItem(identifier: save.eventKitIdentifier)
            }
            finishSuccessWindow()
        } catch let error as EventKitServiceError {
            speechFact = EventKitCopy.openFact(for: error, destination: save.destination)
            finishSuccessWindow()
        } catch {
            speechFact = HistoryCopy.deleteNeeded
            finishSuccessWindow()
        }
    }

    private func leaveSuccessKeepingSave() {
        successTask?.cancel()
        lastSave = nil
        successMessage = nil
        successDestination = nil
    }

    private func finishSuccessWindow() {
        lastSave = nil
        successMessage = nil
        successDestination = nil
        transcriptText = ""
        transcriptPartial = ""
        guard state == .success else { return }
        state = .idle
        LoggingPolicy.log(.captureState(.idle), category: .capture)
    }

    #if DEBUG
    func debugSetState(_ state: CaptureState) {
        self.state = state
    }

    func debugArmClarificationLoop() {
        usedClarificationLoop = true
    }
    #endif
}

private struct LastSave {
    var captureID: UUID?
    var eventKitIdentifier: String
    var destination: CaptureDestination
}
