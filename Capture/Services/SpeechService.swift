import AVFoundation
import Foundation
import Speech

enum SpeechServiceError: Error, Equatable {
    case notAuthorized
    case onDeviceUnavailable
    case recognizerUnavailable
}

/// Always on-device. Never flip `requiresOnDeviceRecognition` to get a cloud fallback.
enum SpeechRecognitionPolicy {
    static func makeOnDeviceRequest() -> SFSpeechAudioBufferRecognitionRequest {
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.requiresOnDeviceRecognition = true
        request.shouldReportPartialResults = true
        request.addsPunctuation = true
        return request
    }

    /// `nil` when this locale cannot run on-device. Callers must not then create a network request.
    static func makeOnDeviceRequestIfAvailable(
        locale: Locale = .autoupdatingCurrent
    ) -> SFSpeechAudioBufferRecognitionRequest? {
        guard SpeechLocalePolicy.supportsOnDevice(locale: locale) else { return nil }
        return makeOnDeviceRequest()
    }
}

/// Current (or given) locale must support on-device recognition. No cloud substitute.
enum SpeechLocalePolicy {
    static func supportsOnDevice(locale: Locale = .autoupdatingCurrent) -> Bool {
        SFSpeechRecognizer(locale: locale)?.supportsOnDeviceRecognition == true
    }

    static func onDeviceRecognizer(locale: Locale = .autoupdatingCurrent) throws -> SFSpeechRecognizer {
        guard let recognizer = SFSpeechRecognizer(locale: locale) else {
            throw SpeechServiceError.recognizerUnavailable
        }
        guard recognizer.supportsOnDeviceRecognition else {
            throw SpeechServiceError.onDeviceUnavailable
        }
        return recognizer
    }
}

@MainActor
protocol SpeechServicing: AnyObject {
    var isOnDeviceAvailable: Bool { get }
    var committedText: String { get }
    var partialText: String { get }
    var onTranscriptChange: (() -> Void)? { get set }
    var onTurnEnded: (() -> Void)? { get set }
    var onLevelChange: ((Float) -> Void)? { get set }
    func start() async throws
    func stop()
    /// Ends the turn now, keeping whatever has been heard. Same finish as running out of silence.
    func endTurn()
}

/// On-device buffer stream. Transcript stays in RAM. Silence ~1.5s after last voice ends the turn.
@MainActor
final class SpeechService: SpeechServicing {
    private let audio: AudioSessionManaging
    private let engine = AVAudioEngine()
    private var recognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var silenceTask: Task<Void, Never>?
    private var watch = SilenceWatch()
    /// Finalised utterance segments, in order. Joined to form `committedText`.
    private var accumulator = TranscriptAccumulator()

    private(set) var committedText = ""
    private(set) var partialText = ""
    var onTranscriptChange: (() -> Void)?
    var onTurnEnded: (() -> Void)?
    var onLevelChange: ((Float) -> Void)?

    var isOnDeviceAvailable: Bool {
        SpeechLocalePolicy.supportsOnDevice()
    }

    init(audio: AudioSessionManaging = AudioSessionManager()) {
        self.audio = audio
    }

    func start() async throws {
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            throw SpeechServiceError.notAuthorized
        }
        let recognizer: SFSpeechRecognizer
        do {
            recognizer = try SpeechLocalePolicy.onDeviceRecognizer()
        } catch {
            LoggingPolicy.log(.speechOnDeviceUnavailable, category: .speech)
            throw error
        }
        guard recognizer.isAvailable else {
            LoggingPolicy.log(.speechOnDeviceUnavailable, category: .speech)
            throw SpeechServiceError.onDeviceUnavailable
        }

        stop()
        committedText = ""
        partialText = ""
        accumulator.reset()
        watch = SilenceWatch()
        self.recognizer = recognizer

        guard let request = SpeechRecognitionPolicy.makeOnDeviceRequestIfAvailable() else {
            LoggingPolicy.log(.speechOnDeviceUnavailable, category: .speech)
            throw SpeechServiceError.onDeviceUnavailable
        }
        precondition(request.requiresOnDeviceRecognition)
        self.request = request
        try audio.enterRecordMode()
        try startEngine(appendingTo: request)

