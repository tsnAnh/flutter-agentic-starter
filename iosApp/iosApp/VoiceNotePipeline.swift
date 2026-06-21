import Foundation
import Shared

enum VoicePipelineError: LocalizedError {
    case microphoneDenied
    case recordingUnavailable
    case recordingTooShort
    case modelUnavailable
    case lowDiskSpace

    var errorDescription: String? {
        switch self {
        case .microphoneDenied: "Microphone permission is required."
        case .recordingUnavailable: "No recording is available."
        case .recordingTooShort: "Record a little longer."
        case .modelUnavailable: "Local voice model is unavailable."
        case .lowDiskSpace: "Not enough free storage to download local models."
        }
    }
}

@MainActor
protocol VoiceNotePipeline {
    var statusText: String { get }
    var modelDownloadProgress: Double? { get }
    func prepareRecording() async throws
    func startRecording() async throws
    func finishRecording() async throws -> VoiceNoteDraft
    func finishEditing(note: VoiceNote) async throws -> VoiceNoteDraft
    func revise(note: VoiceNote, with correction: String) async throws -> VoiceNoteDraft
    func cancelRecording()
}

@MainActor
final class LocalVoiceNotePipeline: ObservableObject, VoiceNotePipeline {
    @Published private(set) var statusText = "Ready"
    @Published private(set) var modelDownloadProgress: Double?

    private let recorder: AudioRecorderService
    private let transcriber: SpeechTranscriber
    private let generator: NoteDraftGenerator
    private let minimumFreeBytes: Int64 = 6_000_000_000

    init(
        recorder: AudioRecorderService = AVAudioRecorderService(),
        transcriber: MLXSpeechTranscriber = MLXSpeechTranscriber(),
        generator: QwenNoteDraftGenerator = QwenNoteDraftGenerator()
    ) {
        self.recorder = recorder
        self.transcriber = transcriber
        self.generator = generator
        transcriber.onStatus = { [weak self] text in Task { @MainActor in self?.statusText = text } }
        generator.onStatus = { [weak self] text in Task { @MainActor in self?.statusText = text } }
        transcriber.onDownloadProgress = { [weak self] progress in Task { @MainActor in self?.modelDownloadProgress = progress } }
        generator.onDownloadProgress = { [weak self] progress in Task { @MainActor in self?.modelDownloadProgress = progress } }
    }

    func prepareRecording() async throws {
        try await recorder.prepare()
    }

    func startRecording() async throws {
        statusText = "Listening"
        modelDownloadProgress = nil
        try await recorder.start()
    }

    func finishRecording() async throws -> VoiceNoteDraft {
        modelDownloadProgress = nil
        try preflightDiskSpace()
        let audio = try recorder.stop()
        defer { transcriber.unload() }
        let transcript = try await transcriber.transcribe(audioURL: audio.url).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !transcript.isEmpty else { throw VoicePipelineError.recordingTooShort }
        let content = try await generatedNoteContent(from: transcript)
        try? FileManager.default.removeItem(at: audio.url)
        modelDownloadProgress = nil
        statusText = "Saved to today"
        return VoiceNoteDraft(
            id: UUID().uuidString,
            title: content.title,
            summary: content.summary,
            transcript: transcript,
            checklist: content.checklist,
            createdAtEpochMillis: Int64(Date().timeIntervalSince1970 * 1000),
            durationMillis: audio.durationMillis,
            source: NoteSource.voice
        )
    }

    func finishEditing(note: VoiceNote) async throws -> VoiceNoteDraft {
        modelDownloadProgress = nil
        try preflightDiskSpace()
        let audio = try recorder.stop()
        defer { transcriber.unload() }
        let correction = try await transcriber.transcribe(audioURL: audio.url).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !correction.isEmpty else { throw VoicePipelineError.recordingTooShort }
        let draft = try await revise(note: note, with: correction, extraDurationMillis: audio.durationMillis)
        try? FileManager.default.removeItem(at: audio.url)
        modelDownloadProgress = nil
        statusText = "Updated note"
        return draft
    }

    func revise(note: VoiceNote, with correction: String) async throws -> VoiceNoteDraft {
        try await revise(note: note, with: correction, extraDurationMillis: 0)
    }

    func cancelRecording() {
        recorder.cancel()
        modelDownloadProgress = nil
        statusText = "Ready"
    }

    private func preflightDiskSpace() throws {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let values = try url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
        if let free = values.volumeAvailableCapacityForImportantUsage, free < minimumFreeBytes {
            throw VoicePipelineError.lowDiskSpace
        }
    }

    private func revise(note: VoiceNote, with correction: String, extraDurationMillis: Int64) async throws -> VoiceNoteDraft {
        let correction = correction.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !correction.isEmpty else { throw VoicePipelineError.recordingTooShort }
        defer { generator.unload() }
        let content = try await generator.reviseNote(note, with: correction)
        return VoiceNoteDraft(
            id: note.id,
            title: content.title,
            summary: content.summary,
            transcript: appendedTranscript(note.transcript, correction: correction),
            checklist: content.checklist,
            createdAtEpochMillis: note.createdAtEpochMillis,
            durationMillis: note.durationMillis + extraDurationMillis,
            source: note.source
        )
    }

    private func appendedTranscript(_ transcript: String, correction: String) -> String {
        let current = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        let edit = "Edit: \(correction)"
        return current.isEmpty ? edit : "\(current)\n\n\(edit)"
    }

    private func generatedNoteContent(from transcript: String) async throws -> GeneratedNoteContent {
        defer { generator.unload() }
        do {
            return try await generator.generateNote(from: transcript)
        } catch {
            statusText = "Saved transcript only"
            return .fallback(from: transcript)
        }
    }
}
