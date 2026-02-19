//
//  LetterRacingGameView.swift
//  PlayABC
//

import SwiftUI

/// Tiger runs forward; correct answer → tiger jumps ahead, wrong → slow down. Adds excitement.
struct LetterRacingGameView: View {
    static let roundsTotal = 5
    static let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map { String($0) }

    let onDone: () -> Void

    @State private var currentRound = 0
    @State private var targetLetter: String = "A"
    @State private var options: [String] = []
    /// Tiger position on track: 0 = left (option 0), 0.5 = middle (option 1), 1 = right (option 2).
    @State private var tigerProgress: CGFloat = 0
    @State private var showCelebration = false
    @State private var rewardIndex: Int? = nil
    @State private var wrongTappedIndex: Int? = nil

    private var isGameComplete: Bool { currentRound >= Self.roundsTotal }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                AnimatedScreenBackground(gradientPageIndex: 2)
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
        VStack(spacing: Layout.spacingL) {
            Text("Help the tiger run!")
                .gamePromptStyle(glowColor: ColorManager.letterPeach)
                .padding(.horizontal)

            Text("Tap the letter \(targetLetter)")
                .font(.system(size: Layout.fontTitle2, weight: .bold, design: .rounded))
                .foregroundColor(ColorManager.textOnCard())

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: Layout.scaled(12), style: .continuous)
                        .fill(ColorManager.accentWhite.opacity(0.6))
                        .frame(height: Layout.scaled(60))
                        .overlay(
                            RoundedRectangle(cornerRadius: Layout.scaled(12), style: .continuous)
                                .stroke(ColorManager.letterPeach.opacity(0.5), lineWidth: 2)
                        )

                    let tigerWidth = Layout.scaled(70)
                    let trackWidth = geo.size.width - tigerWidth
                    HStack {
                        LottieView.mascot(LottieManager.Mascot.cuteTiger)
                            .frame(width: tigerWidth, height: tigerWidth)
                            .offset(x: trackWidth * tigerProgress)
                        Spacer()
                    }
                }
            }
            .frame(height: Layout.scaled(70))
            .padding(.horizontal, Layout.paddingCard)

            HStack(spacing: Layout.spacingXL) {
                ForEach(Array(options.enumerated()), id: \.offset) { index, letter in
                    racingOptionButton(letter: letter, index: index)
                }
            }
            .padding(.top, Layout.spacingL)

            Spacer()
        }
        .padding(.top, Layout.spacingM)
    }

    private func racingOptionButton(letter: String, index: Int) -> some View {
        let isWrong = wrongTappedIndex == index
        let showReward = rewardIndex == index
        return Button {
            if letter == targetLetter {
                SoundManager.shared.playCoinPickup()
                rewardIndex = index
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { rewardIndex = nil }
                // Tiger runs to the position of the correct letter: 0 = left, 1 = middle, 2 = right
                withAnimation(.easeOut(duration: 0.35)) {
                    tigerProgress = CGFloat(index) / 2.0  // 0 → 0, 1 → 0.5, 2 → 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { advanceRound() }
            } else {
                SoundManager.shared.playTap()
                wrongTappedIndex = index
                withAnimation(.easeOut(duration: 0.2)) {
                    tigerProgress = max(0, tigerProgress - 0.08)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { wrongTappedIndex = nil }
            }
        } label: {
            Text(letter)
                .font(.system(size: Layout.fontLetter, weight: .bold, design: .rounded))
                .foregroundColor(ColorManager.textOnCard())
                .frame(width: Layout.scaled(72), height: Layout.scaled(72))
                .background(
                    RoundedRectangle(cornerRadius: Layout.cornerRadiusCell, style: .continuous)
                        .fill(ColorManager.accentWhite)
                        .shadow(color: ColorManager.letterPeach.opacity(0.3), radius: Layout.spacingS)
                )
                .overlay {
                    if showReward {
                        CorrectTapRewardView()
                    }
                }
                .offset(y: isWrong ? 2 : 0)
                .animation(.default.repeatCount(2, autoreverses: true).speed(6), value: isWrong)
        }
        .buttonStyle(.plain)
    }

    private func nextRound() {
        withAnimation(.easeOut(duration: 0.2)) { tigerProgress = 0 }
        let all = Self.letters
        guard let target = all.randomElement() else { return }
        targetLetter = target
        let others = all.filter { $0 != target }
        options = ([target] + Array(others.shuffled().prefix(2))).shuffled()
    }

    private func advanceRound() {
        currentRound += 1
        if currentRound >= Self.roundsTotal {
            SoundManager.shared.playRewardCelebration()
            showCelebration = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { showCelebration = false }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { nextRound() }
        }
    }

    private var completionView: some View {
        GameCompletionView(title: "Tiger made it!", subtitle: "You're a great helper!", accentColor: ColorManager.letterPeach, onDone: onDone) {
            Text("🐯")
                .font(.system(size: Layout.scaled(80)))
        }
    }
}

#Preview {
    LetterRacingGameView(onDone: {})
}