        task = Self.makeTask(recognizer: recognizer, request: request) { [weak self] text, isFinal in
            Task { @MainActor in
                self?.apply(text: text, isFinal: isFinal)
            }
        }
        startSilenceWatch()
        LoggingPolicy.log(.speechStream, category: .speech)
    }

    func stop() {
        silenceTask?.cancel()
        silenceTask = nil
        task?.cancel()
        task = nil
        request?.endAudio()
        request = nil
        recognizer = nil
        engine.inputNode.removeTap(onBus: 0)
        if engine.isRunning {
            engine.stop()
        }
        try? audio.deactivate()
        watch = SilenceWatch()
        onLevelChange?(0)
    }

    private func startEngine(appendingTo request: SFSpeechAudioBufferRecognitionRequest) throws {
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.removeTap(onBus: 0)
        Self.installTap(on: input, format: format, appendingTo: request) { [weak self] energy in
            Task { @MainActor in
                self?.heardEnergy(energy)
            }
        }
        engine.prepare()
        try engine.start()
    }

    /// Speech and AVFAudio hand back non-`Sendable` closures. Built inside a `@MainActor` member they would
    /// inherit that isolation and trap when the framework calls them off the main queue, so both are made
    /// here, `nonisolated`, and only `Sendable` values cross back.
    private nonisolated static func makeTask(
        recognizer: SFSpeechRecognizer,
        request: SFSpeechAudioBufferRecognitionRequest,
        onTranscript: @escaping @Sendable (String, Bool) -> Void
    ) -> SFSpeechRecognitionTask {
        recognizer.recognitionTask(with: request) { result, _ in
            guard let result else { return }
            onTranscript(result.bestTranscription.formattedString, result.isFinal)
        }
    }

    private nonisolated static func installTap(
        on input: AVAudioInputNode,
        format: AVAudioFormat,
        appendingTo request: SFSpeechAudioBufferRecognitionRequest,
        onEnergy: @escaping @Sendable (Float) -> Void
    ) {
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
            onEnergy(bufferRMS(buffer))
        }
    }

    private func heardEnergy(_ rms: Float) {
        onLevelChange?(SpeechEnergy.normalizedLevel(rms: rms))
        guard rms >= SpeechEnergy.voiceFloor else { return }
        watch.heardVoice(at: Date())
    }

    /// Speech finalises one result per utterance *segment*, and a pause — exactly the pause after
    /// "then" — starts a new one. Each final carries only its own segment, so these must accumulate;
    /// assigning would keep the last segment and silently drop everything said before it.
    private func apply(text: String, isFinal: Bool) {
        if isFinal {
            appendSegment(text)
        } else {
            partialText = text
        }
        if ContinuationPhrase.suggestsMore(text) {
            watch.allowLongerPause()
        }
        watch.heardVoice(at: Date())
        onTranscriptChange?()
    }

    private func appendSegment(_ text: String) {
        partialText = ""
        accumulator.append(text)
        committedText = accumulator.text
    }

    /// Tap-to-stop. Promotes any partial the recogniser has not finalised, so ending early never
    /// loses the words already on screen.
    func endTurn() {
        silenceTask?.cancel()
        silenceTask = nil
        commitPartialIfNeeded()
        onTranscriptChange?()
        request?.endAudio()
        stopEngineKeepingTranscript()
    }

    /// The tail segment the recogniser never finalised still belongs to the turn.
    private func commitPartialIfNeeded() {
        appendSegment(partialText)
    }

    private func startSilenceWatch() {
        silenceTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                guard let self, !Task.isCancelled else { return }
                if self.watch.shouldStop(now: Date()) {
                    LoggingPolicy.log(.speechSilenceStop, category: .speech)
                    self.commitPartialIfNeeded()
                    self.onTranscriptChange?()
                    self.request?.endAudio()
                    self.stopEngineKeepingTranscript()
                    return
                }
            }
        }
    }

    private func stopEngineKeepingTranscript() {
        silenceTask?.cancel()
        silenceTask = nil
        engine.inputNode.removeTap(onBus: 0)
        if engine.isRunning {
            engine.stop()
        }
        try? audio.deactivate()
        recognizer = nil
        request = nil
        task = nil
        watch = SilenceWatch()
        onLevelChange?(0)
        onTurnEnded?()
    }

    private nonisolated static func bufferRMS(_ buffer: AVAudioPCMBuffer) -> Float {
        guard let channel = buffer.floatChannelData?[0] else { return 0 }
        let count = Int(buffer.frameLength)
        return SpeechEnergy.rms(samples: UnsafeBufferPointer(start: channel, count: count))
    }
}
