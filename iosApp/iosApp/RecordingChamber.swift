import SwiftUI

struct RecordingChamber: View {
    let isActive: Bool
    let isProcessing: Bool
    let isSaving: Bool
    let seconds: Int
    let transcript: String
    let statusText: String
    let modelDownloadProgress: Double?
    let onStop: () -> Void
    let onCancel: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            ZStack {
                if isActive {
                    timerLabel
                        .position(x: center.x, y: center.y - 122)
                    orb
                        .position(x: center.x, y: center.y)
                    if isSaving {
                        savedLabel
                            .position(x: center.x, y: center.y + 129)
                    } else {
                        VStack(spacing: 0) {
                            WaveformView().opacity(isProcessing ? 0.25 : 1)
                            transcriptLabel.padding(.top, 20)
                        }
                        .position(x: center.x, y: center.y + 178)
                    }
                    Button("SLIDE UP OR TAP TO CANCEL", action: onCancel)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .tracking(1.5)
                        .foregroundStyle(VoiceNoteTheme.pineMuted)
                        .buttonStyle(.plain)
                        .position(x: center.x, y: geometry.size.height - 60)
                }
            }
        }
        .allowsHitTesting(isActive)
        .animation(.easeOut(duration: 0.3), value: isActive)
    }

    private var timerLabel: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(red: 1, green: 0.42, blue: 0.35))
                .frame(width: 7, height: 7)
                .opacity(isProcessing ? 0.35 : 1)
            Text(timeText)
                .font(.system(size: 15, weight: .medium, design: .monospaced))
        }
        .foregroundStyle(VoiceNoteTheme.pine)
        .opacity(isSaving ? 0 : 1)
    }

    private var orb: some View {
        ZStack {
            PulseCircle(delay: 0)
            PulseCircle(delay: 1)
            Button(action: onStop) {
                ZStack {
                    Circle().fill(VoiceNoteTheme.mint)
                    if isSaving {
                        Image(systemName: "checkmark")
                            .font(.system(size: 30, weight: .semibold))
                    } else if isProcessing, modelDownloadProgress != nil {
                        downloadProgressView
                    } else if isProcessing {
                        ProgressView().tint(VoiceNoteTheme.pine)
                    } else {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(VoiceNoteTheme.pine)
                            .frame(width: 24, height: 24)
                    }
                }
                .frame(width: 88, height: 88)
                .noteGlassCircle(interactive: true)
            }
            .buttonStyle(.plain)
            .disabled(isProcessing || isSaving)
        }
        .frame(width: 180, height: 180)
    }

    private var downloadProgressView: some View {
        let progress = CGFloat(min(1, max(0, modelDownloadProgress ?? 0)))
        return ZStack {
            Circle()
                .stroke(VoiceNoteTheme.pine.opacity(0.18), lineWidth: 4)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(VoiceNoteTheme.pine, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%")
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundStyle(VoiceNoteTheme.pine)
        }
        .frame(width: 58, height: 58)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Downloading voice models")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }

    private var savedLabel: some View {
        Text("SAVED TO TODAY")
            .font(.system(size: 12, weight: .medium, design: .monospaced))
            .tracking(1.8)
            .foregroundStyle(VoiceNoteTheme.pine)
            .padding(.top, 10)
    }

    private var transcriptLabel: some View {
        let isStatus = isProcessing && transcript.isEmpty
        return Text(isStatus ? statusText : "“\(transcript.isEmpty ? "Listening" : transcript)”")
            .font(.system(size: isStatus ? 13 : 19, weight: .medium, design: isStatus ? .monospaced : .serif))
            .tracking(isStatus ? 1.1 : 0)
            .lineSpacing(5)
            .multilineTextAlignment(.center)
            .foregroundStyle(VoiceNoteTheme.pine)
            .frame(width: 280)
            .frame(minHeight: 58)
            .padding(.top, 20)
    }

    private var timeText: String {
        "\(seconds / 60):\(String(format: "%02d", seconds % 60))"
    }
}

private struct PulseCircle: View {
    let delay: Double
    @State private var pulsing = false

    var body: some View {
        Circle()
            .stroke(VoiceNoteTheme.mint, lineWidth: 1.5)
            .scaleEffect(pulsing ? 1.1 : 0.42)
            .opacity(pulsing ? 0 : 0.55)
            .onAppear {
                withAnimation(.easeOut(duration: 2).repeatForever(autoreverses: false).delay(delay)) {
                    pulsing = true
                }
            }
    }
}

private struct WaveformView: View {
    private let bars = Array(0..<26)
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(bars, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(VoiceNoteTheme.mint)
                    .frame(width: 3, height: CGFloat(8 + (index * 7) % 26))
                    .scaleEffect(y: isAnimating ? 1 : 0.45)
                    .animation(
                        .easeInOut(duration: 0.7 + Double(index % 7) * 0.08)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index % 5) * -0.08),
                        value: isAnimating
                    )
            }
        }
        .frame(height: 34)
        .onAppear { isAnimating = true }
        .onDisappear { isAnimating = false }
    }
}
