//
//  MemoryFlipGameView.swift
//  PlayABC
//

import SwiftUI

/// Cards face down; match letter with picture (e.g. A ↔ Apple). Memory + concentration.
struct MemoryFlipGameView: View {
    static let pairsCount = 6

    let onDone: () -> Void

    /// Each card is either a letter or an emoji for the same item; pairs match by item.letter.
    @State private var cards: [(item: LetterLearningItem, isLetter: Bool)] = []
    @State private var flippedIndices: [Int] = []
    @State private var matchedPairs: Set<String> = []
    @State private var showCelebration = false
    @State private var rewardIndex: Int? = nil

    private var allMatched: Bool { matchedPairs.count == Self.pairsCount }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                AnimatedScreenBackground(gradientPageIndex: 3)
                if allMatched {
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

            if !allMatched {
                CornerMascotView()
            }
        }
        .onAppear {
            setupGame()
        }
    }

    private var roundView: some View {
        VStack(spacing: Layout.spacingL) {
            Text("Match letter with picture")
                .gamePromptStyle(glowColor: ColorManager.letterTeal)
                .padding(.horizontal)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Layout.gridSpacing) {
                ForEach(Array(cards.enumerated()), id: \.offset) { index, pair in
                    memoryCard(item: pair.item, isLetter: pair.isLetter, index: index)
                }
            }
            .padding(.horizontal, Layout.paddingCard)

            Spacer()
        }
        .padding(.top, Layout.spacingM)
    }

    private func memoryCard(item: LetterLearningItem, isLetter: Bool, index: Int) -> some View {
        let isFlipped = flippedIndices.contains(index) || matchedPairs.contains(item.letter)
        let showReward = rewardIndex == index
        return Button {
            guard !matchedPairs.contains(item.letter), flippedIndices.count < 2 else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                flippedIndices.append(index)
            }
            if flippedIndices.count == 2 {
                let first = cards[flippedIndices[0]]
                let second = cards[flippedIndices[1]]
                if first.item.letter == second.item.letter {
                    SoundManager.shared.playCoinPickup()
                    rewardIndex = index
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { rewardIndex = nil }
                    matchedPairs.insert(first.item.letter)
                    flippedIndices = []
                    if matchedPairs.count == Self.pairsCount {
                        SoundManager.shared.playRewardCelebration()
                        showCelebration = true
                    }
                } else {
                    SoundManager.shared.playTap()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        flippedIndices = []
                    }
                }
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: Layout.cornerRadiusCell, style: .continuous)
                    .fill(isFlipped ? ColorManager.accentWhite : ColorManager.letterTeal.opacity(0.4))
                    .frame(height: Layout.scaled(90))
                    .overlay {
                        if isFlipped {
                            VStack(spacing: 2) {
                                if isLetter {
                                    Text(item.letter)
                                        .font(.system(size: Layout.fontTitle1, weight: .bold, design: .rounded))
                                        .foregroundColor(ColorManager.textOnCard())
                                } else {
                                    Text(item.emoji)
                                        .font(.system(size: Layout.scaled(36)))
                                }
                            }
                            if showReward {
                                CorrectTapRewardView()
                            }
                        } else {
                            Text("?")
                                .font(.system(size: Layout.fontDisplay, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
            }
        }
        .buttonStyle(.plain)
        .disabled(flippedIndices.count == 2)
    }

    private func setupGame() {
        let pool = LetterLearningData.allItems.shuffled()
        let chosen = Array(pool.prefix(Self.pairsCount))
        cards = chosen.flatMap { [(item: $0, isLetter: true), (item: $0, isLetter: false)] }.shuffled()
        flippedIndices = []
        matchedPairs = []
    }

    private var completionView: some View {
        GameCompletionView(title: "You remembered them all!", subtitle: "Great memory!", accentColor: ColorManager.letterTeal, onDone: onDone) {
            Text("🧠")
                .font(.system(size: Layout.scaled(80)))
        }
    }
}

#Preview {
    MemoryFlipGameView(onDone: {})
}
