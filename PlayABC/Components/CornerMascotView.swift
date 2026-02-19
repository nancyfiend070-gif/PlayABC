//
//  CornerMascotView.swift
//  PlayABC
//

import SwiftUI

// MARK: - Touch effect + kid voice on mascot tap
private func mascotTapped() {
    let generator = UIImpactFeedbackGenerator(style: .light)
    generator.impactOccurred()
    SpeechManager.shared.speakRandomKidReaction()
}

/// Button style: scale down on press for touch feedback (mascots).
struct MascotTapStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Soft glow applied to mascots app‑wide (warm + highlight).
struct MascotGlowModifier: ViewModifier {
    var glowColor: Color = .orange
    var glowOpacity: Double = 0.4
    var highlightOpacity: Double = 0.5

    func body(content: Content) -> some View {
        content
            .shadow(color: glowColor.opacity(glowOpacity), radius: 20, x: 0, y: 8)
            .shadow(color: Color.white.opacity(highlightOpacity), radius: 12, x: 0, y: 4)
    }
}

extension View {
    /// Applies the app-wide mascot glow (warm + highlight).
    func mascotGlow(glowColor: Color = .orange, glowOpacity: Double = 0.4) -> some View {
        modifier(MascotGlowModifier(glowColor: glowColor, glowOpacity: glowOpacity))
    }
}

/// Lottie mascot in the bottom‑right corner. Tappable: touch effect + cute kid voice.
struct CornerMascotView: View {
    var animationName: String = LottieManager.Mascot.fishWithBowl
    var size: CGFloat = Layout.mascotCorner

    var body: some View {
        Button(action: mascotTapped) {
            LottieView.mascot(animationName)
                .frame(width: size, height: size)
                .mascotGlow(glowColor: .cyan, glowOpacity: 0.35)
        }
        .buttonStyle(MascotTapStyle())
        .padding(.trailing, Layout.spacingM)
        .padding(.bottom, Layout.spacingM)
    }
}

/// Cute doggie Lottie at bottom center for winning/celebration. Tappable: touch effect + kid voice.
struct WinningDoggieView: View {
    var size: CGFloat = Layout.mascotWinningXL
    @State private var isPulsing = false

    var body: some View {
        VStack {
            Spacer(minLength: 0)
            Button(action: mascotTapped) {
                LottieView.mascot(LottieManager.Mascot.cuteDoggie)
                    .frame(width: size, height: size)
                    .scaleEffect(isPulsing ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isPulsing)
                    .mascotGlow(glowColor: .orange, glowOpacity: 0.45)
            }
            .buttonStyle(MascotTapStyle())
            .padding(.bottom, Layout.spacingM)
        }
        .onAppear { isPulsing = true }
    }
}
