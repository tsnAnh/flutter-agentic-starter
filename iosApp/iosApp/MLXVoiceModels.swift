import AVFoundation
import Foundation
import HuggingFace
import MLXAudioCore
import MLXAudioSTT
import MLXHuggingFace
import MLXLLM
import MLXLMCommon
import Shared
import Tokenizers

struct GeneratedNoteContent {
    let title: String
    let summary: String
    let checklist: [String]

    static func fallback(from transcript: String) -> GeneratedNoteContent {
        let words = transcript.split(separator: " ").prefix(6).joined(separator: " ")
        let title = words.isEmpty ? "Voice note" : words
        return GeneratedNoteContent(title: title, summary: String(transcript.prefix(240)), checklist: [])
    }
}

protocol SpeechTranscriber: AnyObject {
    var onStatus: ((String) -> Void)? { get set }
    var onDownloadProgress: ((Double?) -> Void)? { get set }

    func transcribe(audioURL: URL) async throws -> String
    func unload()
}

protocol NoteDraftGenerator: AnyObject {
    var onStatus: ((String) -> Void)? { get set }
    var onDownloadProgress: ((Double?) -> Void)? { get set }

    func generateNote(from transcript: String) async throws -> GeneratedNoteContent
    func reviseNote(_ note: VoiceNote, with correction: String) async throws -> GeneratedNoteContent
    func unload()
}

final class MLXSpeechTranscriber: SpeechTranscriber {
    var onStatus: ((String) -> Void)?
    var onDownloadProgress: ((Double?) -> Void)?
    private var model: Qwen3ASRModel?
    private let modelID = "mlx-community/Qwen3-ASR-0.6B-4bit"
    private let minimumAudioSeconds = 0.35

    func transcribe(audioURL: URL) async throws -> String {
        onStatus?("Preparing voice model")
        let model = try await loadModel()
        onStatus?("Processing audio")
        try validateAudioFile(audioURL, sampleRate: model.sampleRate)
        let (_, audio) = try loadAudioArray(from: audioURL, sampleRate: model.sampleRate)
        guard audio.size >= Int(Double(model.sampleRate) * minimumAudioSeconds) else {
            throw VoicePipelineError.recordingTooShort
        }
        return model.generate(audio: audio, language: "English").text
    }

    private func loadModel() async throws -> Qwen3ASRModel {
        if let model { return model }
        guard let repoID = Repo.ID(rawValue: modelID) else { throw VoicePipelineError.modelUnavailable }
        let hfToken = ProcessInfo.processInfo.environment["HF_TOKEN"]
            ?? Bundle.main.object(forInfoDictionaryKey: "HF_TOKEN") as? String
        let cache = HubCache.default
        let client: HubClient
        if let hfToken = hfToken, !hfToken.isEmpty {
            client = HubClient(host: HubClient.defaultHost, bearerToken: hfToken, cache: cache)
        } else {
            client = HubClient(cache: cache)
        }
        defer { onDownloadProgress?(nil) }
        let modelDir = try await ModelUtils.resolveOrDownloadModel(
            client: client,
            cache: cache,
            repoID: repoID,
            requiredExtension: "safetensors"
        ) { [weak self] progress in
            self?.onStatus?("Downloading voice models")
            self?.onDownloadProgress?(progress.fractionCompleted.clampedProgress)
        }
        let loaded = try await Qwen3ASRModel.fromModelDirectory(modelDir)
        model = loaded
        return loaded
    }

    private func validateAudioFile(_ url: URL, sampleRate: Int) throws {
        let file = try AVAudioFile(forReading: url)
        let seconds = Double(file.length) / file.fileFormat.sampleRate
        guard file.length > 0, seconds >= minimumAudioSeconds else {
            throw VoicePipelineError.recordingTooShort
        }
    }

    func unload() {
        model = nil
    }
}

final class QwenNoteDraftGenerator: NoteDraftGenerator {
    var onStatus: ((String) -> Void)?
    var onDownloadProgress: ((Double?) -> Void)?
    private let modelID = "mlx-community/Qwen3.5-0.8B-MLX-4bit"
    private var container: ModelContainer?

    func generateNote(from transcript: String) async throws -> GeneratedNoteContent {
        onStatus?("Preparing note")
        let container = try await loadContainer()
        onStatus?("Preparing note")
        let session = ChatSession(
            container,
            instructions: "Convert transcripts into concise personal notes. Return only JSON.",
            generateParameters: GenerateParameters(maxTokens: 260, temperature: 0.2)
        )
        let response = try await session.respond(to: prompt(for: transcript))
        return parse(response, fallback: transcript)
    }

    func reviseNote(_ note: VoiceNote, with correction: String) async throws -> GeneratedNoteContent {
        onStatus?("Rewriting note")
        let container = try await loadContainer()
        let session = ChatSession(
            container,
            instructions: "Revise personal notes from corrections. Return only JSON.",
            generateParameters: GenerateParameters(maxTokens: 280, temperature: 0.2)
        )
        let response = try await session.respond(to: revisePrompt(note, correction: correction))
        return parse(response, fallback: correction)
    }

    private func loadContainer() async throws -> ModelContainer {
        if let container { return container }
        let config = ModelConfiguration(
            id: modelID,
            extraEOSTokens: ["<|im_end|>", "<|endoftext|>"]
        )
        defer { onDownloadProgress?(nil) }
        let loaded = try await #huggingFaceLoadModelContainer(configuration: config) { [weak self] progress in
            self?.onStatus?("Downloading voice models")
            self?.onDownloadProgress?(progress.fractionCompleted.clampedProgress)
        }
        container = loaded
        return loaded
    }

    private func prompt(for transcript: String) -> String {
        """
        Make a voice note from this transcript.
        Return compact JSON: {"title":"...", "summary":"...", "checklist":["..."]}.
        Title max 6 words. Summary max 2 short sentences.
        Checklist max 5 action items. Use [] if there are no clear actions.

        Transcript:
        \(transcript)
        """
    }

    private func revisePrompt(_ note: VoiceNote, correction: String) -> String {
        """
        Update this note using the correction. Preserve useful details.
        Return compact JSON: {"title":"...", "summary":"...", "checklist":["..."]}.
        Title max 6 words. Summary max 2 short sentences. Checklist max 5 action items.

        Current title:
        \(note.title)

        Current summary:
        \(note.summary)

        Current checklist:
        \(note.checklist.joined(separator: "\n"))

        Correction:
        \(correction)
        """
    }

    private func parse(_ response: String, fallback transcript: String) -> GeneratedNoteContent {
        let json = response.trimmedJSONFragment()
        if let data = json.data(using: .utf8),
           let decoded = try? JSONDecoder().decode(NoteJSON.self, from: data),
           !decoded.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return GeneratedNoteContent(
                title: decoded.title,
                summary: decoded.summary,
                checklist: decoded.checklist?.cleanedChecklist ?? []
            )
        }
        return .fallback(from: transcript)
    }

    private struct NoteJSON: Decodable {
        let title: String
        let summary: String
        let checklist: [String]?
    }

    func unload() {
        container = nil
    }
}

private extension String {
    func trimmedJSONFragment() -> String {
        guard let start = firstIndex(of: "{"), let end = lastIndex(of: "}") else { return self }
        return String(self[start...end])
    }
}

private extension Double {
    var clampedProgress: Double {
        min(1, max(0, self))
    }
}

private extension [String] {
    var cleanedChecklist: [String] {
        prefix(5).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }
}
