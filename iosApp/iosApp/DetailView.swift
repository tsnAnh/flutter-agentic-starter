import Shared
import SwiftUI
import UIKit

struct DetailView: View {
    let note: VoiceNote
    @ObservedObject var pipeline: LocalVoiceNotePipeline
    let onSave: (VoiceNoteDraft) -> Void

    @AppStorage("voiceNoteKeyboardFallbackEnabled") private var keyboardFallbackEnabled = false
    @FocusState private var correctionFocused: Bool
    @State private var typedCorrection = ""
    @State private var isRecordingEdit = false
    @State private var isProcessingEdit = false
    @State private var errorMessage: String?
    @State private var editTask: Task<Void, Never>?

    init(note: VoiceNote, pipeline: LocalVoiceNotePipeline, onSave: @escaping (VoiceNoteDraft) -> Void) {
        self.note = note
        self._pipeline = ObservedObject(wrappedValue: pipeline)
        self.onSave = onSave
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                DetailBlock(title: "Summary", text: note.summary)
                ChecklistBlock(items: note.checklist)
                DetailBlock(title: "Transcript", text: note.transcript.isEmpty ? note.summary : note.transcript)
                editPanel
            }
            .padding(24)
        }
        .background(VoiceNoteTheme.paper.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    revealKeyboard()
                } label: {
                    Image(systemName: "keyboard")
                }
                .accessibilityLabel("Edit with keyboard")
            }
        }
        .onDisappear {
            editTask?.cancel()
            if isRecordingEdit || isProcessingEdit {
                pipeline.cancelRecording()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("VOICE NOTE")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .tracking(2)
                .foregroundStyle(VoiceNoteTheme.mint)
            Text(note.title)
                .font(.system(size: 32, weight: .medium, design: .serif))
                .foregroundStyle(VoiceNoteTheme.pine)
            Text(detailDate)
                .font(.subheadline)
                .foregroundStyle(VoiceNoteTheme.pineMuted)
        }
    }

    private var editPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Button(action: voiceEditTapped) {
                    Label(isRecordingEdit ? "Save edit" : "Edit by voice", systemImage: isRecordingEdit ? "checkmark" : "mic")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(VoiceNoteTheme.pine)
                .disabled(isProcessingEdit)

                if isProcessingEdit {
                    ProgressView()
                        .tint(VoiceNoteTheme.pine)
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            if keyboardFallbackEnabled {
                TextEditor(text: $typedCorrection)
                    .focused($correctionFocused)
                    .frame(minHeight: 90)
                    .padding(10)
                    .scrollContentBackground(.hidden)
                    .background(.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14).stroke(VoiceNoteTheme.hairline)
                    }

                Button {
                    saveTypedCorrection()
                } label: {
                    Label("Apply typed edit", systemImage: "arrow.up.circle")
                }
                .buttonStyle(.bordered)
                .disabled(typedCorrection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessingEdit)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .noteGlass(cornerRadius: 18)
    }

    private var detailDate: String {
        let date = Date(timeIntervalSince1970: TimeInterval(note.createdAtEpochMillis) / 1000)
        let duration = max(1, note.durationMillis / 1000)
        return "\(date.formatted(date: .abbreviated, time: .shortened)) · \(duration)s"
    }

    private func voiceEditTapped() {
        isRecordingEdit ? stopVoiceEdit() : startVoiceEdit()
    }

    private func startVoiceEdit() {
        guard !isRecordingEdit, !isProcessingEdit else { return }
        errorMessage = nil
        isRecordingEdit = true
        Task {
            do {
                try await pipeline.startRecording()
            } catch {
                isRecordingEdit = false
                showFallback(error.localizedDescription)
            }
        }
    }

    private func stopVoiceEdit() {
        guard isRecordingEdit else { return }
        isRecordingEdit = false
        isProcessingEdit = true
        editTask?.cancel()
        editTask = Task {
            do {
                let draft = try await pipeline.finishEditing(note: note)
                try Task.checkCancellation()
                onSave(draft)
                errorMessage = nil
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch is CancellationError {
                pipeline.cancelRecording()
            } catch {
                pipeline.cancelRecording()
                showFallback(error.localizedDescription)
            }
            isProcessingEdit = false
        }
    }

    private func saveTypedCorrection() {
        let correction = typedCorrection.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !correction.isEmpty, !isProcessingEdit else { return }
        keyboardFallbackEnabled = true
        isProcessingEdit = true
        editTask?.cancel()
        editTask = Task {
            do {
                let draft = try await pipeline.revise(note: note, with: correction)
                try Task.checkCancellation()
                onSave(draft)
                typedCorrection = ""
                errorMessage = nil
                correctionFocused = false
            } catch is CancellationError {
                return
            } catch {
                showFallback(error.localizedDescription)
            }
            isProcessingEdit = false
        }
    }

    private func revealKeyboard() {
        keyboardFallbackEnabled = true
        correctionFocused = true
    }

    private func showFallback(_ message: String) {
        errorMessage = message
        keyboardFallbackEnabled = true
        correctionFocused = true
    }
}

private struct DetailBlock: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .tracking(1.6)
                .foregroundStyle(VoiceNoteTheme.pineMuted)
            Text(text)
                .font(.body)
                .lineSpacing(5)
                .foregroundStyle(VoiceNoteTheme.pine)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .noteGlass(cornerRadius: 18)
    }
}

private struct ChecklistBlock: View {
    let items: [String]

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("CHECKLIST")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .tracking(1.6)
                    .foregroundStyle(VoiceNoteTheme.pineMuted)
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "circle")
                            .font(.caption)
                            .foregroundStyle(VoiceNoteTheme.mint)
                            .padding(.top, 4)
                        Text(item)
                            .font(.body)
                            .foregroundStyle(VoiceNoteTheme.pine)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .noteGlass(cornerRadius: 18)
        }
    }
}
