//
//  LetterSoundGameView.swift
//  PlayABC
//

import SwiftUI

/// Phonics game: play sound (e.g. "buh"), show 3 letters, kid selects the correct one.
struct LetterSoundGameView: View {
    static let roundsTotal = 5
    static let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map { String($0) }

    let onDone: () -> Void

    @State private var currentRound = 0
    @State private var targetLetter: String = "B"
    @State private var options: [String] = []
    @State private var wrongTappedIndex: Int? = nil
    @State private var showCelebration = false
    @State private var rewardOptionIndex: Int? = nil

    private var isGameComplete: Bool { currentRound >= Self.roundsTotal }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                AnimatedScreenBackground(gradientPageIndex: 4)
                if isGameComplete {
                    completionView
                } else {
                    roundView
                }
                if showCelebration {
                    LottieView.celebration(LottieManager.Celebration.confetti)
                        .opacity(0.7)
                        .allowsHitTesting(false)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if !isGameComplete {
                CornerMascotView()
            }
        }
        .onAppear {
            nextRound()
        }
    }

    private var roundView: some View {
        VStack(spacing: Layout.spacingXXL) {
            Text("Which letter makes this sound?")
                .gamePromptStyle(glowColor: ColorManager.letterViolet)
                .padding(.horizontal)

            Button {
                SpeechManager.shared.speakPhonicsSound(letter: targetLetter)
            } label: {
                HStack(spacing: Layout.spacingS) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: Layout.fontTitle1))
                    Text("Play sound")
                        .font(.system(size: Layout.fontTitle3, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, Layout.spacingXL)
                .padding(.vertical, Layout.spacingM)
                .background(Capsule().fill(ColorManager.letterViolet))
            }
            .padding(.top, Layout.spacingS)

            HStack(spacing: Layout.spacingXL) {
                ForEach(Array(options.enumerated()), id: \.offset) { index, letter in
                    letterOption(letter: letter, index: index)
                }
            }
            .padding(.horizontal, Layout.paddingCard)

            Spacer()
        }
        .padding(.top, Layout.spacingM)
    }

    private func letterOption(letter: String, index: Int) -> some View {
        let isWrong = wrongTappedIndex == index
        let showReward = rewardOptionIndex == index
        return Button {
            if letter == targetLetter {
                SoundManager.shared.playCoinPickup()
                rewardOptionIndex = index
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { rewardOptionIndex = nil }
                SpeechManager.shared.speakRewardPhrase()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { advanceRound() }
            } else {
                wrongTappedIndex = index
                SoundManager.shared.playTap()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { wrongTappedIndex = nil }
            }
        } label: {
            Text(letter)
                .font(.system(size: Layout.fontLetterBig, weight: .bold, design: .rounded))
                .foregroundColor(ColorManager.textOnCard())
                .frame(width: Layout.scaled(88), height: Layout.scaled(88))
                .background(
                    RoundedRectangle(cornerRadius: Layout.cornerRadiusOption, style: .continuous)
                        .fill(ColorManager.accentWhite)
                        .shadow(color: ColorManager.letterViolet.opacity(0.25), radius: Layout.spacingL, x: 0, y: Layout.spacingS)
                )
                .overlay {
                    if showReward {
                        CorrectTapRewardView()
                    }
                }
                .offset(x: isWrong ? -4 : 0)
                .animation(.default.repeatCount(2, autoreverses: true).speed(6), value: isWrong)
        }
        .buttonStyle(.plain)
    }

    private func nextRound() {
        let all = Self.letters
        guard let target = all.randomElement() else { return }
        targetLetter = target
        let others = all.filter { $0 != target }
        let distractors = Array(others.shuffled().prefix(2))
        options = ([target] + distractors).shuffled()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            SpeechManager.shared.speakPhonicsSound(letter: targetLetter)
        }
    }

    private func advanceRound() {
        currentRound += 1
        if currentRound >= Self.roundsTotal {
            SoundManager.shared.playRewardCelebration()
            showCelebration = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { showCelebration = false }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { nextRound() }
        }
    }

    private var completionView: some View {
        GameCompletionView(title: "You know your sounds!", subtitle: "Great listening!", accentColor: ColorManager.letterViolet, onDone: onDone) {
            Text("🎵")
                .font(.system(size: Layout.scaled(80)))
        }
    }
}

#Preview {
    LetterSoundGameView(onDone: {})
}
