import SwiftUI

/// The main home screen: Learning and Games.
struct HomeView: View {
    var onLearnABCTapped: (() -> Void)?
    var onPlayGames: (() -> Void)?
    /// Called when the user taps Privacy (for in-app privacy policy; required for App Store).
    var onPrivacyTapped: (() -> Void)? = nil

    /// Start time for cycling background gradient every 2.5s (rainbow + pastels).
    @State private var gradientCycleStart = Date()
    private let gradientCycleInterval: TimeInterval = 2.5
    /// First-launch "wow": show a short sparkle/celebration once when the app is opened for the first time.
    @AppStorage("PlayABC_hasSeenFirstLaunch") private var hasSeenFirstLaunch = false
    @State private var showFirstLaunchSparkle = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TimelineView(.periodic(from: gradientCycleStart, by: gradientCycleInterval)) { context in
                let index = (Int(context.date.timeIntervalSince(gradientCycleStart) / gradientCycleInterval) % ColorManager.homeCycleGradientCount)
                AnimatedScreenBackground(customGradient: ColorManager.gradientForHomeCycle(index), gradientOpacity: 0.85)
                    .animation(.easeInOut(duration: 1.0), value: index)
            }
            ScrollView {
                VStack(spacing: Layout.spacingL) {
                    headerSection
                    HomeMenuCard(
                        label: nil,
                        title: "Learn ABC",
                        subtitle: "Tap each letter, see pictures and hear words!",
                        emoji: "📚",
                        accent: ColorManager.letterMint,
                        action: { onLearnABCTapped?() },
                        playSound: false
                    )
                    HomeMenuCard(
                        label: nil,
                        title: "Play Games",
                        subtitle: "Pop balloons, race the tiger, match letters & more!",
                        emoji: "🎮",
                        accent: ColorManager.letterSkyBlue,
                        action: { onPlayGames?() }
                    )
                }
                .padding(Layout.paddingScreen)
                .padding(.bottom, Layout.spacingXXL)
            }
            CornerMascotView()

            if showFirstLaunchSparkle {
                LottieView.celebration(LottieManager.Celebration.confetti)
                    .opacity(0.7)
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            gradientCycleStart = Date()
            if !hasSeenFirstLaunch {
                hasSeenFirstLaunch = true
                showFirstLaunchSparkle = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    showFirstLaunchSparkle = false
                }
            }
        }
    }

    private var headerSection: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: Layout.spacingM) {
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    SpeechManager.shared.speakRandomKidReaction()
                }) {
                    LottieView.mascot(LottieManager.Mascot.cuteTiger)
                        .frame(width: Layout.mascotHeaderHome, height: Layout.mascotHeaderHome)
                        .mascotGlow(glowColor: .orange, glowOpacity: 0.55)
                        .shadow(color: Color.orange.opacity(0.4), radius: 28, x: 0, y: 10)
                }
                .buttonStyle(MascotTapStyle())
                playABCTitle
                Text("Tap the tiger! 🐯")
                    .font(.system(size: Layout.fontCaption, weight: .medium, design: .rounded))
                    .foregroundColor(ColorManager.titleOnGradient().opacity(0.85))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, Layout.spacingM)
            .padding(.bottom, Layout.spacingS)

            if onPrivacyTapped != nil {
                Button(action: { onPrivacyTapped?() }) {
                    Text("Privacy")
                        .font(.system(size: Layout.fontCaption, weight: .semibold, design: .rounded))
                        .foregroundColor(ColorManager.titleOnGradient().opacity(0.9))
                }
                .padding(.trailing, Layout.spacingM)
                .padding(.top, Layout.spacingS)
                .accessibilityLabel("Privacy Policy")
                .accessibilityHint("Opens the app privacy policy")
            }
        }
    }

    private static let playABCFont = Font.system(size: Layout.fontDisplay, weight: .black, design: .rounded)
    /// Text color: blue. Shimmer band: light blue → white.
    private static let playABCBlue = Color(red: 0.2, green: 0.45, blue: 0.95)
    private static let shimmerLightBlue = Color(red: 0.5, green: 0.78, blue: 1.0)
    private static let shimmerWhite = Color.white

    private var playABCTitle: some View {
        Text("PlayABC")
            .font(Self.playABCFont)
            .shimmerFromColors(baseColor: Self.playABCBlue, shimmerColors: (Self.shimmerLightBlue, Self.shimmerWhite))
            .shadow(color: Color.white.opacity(0.4), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        HomeView(onLearnABCTapped: {}, onPlayGames: {})
    }
}
