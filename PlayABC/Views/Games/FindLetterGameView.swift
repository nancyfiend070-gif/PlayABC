//
//  FindLetterGameView.swift
//  PlayABC
//

import SwiftUI

/// Short game: "Find the letter [X]" in a grid. 5 rounds, then celebration.
struct FindLetterGameView: View {
    static let roundsTotal = 5
    static let gridColumns = 4
    static let gridSize = 12

    let onDone: () -> Void

    @State private var currentRound = 0
    @State private var targetLetter: String = "A"
    @State private var gridLetters: [String] = []
    @State private var selectedIndices: Set<Int> = []
    @State private var wrongTappedIndex: Int? = nil
    @State private var showCelebration = false
    /// Index of the cell that just got a correct tap (shows peaceful star reward).
    @State private var rewardCellIndex: Int? = nil

    /// Number of target letters in the grid (must select all to advance).
    private let targetCount = 3

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
            Text("Find the letter")
                .gamePromptStyle(glowColor: ColorManager.letterSkyBlue)
                .padding(.horizontal, Layout.paddingScreen)

            Text(targetLetter)
                .font(.system(size: Layout.fontLetterBig, weight: .heavy, design: .rounded))
                .foregroundColor(ColorManager.textOnCard())

            let columns = Array(repeating: GridItem(.flexible(), spacing: Layout.gridSpacing), count: Self.gridColumns)
            LazyVGrid(columns: columns, spacing: Layout.gridSpacing) {
                ForEach(Array(gridLetters.enumerated()), id: \.offset) { index, letter in
                    letterCell(letter: letter, index: index)
                }
            }
            .padding(.horizontal, Layout.paddingCard)

            Spacer()
        }
        .padding(.top, Layout.scaled(32))
    }

    private func letterCell(letter: String, index: Int) -> some View {
        let isSelected = selectedIndices.contains(index)
        let isWrongShake = wrongTappedIndex == index
        return Button {
            if letter == targetLetter {
                if !isSelected {
                    selectedIndices.insert(index)
                    SoundManager.shared.playCoinPickup()
                    rewardCellIndex = index
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { rewardCellIndex = nil }
                    if selectedIndices.count == 1,
                       let item = LetterLearningData.item(for: letter) {
                        SpeechManager.shared.speakLetterSequence(letter: item.letter, word: item.word)
                    } else {
                        SpeechManager.shared.speakRewardPhrase()
                    }
                }
                if selectedIndices.count == targetCount { advanceRound() }
            } else {
                wrongTappedIndex = index
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { wrongTappedIndex = nil }
            }
        } label: {
            Text(letter)
                .font(.system(size: Layout.fontTitle1, weight: .bold, design: .rounded))
                .foregroundColor(ColorManager.textOnCard())
                .frame(width: Layout.iconSizeSmall, height: Layout.iconSizeSmall)
                .background(
                    RoundedRectangle(cornerRadius: Layout.cornerRadiusCell, style: .continuous)
                        .fill(ColorManager.accentWhite)
                        .overlay(
                            RoundedRectangle(cornerRadius: Layout.cornerRadiusCell, style: .continuous)
                                .stroke(isSelected ? ColorManager.letterSkyBlue : .clear, lineWidth: 3)
                        )
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                )
                .offset(x: isWrongShake ? -4 : 0)
                .animation(.default.repeatCount(2, autoreverses: true).speed(8), value: isWrongShake)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
                .overlay {
                    if rewardCellIndex == index {
                        CorrectTapRewardView()
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private var completionView: some View {
        GameCompletionView(title: "You found them all!", subtitle: "Great job!", accentColor: ColorManager.letterSkyBlue, onDone: onDone) {
            Text("🌟")
                .font(.system(size: Layout.scaled(80)))
        }
    }

    private func nextRound() {
        selectedIndices = []
        let all = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map { String($0) }
        // Avoid same letter two rounds in a row (first round can be any letter)
        let candidates = currentRound == 0 ? all : all.filter { $0 != targetLetter }
        guard let target = candidates.randomElement() else { return }
        targetLetter = target
        var grid: [String] = []
        for _ in 0..<targetCount {
            grid.append(target)
        }
        let others = all.filter { $0 != target }
        while grid.count < Self.gridSize {
            grid.append(others.randomElement() ?? "A")
        }
        grid.shuffle()
        gridLetters = grid
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                nextRound()
            }
        }
    }
}

#Preview {
    FindLetterGameView(onDone: {})
}
