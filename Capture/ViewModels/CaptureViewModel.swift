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
    /// One turn that held several captures, each awaiting a destination. Empty unless routing.
    var pendingItems: [RoutedItem] = []
    var successMessage: String?
    var successDestination: CaptureDestination?
    /// Quiet fact when settings could not refresh. Capture still works.
    var settingsFact: String?

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
    /// Everything written by the last save, so Undo can take back all of it, not just the last item.
    private var lastSaves: [LastSave] = []
    private let undoWindow: TimeInterval
    private let defaults: UserDefaults
    private(set) var hasLeftFirstRun: Bool
    /// Spec: one spoken clarification, then confirmation.
    private var usedClarificationLoop = false
    private var isClarificationListen = false
    var clarificationAnswer: String?

    /// Full-screen routing while a multi-part turn waits on destinations.
    var showsRouting: Bool {
        state == .routing && !pendingItems.isEmpty
    }

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
        defaults: UserDefaults = .standard,
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
        self.defaults = defaults
        self.hasLeftFirstRun = defaults.bool(forKey: CaptureFirstRun.defaultsKey)
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
            pendingItems = []
            clarificationAnswer = nil
            usedClarificationLoop = false
            isClarificationListen = false
            successTask?.cancel()
            lastSaves = []
            successMessage = nil
            successDestination = nil
            settingsFact = nil
            synth.stop()
        }
    }

    /// Background fetch. Does not block capture. Failures leave the cache as-is.
    func refreshSettingsFromRemote() async {
        guard canCapture else { return }
        do {
            try await settingsSync.fetchRemote()
            alwaysConfirm = settingsSync.alwaysConfirm
            settingsFact = nil
        } catch {
            alwaysConfirm = settingsSync.alwaysConfirm
            settingsFact = SettingsCopy.usingThisPhone
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

    /// Kit first-run until the well has started a listen on this install.
    var showsFirstRun: Bool {
        canCapture && state == .idle && !hasLeftFirstRun
    }

    /// True while a list is in progress, so the screen can explain the longer pause.
    var isWaitingForMore: Bool {
        state == .listening
            && ContinuationPhrase.suggestsMore(transcriptText + " " + transcriptPartial)
    }

    func tapWell() {
        guard canCapture, !isStartingListen else { return }
        if state == .listening {
            endListeningByTap()
            return
        }
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

    /// Tapping the well while it listens ends the turn there and then. Whatever was already heard is
    /// kept and processed; an empty turn simply returns to idle. Nothing the user said is thrown away.
    private func endListeningByTap() {
        listenLevel = 0
        speech.endTurn()
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
            hasLeftFirstRun = true
            defaults.set(true, forKey: CaptureFirstRun.defaultsKey)
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
        if !usedClarificationLoop, let items = routedItems(from: spoken) {
            beginRouting(items)
            return
        }
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

    /// Nil when the turn is a single capture, so the existing one-item path is untouched.
    private func routedItems(from spoken: String) -> [RoutedItem]? {
        let segments = TranscriptSplitter.segments(spoken)
        guard segments.count > 1 else { return nil }
        let items = segments
            .map { RoutedItem(intent: classifier.classify(parser.parse($0))) }
            .filter { !$0.title.isEmpty }
        return items.count > 1 ? items : nil
    }

    private func beginRouting(_ items: [RoutedItem]) {
        pendingItems = items
        pendingIntent = nil
        speechFact = nil
        transcriptPartial = ""
        state = .routing
        LoggingPolicy.log(.captureState(.routing), category: .capture)
    }

    func setDestination(_ destination: CaptureDestination, for id: RoutedItem.ID) {
        guard let index = pendingItems.firstIndex(where: { $0.id == id }) else { return }
        pendingItems[index].destination = destination
    }

    func routingCancel() {
        guard state == .routing else { return }
        pendingItems = []
        transcriptText = ""
        transcriptPartial = ""
        speechFact = nil
        state = .idle
        LoggingPolicy.log(.captureState(.idle), category: .capture)
    }

    /// Saves every routed item. Partial success still lands, and Undo takes back whatever was written.
    func confirmRoutedSave() async {
        guard state == .routing, pendingItems.allRouted else { return }
        let items = pendingItems
        state = .saving
        LoggingPolicy.log(.captureState(.saving), category: .capture)

        var saves: [LastSave] = []
        var lastError: String?
        for item in items {
            guard let destination = item.destination else { continue }
            var intent = item.intent
            intent.taskText = item.title
            do {
                saves.append(try await performSave(intent, destination: destination))
            } catch let error as EventKitServiceError {
                lastError = destination == .event
                    ? EventKitCopy.eventFact(for: error)
                    : EventKitCopy.reminderFact(for: error)
            } catch {
                lastError = destination == .event
                    ? EventKitCopy.calendarAccessNeeded
                    : EventKitCopy.remindersAccessNeeded
            }
        }

        pendingItems = []
        pendingIntent = nil
        usedClarificationLoop = false
        clarificationAnswer = nil

        guard let first = saves.first else {
            speechFact = lastError ?? EventKitCopy.remindersAccessNeeded
            state = .idle
            LoggingPolicy.log(.captureState(.idle), category: .capture)
            return
        }
        speechFact = lastError
        beginSuccess(
            saves: saves,
            destination: first.destination,
            message: RoutingCopy.savedMessage(saves.count)
        )
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
        pendingItems = []
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

    /// Writes one item to EventKit and history. Shared by the single and multi-capture paths.
    private func performSave(
        _ intent: ParsedIntent,
        destination: CaptureDestination
    ) async throws -> LastSave {
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
        return LastSave(
            captureID: captureID,
            eventKitIdentifier: identifier,
            destination: destination
        )
    }

    private func save(_ intent: ParsedIntent, destination: CaptureDestination) async {
        state = .saving
        LoggingPolicy.log(.captureState(.saving), category: .capture)
        do {
            let save = try await performSave(intent, destination: destination)
            pendingIntent = nil
            clarificationAnswer = nil
            usedClarificationLoop = false
            speechFact = nil
            beginSuccess(
                saves: [save],
                destination: destination,
                message: SuccessCopy.message(
                    destination: destination,
                    date: intent.date,
                    hasExplicitTime: intent.hasExplicitTime
                )
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
        saves: [LastSave],
        destination: CaptureDestination,
        message: String
    ) {
        lastSaves = saves
        successDestination = destination
        successMessage = message
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

    /// Takes back everything the last save wrote. One failure does not strand the rest.
    func undoSave() async {
        guard state == .success, !lastSaves.isEmpty else { return }
        successTask?.cancel()
        let saves = lastSaves
        var fact: String?
        for save in saves {
            do {
                try await undoOne(save)
            } catch let error as EventKitServiceError {
                fact = EventKitCopy.openFact(for: error, destination: save.destination)
            } catch {
                fact = HistoryCopy.deleteNeeded
            }
        }
        speechFact = fact
        finishSuccessWindow()
    }

    private func undoOne(_ save: LastSave) async throws {
        guard let context = modelContext, let captureID = save.captureID else {
            try await eventKit.deleteItem(identifier: save.eventKitIdentifier)
            return
        }
        let id = captureID
        var descriptor = FetchDescriptor<Capture>(predicate: #Predicate { $0.id == id })
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
    }

    private func leaveSuccessKeepingSave() {
        successTask?.cancel()
        lastSaves = []
        successMessage = nil
        successDestination = nil
    }

    private func finishSuccessWindow() {
        lastSaves = []
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
