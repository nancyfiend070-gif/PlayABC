import SwiftUI

/// Shows a large letter and its related image and word inside a rounded card.
struct LetterDetailView: View {
    /// The selected letter from the home screen.
    let letter: AlphabetLetter

    /// Visual theme used for this letter page.
    let theme: ColorManager.Theme

    /// Called when the main image card is tapped.
    let onImageTapped: () -> Void

    /// Controls the bounce animation of the image area.
    @State private var isBouncing: Bool = false

    /// Flying emojis overlay (Flutter-style: single progress, per-emoji params).
    @State private var flyingEmojis: [FlyingEmoji] = []
    @State private var flyingProgress: Double = 0

    /// Controls sparkle animation when page appears.
    @State private var showSparkle: Bool = false

    /// Gentle "breathing" pulse on the picture to invite tap (letter–picture association).
    @State private var picturePulse: Bool = false

    var body: some View {
        let item = LetterLearningData.item(for: letter.character)

        ZStack {
            VStack(spacing: Layout.spacingXL) {
                Text(letter.character)
                    .font(.system(size: Layout.scaled(80), weight: .heavy, design: .rounded))
                    .foregroundColor(theme.accent)

                if let item = item {
                    ZStack {
                        imageSection(for: item)
                        flyingEmojisLayer(emojis: flyingEmojis, progress: flyingProgress)
                    }
                    textSection(for: item)
                } else {
                    fallbackSection
                }
            }
            .padding(Layout.paddingCard)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Layout.cornerRadiusCard + Layout.scaled(8), style: .continuous)
                    .fill(ColorManager.accentWhite)
                    .shadow(color: theme.primary.opacity(0.35), radius: Layout.scaled(10), x: 0, y: Layout.scaled(8))
            )
            
            // Sparkle animation overlay when page appears
            if showSparkle {
                LottieView.celebration("Confetti")
                    .opacity(0.6)
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            startBounceAnimation()
            showSparkle = true
            picturePulse = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showSparkle = false
            }
        }
    }

    /// Builds the animated image area for the letter.
    private func imageSection(for item: LetterLearningItem) -> some View {
        Button(action: {
            startBounceAnimation()
            onImageTapped()
            addFlyingEmojis(emoji: item.emoji)
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: Layout.cornerRadiusOption + Layout.scaled(8), style: .continuous)
                    .fill(theme.primary.opacity(0.18))

                Text(item.emoji)
                    .font(.system(size: Layout.scaled(100)))
            }
            .frame(height: Layout.scaled(200))
            .scaleEffect(isBouncing ? 1.06 : (picturePulse ? 1.02 : 0.98))
            .animation(
                .interpolatingSpring(stiffness: 220, damping: 15),
                value: isBouncing
            )
            .animation(
                .easeInOut(duration: 1.8).repeatForever(autoreverses: true),
                value: picturePulse
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(item.word) picture")
    }

    /// Shows text like "A for Apple" under the image.
    private func textSection(for item: LetterLearningItem) -> some View {
        Text("\(item.letter) for \(item.word)")
            .font(.system(size: Layout.fontLarge, weight: .bold, design: .rounded))
            .foregroundColor(theme.accent)
    }

    /// Fallback view if we do not have data for the letter.
    private var fallbackSection: some View {
        Text("Coming soon!")
            .font(.system(size: Layout.fontTitle2, weight: .semibold, design: .rounded))
            .foregroundColor(theme.accent)
    }

    /// Starts or restarts the bounce animation.
    private func startBounceAnimation() {
        isBouncing.toggle()
    }

    /// Adds flying emojis (Flutter-style: single linear progress, per-emoji delay/speed/scale/rotation).
    private func addFlyingEmojis(emoji: String) {
        let count = 8
        let duration: TimeInterval = 2.0
        let newItems = (0..<count).map { i in
            FlyingEmoji(
                emoji: emoji,
                offsetX: Double.random(in: -50...50),
                speed: Double.random(in: 0.5...1.0),
                scale: Double.random(in: 0.8...1.2),
                rotation: Double.random(in: -0.25...0.25),
                delay: Double(i) * 0.05
            )
        }
        flyingEmojis = newItems
        flyingProgress = 0

        withAnimation(.linear(duration: duration)) {
            flyingProgress = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            flyingEmojis.removeAll()
            flyingProgress = 0
        }
    }

    /// Renders flying emojis driven by single progress (Flutter _FlyingEmojisPainter style).
    private func flyingEmojisLayer(emojis: [FlyingEmoji], progress: Double) -> some View {
        ZStack {
            ForEach(emojis) { item in
                FlyingEmojiView(item: item, progress: progress)
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Flutter-style flying emoji (per-emoji params, single progress 0→1)
private struct FlyingEmoji: Identifiable {
    let id = UUID()
    let emoji: String
    let offsetX: Double
    let speed: Double
    let scale: Double
    let rotation: Double
    let delay: Double
}

private func easeOutCubic(_ t: Double) -> Double {
    1 - pow(1 - t, 3)
}

private struct FlyingEmojiView: View {
    let item: FlyingEmoji
    let progress: Double

    private static let travelDistance: Double = 160
    private static var fontSize: CGFloat { Layout.fontLarge }

    var body: some View {
        let adjustedProgress = ((progress - item.delay) / (1 - item.delay)).clamped(to: 0...1)
        let curve = easeOutCubic(adjustedProgress)
        let x = item.offsetX * curve
        let y = -Self.travelDistance * curve * item.speed
        let opacity = (1 - adjustedProgress).clamped(to: 0...1)
        let scale = 0.5 + item.scale * adjustedProgress
        let rotation = item.rotation * adjustedProgress

        Text(item.emoji)
            .font(.system(size: Self.fontSize))
            .opacity(opacity)
            .offset(x: x, y: y)
            .scaleEffect(scale)
            .rotationEffect(.radians(rotation))
    }
}

extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

#Preview {
    ZStack {
        ColorManager.themeForPage(0).backgroundGradient
            .ignoresSafeArea()

        LetterDetailView(
            letter: AlphabetLetter(character: "A"),
            theme: ColorManager.themeForPage(0),
            onImageTapped: {}
        )
        .padding(.horizontal, Layout.paddingCard)
    }
}

