//
//  MatchingGameView.swift
//  PlayABC
//

import SwiftUI

/// Short game: match the letter to the correct picture. 5 rounds, then celebration.
struct MatchingGameView: View {
    static let roundsTotal = 5

    let onDone: () -> Void

    @State private var currentRound = 0
    @State private var correctItem: LetterLearningItem?
    @State private var options: [LetterLearningItem] = []
    @State private var wrongTappedIndex: Int? = nil
    @State private var showCelebration = false
    @State private var rewardOptionIndex: Int? = nil

    private var isGameComplete: Bool { currentRound >= Self.roundsTotal }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                AnimatedScreenBackground(gradientPageIndex: 3)
                if isGameComplete {
                    completionView
                } else {
                    roundView
                }
                if showCelebration {
                    LottieView.celebration("Confetti")
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
            Text("Which picture goes with this letter?")
                .gamePromptStyle(glowColor: ColorManager.letterCoral)
                .padding(.horizontal, Layout.paddingScreen)

            if let correct = correctItem {
                Text(correct.letter)
                    .font(.system(size: Layout.fontLetterHuge, weight: .heavy, design: .rounded))
                    .foregroundColor(ColorManager.textOnCard())

                HStack(spacing: Layout.spacingXL) {
                    ForEach(Array(options.enumerated()), id: \.element.letter) { index, item in
                        optionButton(item: item, index: index)
                    }
                }
                .padding(.horizontal, Layout.spacingL)
            }

            Spacer()
        }
        .padding(.top, Layout.scaled(32))
    }

    private func optionButton(item: LetterLearningItem, index: Int) -> some View {
        let isWrongShake = wrongTappedIndex == index
        return Button {
            if item.letter == correctItem?.letter {
                SoundManager.shared.playCoinPickup()
                rewardOptionIndex = index
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { rewardOptionIndex = nil }
                SpeechManager.shared.speakLetterSequence(letter: item.letter, word: item.word)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    advanceRound()
                }
            } else {
                wrongTappedIndex = index
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    wrongTappedIndex = nil
                }
            }
        } label: {
            VStack(spacing: Layout.spacingS) {
                Text(item.emoji)
                    .font(.system(size: Layout.fontLetterBig))
                Text(item.word)
                    .font(.system(size: Layout.fontSubhead, weight: .semibold, design: .rounded))
                    .foregroundColor(ColorManager.textOnCard())
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Layout.spacingXL)
            .background(
                RoundedRectangle(cornerRadius: Layout.cornerRadiusOption, style: .continuous)
                    .fill(ColorManager.accentWhite)
                    .shadow(color: .black.opacity(0.1), radius: Layout.spacingL, x: 0, y: 4)
            )
            .offset(x: isWrongShake ? -6 : 0)
            .animation(.default.repeatCount(3, autoreverses: true).speed(6), value: isWrongShake)
            .overlay {
                if rewardOptionIndex == index {
                    CorrectTapRewardView()
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(correctItem == nil)
    }

    private var completionView: some View {
        GameCompletionView(title: "You did it!", subtitle: "Great matching!", accentColor: ColorManager.letterCoral, onDone: onDone) {
            Text("🎉")
                .font(.system(size: Layout.scaled(80)))
        }
    }

    private func nextRound() {
        let pool = LetterLearningData.allItems
        guard let chosen = pool.randomElement() else { return }
        correctItem = chosen
        options = [chosen] + LetterLearningData.randomItems(count: 2, excludingLetter: chosen.letter)
        options.shuffle()
    }

    private func advanceRound() {
        currentRound += 1
        if currentRound >= Self.roundsTotal {
            SoundManager.shared.playRewardCelebration()
            showCelebration = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                showCelebration = false
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                nextRound()
            }
        }
    }
}

#Preview {
    MatchingGameView(onDone: {})
}
