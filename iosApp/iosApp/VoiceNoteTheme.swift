import SwiftUI

enum VoiceNoteTheme {
    static let pine = Color(red: 0.06, green: 0.18, blue: 0.15)
    static let pineMuted = Color(red: 0.16, green: 0.32, blue: 0.27)
    static let mint = Color(red: 0.35, green: 0.78, blue: 0.58)
    static let mintSoft = Color(red: 0.86, green: 0.97, blue: 0.90)
    static let amber = Color(red: 0.82, green: 0.58, blue: 0.22)
    static let paper = Color(red: 0.97, green: 0.98, blue: 0.94)
    static let hairline = Color(red: 0.08, green: 0.25, blue: 0.20).opacity(0.12)
}

extension View {
    @ViewBuilder
    func noteGlass(cornerRadius: CGFloat, interactive: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
            if interactive {
                self.glassEffect(
                    .regular.tint(.white.opacity(0.28)).interactive(),
                    in: .rect(cornerRadius: cornerRadius)
                )
            } else {
                self.glassEffect(
                    .regular.tint(.white.opacity(0.20)),
                    in: .rect(cornerRadius: cornerRadius)
                )
            }
        } else {
            self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
        }
    }

    @ViewBuilder
    func noteGlassCircle(interactive: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
            if interactive {
                self.glassEffect(.regular.tint(VoiceNoteTheme.mint.opacity(0.25)).interactive(), in: .circle)
            } else {
                self.glassEffect(.regular.tint(VoiceNoteTheme.mint.opacity(0.18)), in: .circle)
            }
        } else {
            self.background(.ultraThinMaterial, in: Circle())
        }
    }
}
