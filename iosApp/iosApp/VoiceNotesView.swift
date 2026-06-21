import KMPObservableViewModelSwiftUI
import Shared
import SwiftUI
import UIKit

private enum RecordingPhase: Equatable {
    case idle
    case pulling
    case recording
    case processing
    case saving
}

private enum VoiceNoteRoute: Hashable {
    case detail(String)
}

struct VoiceNotesView: View {
    private let threshold: CGFloat = 190
    private let fadeEnd: CGFloat = 0.35
    private let orbRadius: CGFloat = 44
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @StateViewModel private var viewModel = KoinDependencies().notesViewModel
    @StateObject private var pipeline = LocalVoiceNotePipeline()
    @State private var phase: RecordingPhase = .idle
    @State private var pull: CGFloat = 0
    @State private var seconds = 0
    @State private var transcript = ""
    @State private var errorMessage: String?
    @State private var path: [VoiceNoteRoute] = []
    @State private var isListAtTop = true
    @State private var processingTask: Task<Void, Never>?

    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geometry in
                ZStack {
                    VoiceNoteTheme.paper.ignoresSafeArea()
                    radialWash.ignoresSafeArea()

                    ThreadLayer(progress: pullProgress, orbRadius: orbRadius)

                    VoiceNotesSheet(
                        notes: viewModel.notes,
                        errorMessage: viewModel.notesErrorMessage ?? errorMessage,
                        sheetOpacity: sheetOpacity,
                        sheetOffset: pull * 0.18,
                        onSelectNote: { path.append(.detail($0.id)) },
                        onScrollAtTopChange: { isListAtTop = $0 }
                    )

                    RecordingChamber(
                        isActive: phase != .idle && phase != .pulling,
                        isProcessing: phase == .processing,
                        isSaving: phase == .saving,
                        seconds: seconds,
                        transcript: transcript,
                        statusText: pipeline.statusText,
                        modelDownloadProgress: pipeline.modelDownloadProgress,
                        onStop: stopAndSave,
                        onCancel: cancelRecording
                    )
                }
                .contentShape(Rectangle())
                .simultaneousGesture(pullGesture)
                .simultaneousGesture(cancelGesture(height: geometry.size.height))
                .onReceive(timer) { _ in
                    if phase == .recording { seconds += 1 }
                }
                .task {
                    await prepareRecording()
                }
            }
            .navigationDestination(for: VoiceNoteRoute.self) { route in
                detailDestination(route)
            }
        }
        .preferredColorScheme(.light)
    }

    private var radialWash: some View {
        RadialGradient(
            colors: [VoiceNoteTheme.mintSoft.opacity(0.9), .clear],
            center: .top,
            startRadius: 20,
            endRadius: 520
        )
    }

    private var pullProgress: CGFloat {
        if phase == .recording || phase == .processing || phase == .saving { return 1 }
        return min(1, pull / threshold)
    }

    private var sheetOpacity: Double {
        phase == .idle || phase == .pulling ? Double(max(0, 1 - pullProgress / fadeEnd)) : 0
    }

    private var pullGesture: some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { value in
                guard phase == .idle || phase == .pulling else { return }
                guard phase == .pulling || isListAtTop else { return }
                let dy = value.translation.height
                guard dy > 0 else {
                    pull = 0
                    return
                }
                phase = .pulling
                pull = damp(dy)
                if pull >= threshold { lockRecording() }
            }
            .onEnded { _ in
                if phase == .pulling { springBack() }
            }
    }

    private func cancelGesture(height: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 24)
            .onEnded { value in
                guard (phase == .recording || phase == .processing), value.translation.height < -70 else { return }
                cancelRecording()
            }
    }

    private func damp(_ dy: CGFloat) -> CGFloat {
        220 * (1 - 1 / (dy / 260 + 1)) * 1.7
    }

    private func lockRecording() {
        guard phase != .recording else { return }
        phase = .recording
        pull = threshold
        seconds = 0
        transcript = ""
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Task {
            do {
                try await pipeline.startRecording()
            } catch {
                errorMessage = error.localizedDescription
                collapse()
            }
        }
    }

    private func stopAndSave() {
        guard phase == .recording else { return }
        phase = .processing
        transcript = ""
        processingTask?.cancel()
        processingTask = Task {
            do {
                let draft = try await pipeline.finishRecording()
                try Task.checkCancellation()
                try await revealTranscript(draft.transcript)
                try Task.checkCancellation()
                phase = .saving
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                viewModel.saveVoiceNote(draft: draft)
                try Task.checkCancellation()
                collapse()
            } catch is CancellationError {
                pipeline.cancelRecording()
            } catch {
                guard !Task.isCancelled else {
                    pipeline.cancelRecording()
                    return
                }
                errorMessage = error.localizedDescription
                pipeline.cancelRecording()
                collapse()
            }
        }
    }

    private func cancelRecording() {
        guard phase == .recording || phase == .processing else { return }
        processingTask?.cancel()
        pipeline.cancelRecording()
        collapse()
    }

    private func springBack() {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.68)) {
            pull = 0
            phase = .idle
        }
    }

    private func collapse() {
        processingTask?.cancel()
        processingTask = nil
        withAnimation(.easeOut(duration: 0.32)) {
            pull = 0
            phase = .idle
            seconds = 0
            transcript = ""
        }
    }

    private func revealTranscript(_ text: String) async throws {
        transcript = ""
        let words = text.firstSentence.split(separator: " ")
        for start in stride(from: 0, to: words.count, by: 3) {
            try Task.checkCancellation()
            let end = min(start + 3, words.count)
            transcript = words.prefix(end).joined(separator: " ")
            try await Task.sleep(for: .milliseconds(110))
        }
    }

    private func prepareRecording() async {
        do {
            try await pipeline.prepareRecording()
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @ViewBuilder
    private func detailDestination(_ route: VoiceNoteRoute) -> some View {
        switch route {
        case .detail(let id):
            if let note = viewModel.notes.first(where: { $0.id == id }) {
                DetailView(note: note, pipeline: pipeline, onSave: { viewModel.saveVoiceNote(draft: $0) })
            } else {
                EmptyVoiceState(message: "Note not found.")
                    .background(VoiceNoteTheme.paper.ignoresSafeArea())
            }
        }
    }
}

private extension String {
    var firstSentence: String {
        guard let end = firstIndex(where: { ".!?。！？".contains($0) }) else {
            return trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return String(self[...end]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
