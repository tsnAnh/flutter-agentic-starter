import AVFoundation
import Foundation

struct RecordedAudio {
    let url: URL
    let durationMillis: Int64
}

protocol AudioRecorderService {
    func prepare() async throws
    func start() async throws
    func stop() throws -> RecordedAudio
    func cancel()
}

final class AVAudioRecorderService: NSObject, AudioRecorderService {
    private var recorder: AVAudioRecorder?
    private var startDate: Date?
    private var currentURL: URL?
    private var isSessionReady = false

    func prepare() async throws {
        guard await requestPermission() else {
            throw VoicePipelineError.microphoneDenied
        }
        try configureSessionIfNeeded()
    }

    func start() async throws {
        try await prepare()

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("voice-note-\(UUID().uuidString).wav")
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 16_000,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
        ]
        let recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder.isMeteringEnabled = true
        recorder.prepareToRecord()
        guard recorder.record() else {
            throw VoicePipelineError.recordingUnavailable
        }

        self.recorder = recorder
        self.startDate = Date()
        self.currentURL = url
    }

    func stop() throws -> RecordedAudio {
        guard let recorder, let startDate, let currentURL else {
            throw VoicePipelineError.recordingUnavailable
        }
        recorder.stop()
        self.recorder = nil
        self.startDate = nil
        self.currentURL = nil
        let duration = max(0, Date().timeIntervalSince(startDate))
        return RecordedAudio(url: currentURL, durationMillis: Int64(duration * 1000))
    }

    func cancel() {
        recorder?.stop()
        recorder?.deleteRecording()
        recorder = nil
        startDate = nil
        currentURL = nil
    }

    private func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { allowed in
                continuation.resume(returning: allowed)
            }
        }
    }

    private func configureSessionIfNeeded() throws {
        guard !isSessionReady else { return }
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker, .allowBluetoothHFP])
        try session.setActive(true)
        isSessionReady = true
    }
}
