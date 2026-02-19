//
//  Layout.swift
//  PlayABC
//

import SwiftUI
import UIKit

/// Responsive layout constants. Scales with screen width (reference 393pt).
enum Layout {
    private static let refWidth: CGFloat = 393
    private static var scale: CGFloat {
        let width: CGFloat
        if let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first,
           let screen = scene.screen as UIScreen? {
            width = screen.bounds.width
        } else {
            width = UIScreen.main.bounds.width
        }
        return min(1.4, max(0.85, width / refWidth))
    }

    static func scaled(_ value: CGFloat) -> CGFloat { value * scale }

    // MARK: - Spacing
    static var spacingS: CGFloat { scaled(8) }
    static var spacingM: CGFloat { scaled(12) }
    static var spacingL: CGFloat { scaled(16) }
    static var spacingXL: CGFloat { scaled(20) }
    static var spacingXXL: CGFloat { scaled(24) }
    static var paddingScreen: CGFloat { scaled(20) }
    static var paddingCard: CGFloat { scaled(24) }

    // MARK: - Font sizes
    static var fontCaption: CGFloat { scaled(13) }
    static var fontSubhead: CGFloat { scaled(14) }
    static var fontBody: CGFloat { scaled(15) }
    static var fontTitle3: CGFloat { scaled(18) }
    static var fontTitle2: CGFloat { scaled(22) }
    static var fontTitle1: CGFloat { scaled(28) }
    static var fontLarge: CGFloat { scaled(32) }
    static var fontDisplay: CGFloat { scaled(42) }
    static var fontLetter: CGFloat { scaled(40) }
    static var fontLetterBig: CGFloat { scaled(56) }
    static var fontLetterHuge: CGFloat { scaled(72) }

    // MARK: - Sizes
    static var iconSizeSmall: CGFloat { scaled(56) }
    static var iconSizeMedium: CGFloat { scaled(72) }
    static var mascotHeader: CGFloat { scaled(130) }
    /// Home screen header tiger (slightly larger than default header).
    static var mascotHeaderHome: CGFloat { scaled(158) }
    static var mascotCorner: CGFloat { scaled(140) }
    /// Large mascot for winning/celebration (e.g. cute doggie).
    static var mascotWinning: CGFloat { scaled(200) }
    /// Extra-large winning doggie (uses significant screen space).
    static var mascotWinningXL: CGFloat { scaled(280) }
    static var letterButtonHeight: CGFloat { scaled(80) }
    static var cornerRadiusCard: CGFloat { scaled(24) }
    static var cornerRadiusOption: CGFloat { scaled(20) }
    static var cornerRadiusCell: CGFloat { scaled(14) }
    static var cornerRadiusButton: CGFloat { scaled(26) }
    static var gridColumns: Int { 3 }
    static var gridSpacing: CGFloat { scaled(12) }
}

// MARK: - Game prompt style (visible, colorful, kid-friendly; outline + glow)
extension View {
    /// Prominent game prompt: larger text, semi-transparent pill, white outline, soft glow.
    func gamePromptStyle(glowColor: Color = ColorManager.letterViolet) -> some View {
        self
            .font(.system(size: Layout.fontTitle1, weight: .bold, design: .rounded))
            .foregroundColor(Color(red: 0.28, green: 0.20, blue: 0.52))
            .multilineTextAlignment(.center)
            .padding(.horizontal, Layout.scaled(24))
            .padding(.vertical, Layout.scaled(16))
            .background(
                RoundedRectangle(cornerRadius: Layout.cornerRadiusOption, style: .continuous)
                    .fill(Color.white.opacity(0.35))
                    .overlay(
                        RoundedRectangle(cornerRadius: Layout.cornerRadiusOption, style: .continuous)
                            .stroke(Color.white.opacity(0.85), lineWidth: 2)
                    )
            )
            .shadow(color: glowColor.opacity(0.45), radius: 16, x: 0, y: 6)
            .shadow(color: Color.white.opacity(0.35), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Shimmer from colors (Flutter Shimmer.fromColors style)
/// Base color = text color; shimmer band = (light blue, white) sweeping across.
struct ShimmerFromColorsModifier: ViewModifier {
    let baseColor: Color
    /// Shimmer band: (e.g. light blue, white).
    let shimmerColors: (Color, Color)
    @State private var progress: CGFloat = 0
    @State private var timer: Timer?
    private let duration: TimeInterval = 1.8

    private var gradient: LinearGradient {
        let (shimmerStart, shimmerPeak) = shimmerColors
        return LinearGradient(
            stops: [
                .init(color: baseColor, location: 0),
                .init(color: baseColor, location: 0.3),
                .init(color: shimmerStart, location: 0.42),
                .init(color: shimmerPeak, location: 0.5),
                .init(color: shimmerStart, location: 0.58),
                .init(color: baseColor, location: 0.7),
                .init(color: baseColor, location: 1)
            ],
            startPoint: UnitPoint(x: progress - 0.5, y: 0.5),
            endPoint: UnitPoint(x: progress + 0.5, y: 0.5)
        )
    }

    func body(content: Content) -> some View {
        content
            .foregroundStyle(gradient)
            .onAppear {
                runCycle()
                let t = Timer.scheduledTimer(withTimeInterval: duration, repeats: true) { _ in runCycle() }
                timer = t
                RunLoop.main.add(t, forMode: .common)
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
    }

    private func runCycle() {
        progress = 0
        withAnimation(.linear(duration: duration)) {
            progress = 1.5
        }
    }
}

extension View {
    /// Base color = text color; shimmer band = (e.g. light blue, white) sweeping across.
    func shimmerFromColors(baseColor: Color, shimmerColors: (Color, Color)) -> some View {
        modifier(ShimmerFromColorsModifier(baseColor: baseColor, shimmerColors: shimmerColors))
    }
}
