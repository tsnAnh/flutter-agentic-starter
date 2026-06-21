import Shared
import SwiftUI

struct ThreadLayer: View {
    let progress: CGFloat
    let orbRadius: CGFloat
    private let fadeEnd: CGFloat = 0.35

    var body: some View {
        GeometryReader { geometry in
            let q = max(0, (progress - fadeEnd) / (1 - fadeEnd))
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            ZStack {
                Circle()
                    .fill(VoiceNoteTheme.mint.opacity(Double(max(0, (q - 0.8) * 0.28))))
                    .frame(width: orbRadius * 2 * max(0, (q - 0.8) * 5), height: orbRadius * 2 * max(0, (q - 0.8) * 5))
                    .position(center)

                Circle()
                    .trim(from: 0, to: q)
                    .stroke(VoiceNoteTheme.mint, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: orbRadius * 2, height: orbRadius * 2)
                    .shadow(color: VoiceNoteTheme.mint.opacity(0.45), radius: 12)
                    .position(center)
                    .opacity(q > 0.001 ? 1 : 0)

                Text(q < 0.6 ? "PULL TO SPEAK" : "KEEP PULLING")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .tracking(1.8)
                    .foregroundStyle(VoiceNoteTheme.pineMuted)
                    .position(x: center.x, y: center.y + orbRadius + 28)
                    .opacity(q > 0.03 && q < 0.96 ? min(1, Double(q * 2 + 0.3)) : 0)
            }
        }
        .allowsHitTesting(false)
    }
}

struct VoiceNotesSheet: View {
    let notes: [VoiceNote]
    let errorMessage: String?
    let sheetOpacity: Double
    let sheetOffset: CGFloat
    let onSelectNote: (VoiceNote) -> Void
    let onScrollAtTopChange: (Bool) -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(spacing: 0) {
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: ScrollTopPreferenceKey.self,
                            value: proxy.frame(in: .named("VoiceNotesScroll")).minY >= -2
                        )
                    }
                    .frame(height: 0)
                    HintRow()
                    if let errorMessage {
                        EmptyVoiceState(message: errorMessage)
                    } else if notes.isEmpty {
                        EmptyVoiceState(message: "Nothing captured yet.\nPull the page down and speak a note.")
                    } else {
                        ForEach(notes, id: \.id) { note in
                            VoiceNoteRow(note: note, onSelect: { onSelectNote(note) })
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 120)
                .animation(.spring(response: 0.5, dampingFraction: 0.72), value: notes.count)
            }
            .coordinateSpace(name: "VoiceNotesScroll")
            .onPreferenceChange(ScrollTopPreferenceKey.self, perform: onScrollAtTopChange)
        }
        .opacity(sheetOpacity)
        .offset(y: sheetOffset)
        .animation(.spring(response: 0.55, dampingFraction: 0.72), value: sheetOffset)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TODAY · VOICE NOTES")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .tracking(2.0)
                .foregroundStyle(VoiceNoteTheme.mint)
            Text("Good morning,\nAn")
                .font(.system(size: 34, weight: .medium, design: .serif))
                .foregroundStyle(VoiceNoteTheme.pine)
            HStack(alignment: .lastTextBaseline) {
                Text("\(notes.count)")
                    .font(.system(size: 28, weight: .medium, design: .monospaced))
                    .foregroundStyle(VoiceNoteTheme.pine)
                Text(notes.count == 1 ? "note today" : "notes today")
                    .font(.subheadline)
                    .foregroundStyle(VoiceNoteTheme.pineMuted)
                Spacer()
                Text("On-device")
                    .font(.caption)
                    .foregroundStyle(VoiceNoteTheme.pineMuted)
            }
            .padding(.top, 10)
        }
        .padding(.horizontal, 24)
        .padding(.top, 22)
        .padding(.bottom, 20)
        .overlay(alignment: .bottom) {
            Rectangle().fill(VoiceNoteTheme.hairline).frame(height: 1)
        }
    }
}

private struct ScrollTopPreferenceKey: PreferenceKey {
    static var defaultValue = true

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

struct HintRow: View {
    @State private var hintPulse = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "chevron.down")
                .font(.caption)
                .offset(y: hintPulse ? 3 : -1)
                .opacity(hintPulse ? 0.55 : 1)
            Text("Pull down to speak a note")
                .font(.footnote)
        }
        .foregroundStyle(VoiceNoteTheme.pineMuted.opacity(0.55))
        .frame(maxWidth: .infinity)
        .padding(.top, 18)
        .padding(.bottom, 6)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.75).repeatForever(autoreverses: true)) {
                hintPulse = true
            }
        }
    }
}

struct EmptyVoiceState: View {
    let message: String

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "mic")
                .font(.system(size: 24))
                .frame(width: 64, height: 64)
                .overlay(Circle().stroke(style: StrokeStyle(lineWidth: 1.5, dash: [5])))
            Text(message)
                .font(.callout)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .foregroundStyle(VoiceNoteTheme.pineMuted.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 46)
    }
}

struct VoiceNoteRow: View {
    let note: VoiceNote
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "waveform")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(VoiceNoteTheme.pine)
                    .frame(width: 40, height: 40)
                    .background(VoiceNoteTheme.mintSoft, in: RoundedRectangle(cornerRadius: 14))
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 7) {
                        Text(note.title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(VoiceNoteTheme.pine)
                        Text("VOICE")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(VoiceNoteTheme.pine, in: Capsule())
                    }
                    Text(note.summary)
                        .font(.caption)
                        .foregroundStyle(VoiceNoteTheme.pineMuted)
                        .lineLimit(2)
                    Text("\(max(1, note.durationMillis / 1000))s · just now")
                        .font(.caption2)
                        .foregroundStyle(VoiceNoteTheme.pineMuted.opacity(0.65))
                }
                Spacer()
            }
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .padding(.vertical, 16)
        .overlay(alignment: .bottom) {
            Rectangle().fill(VoiceNoteTheme.hairline).frame(height: 1)
        }
    }
}
