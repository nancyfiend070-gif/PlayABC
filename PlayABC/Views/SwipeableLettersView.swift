import SwiftUI

/// Allows kids to swipe left and right through all alphabet letters
/// in a carousel-style layout where the next and previous cards peek in.
struct SwipeableLettersView: View {
    /// All letters available in this screen.
    private let letters: [AlphabetLetter] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map {
        AlphabetLetter(character: String($0))
    }

    /// The index of the letter to show first when the screen appears.
    let startIndex: Int

    /// When true, do not speak on first appear (e.g. when opening from Learning).
    var skipInitialSpeech: Bool = false

    /// The currently visible letter index, used for paging and speech.
    @State private var currentIndex: Int = 0

    /// Tracks the current drag offset while the user is swiping.
    @GestureState private var dragOffset: CGFloat = 0

    @Environment(\.dismiss) private var dismiss

    /// Controls whether confetti celebration should be shown.
    @State private var showConfetti: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AnimatedScreenBackground(gradientPageIndex: currentIndex % 5, gradientOpacity: 0.7)

            VStack {
                topBar

                GeometryReader { geometry in
                    let cardWidth = geometry.size.width * 0.72
                    let spacing: CGFloat = 8
                    let totalWidth = CGFloat(letters.count) * (cardWidth + spacing)
                    let xOffset = -CGFloat(currentIndex) * (cardWidth + spacing)
                        + dragOffset
                        + (geometry.size.width - cardWidth) / 2

                    LazyHStack(spacing: spacing) {
                        ForEach(letters.indices, id: \.self) { index in
                            let theme = ColorManager.themeForPage(index)
                            LetterDetailView(letter: letters[index], theme: theme) {
                                handleImageTap(at: index)
                            }
                            .frame(width: cardWidth, height: geometry.size.height * 0.8)
                            .scaleEffect(index == currentIndex ? 1.0 : 0.92)
                            .animation(.easeInOut(duration: 0.25), value: currentIndex)
                        }
                    }
                    .frame(width: totalWidth, alignment: .leading)
                    .offset(x: xOffset)
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation.width
                            }
                            .onEnded { value in
                                let threshold = geometry.size.width * 0.18
                                if value.translation.width < -threshold, currentIndex < letters.count - 1 {
                                    currentIndex += 1
                                } else if value.translation.width > threshold, currentIndex > 0 {
                                    currentIndex -= 1
                                }
                            }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            // Confetti celebration overlay
            if showConfetti {
                LottieView.celebration(LottieManager.Celebration.confetti)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            CornerMascotView()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            currentIndex = safeIndex(startIndex)
            if !skipInitialSpeech {
                speakForCurrentIndex(currentIndex)
            }
        }
        .onChange(of: currentIndex) { newIndex in
            speakForCurrentIndex(newIndex)
        }
    }

    /// Top bar with a friendly back/home button.
    private var topBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Home")
                }
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(ColorManager.textOnCard())
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(ColorManager.accentWhite.opacity(0.95))
                        .shadow(color: ColorManager.overlayDark, radius: 4, x: 0, y: 2)
                )
            }
            Spacer()
        }
        .padding(.bottom, 12)
    }

    /// Speaks the letter, word, and sentence for the given index.
    private func speakForCurrentIndex(_ index: Int) {
        let safe = safeIndex(index)
        let letter = letters[safe]
        if let item = LetterLearningData.item(for: letter.character) {
            SpeechManager.shared.speakLetterSequence(letter: item.letter, word: item.word)
        }
    }

    /// Handles taps on the main image, including speech and rewards.
    private func handleImageTap(at index: Int) {
        speakForCurrentIndex(index)

        let reward = RewardManager.shared.registerTap()
        switch reward {
        case .none:
            break
        case .star:
            SoundManager.shared.playRewardStar()
        case .celebration:
            SoundManager.shared.playRewardCelebration()
            showConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                showConfetti = false
            }
        }
    }

    /// Ensures the index always stays inside the valid range.
    private func safeIndex(_ index: Int) -> Int {
        guard !letters.isEmpty else { return 0 }
        return min(max(0, index), letters.count - 1)
    }
}

#Preview {
    SwipeableLettersView(startIndex: 0)
}

