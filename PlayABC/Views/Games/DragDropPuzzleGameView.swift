//
//  DragDropPuzzleGameView.swift
//  PlayABC
//

import SwiftUI

// MARK: - Preference keys for drag-and-drop frame tracking
private struct BlankFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) { value = nextValue() }
}

private struct LetterFramesKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

/// Drag & drop: show word with blank (e.g. C _ T), letters below; kid drags letter to the blank to complete the word.
struct DragDropPuzzleGameView: View {
    static let roundsTotal = 5

    let onDone: () -> Void

    @State private var currentRound = 0
    @State private var puzzle: WordPuzzleItem = WordPuzzleItem.puzzles[0]
    @State private var options: [String] = []
    @State private var filledLetter: String? = nil
    @State private var showCelebration = false
    @State private var showReward = false
    /// Real drag: letter follows finger; drop on blank to place.
    @State private var draggedLetter: String? = nil
    @State private var dragTranslation: CGSize = .zero
    @State private var blankFrame: CGRect = .zero
    @State private var letterFrames: [String: CGRect] = [:]

    private var isGameComplete: Bool { currentRound >= Self.roundsTotal }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                AnimatedScreenBackground(gradientPageIndex: 0)
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
        ZStack(alignment: .topLeading) {
            VStack(spacing: Layout.spacingXXL) {
                Text("Complete the word!")
                    .gamePromptStyle(glowColor: ColorManager.letterMint)
                    .padding(.horizontal)

                Text("Drag a letter to the blank")
                    .font(.system(size: Layout.fontCaption, weight: .medium, design: .rounded))
                    .foregroundColor(ColorManager.textSecondaryOnLight)

                HStack(spacing: Layout.spacingS) {
                    ForEach(Array(puzzle.prompt.split(separator: " ").map(String.init).enumerated()), id: \.offset) { _, part in
                        if part == "_" {
                            blankSlot
                        } else {
                            Text(part)
                                .font(.system(size: Layout.fontLetterBig, weight: .bold, design: .rounded))
                                .foregroundColor(ColorManager.textOnCard())
                        }
                    }
                }
                .padding(.vertical, Layout.spacingL)

                HStack(spacing: Layout.spacingXL) {
                    ForEach(options, id: \.self) { letter in
                        letterDraggable(letter: letter)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, Layout.spacingM)
            .coordinateSpace(name: "dropSpace")
            .onPreferenceChange(BlankFrameKey.self) { blankFrame = $0 }
            .onPreferenceChange(LetterFramesKey.self) { letterFrames = $0 }

            if let letter = draggedLetter, let frame = letterFrames[letter] {
                Text(letter)
                    .font(.system(size: Layout.fontLetter, weight: .bold, design: .rounded))
                    .foregroundColor(ColorManager.textOnCard())
                    .frame(width: Layout.scaled(56), height: Layout.scaled(56))
                    .background(
                        RoundedRectangle(cornerRadius: Layout.cornerRadiusCell, style: .continuous)
                            .fill(ColorManager.accentWhite)
                            .shadow(color: .black.opacity(0.25), radius: 8)
                    )
                    .position(
                        x: frame.midX + dragTranslation.width,
                        y: frame.midY + dragTranslation.height
                    )
                    .allowsHitTesting(false)
            }
        }
    }

    private var blankSlot: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Layout.cornerRadiusCell, style: .continuous)
                .stroke(
                    draggedLetter != nil ? ColorManager.letterMint : ColorManager.letterMint.opacity(0.6),
                    style: StrokeStyle(lineWidth: draggedLetter != nil ? 4 : 3, dash: [8, 6])
                )
                .frame(width: Layout.scaled(56), height: Layout.scaled(64))
            if let letter = filledLetter {
                Text(letter)
                    .font(.system(size: Layout.fontLetter, weight: .bold, design: .rounded))
                    .foregroundColor(ColorManager.textOnCard())
            } else {
                Text("Drop here")
                    .font(.system(size: Layout.fontCaption, weight: .semibold, design: .rounded))
                    .foregroundColor(ColorManager.letterMint.opacity(0.8))
            }
        }
        .frame(width: Layout.scaled(64), height: Layout.scaled(72))
        .background(
            GeometryReader { g in
                Color.clear.preference(key: BlankFrameKey.self, value: g.frame(in: .named("dropSpace")))
            }
        )
    }

    private func letterDraggable(letter: String) -> some View {
        let isDragging = draggedLetter == letter
        return Text(letter)
            .font(.system(size: Layout.fontLetter, weight: .bold, design: .rounded))
            .foregroundColor(ColorManager.textOnCard())
            .frame(width: Layout.scaled(56), height: Layout.scaled(56))
            .background(
                RoundedRectangle(cornerRadius: Layout.cornerRadiusCell, style: .continuous)
                    .fill(ColorManager.accentWhite)
                    .shadow(color: .black.opacity(0.08), radius: 4)
            )
            .overlay {
                if showReward && letter == puzzle.correctLetter {
                    CorrectTapRewardView()
                }
            }
            .opacity(isDragging ? 0.4 : 1)
            .background(
                GeometryReader { g in
                    Color.clear.preference(key: LetterFramesKey.self, value: [letter: g.frame(in: .named("dropSpace"))])
                }
            )
            .gesture(
                DragGesture(minimumDistance: 8)
                    .onChanged { value in
                        if filledLetter != nil { return }
                        if draggedLetter == nil { SoundManager.shared.playTap() }
                        draggedLetter = letter
                        dragTranslation = value.translation
                    }
                    .onEnded { value in
                        guard draggedLetter == letter else { return }
                        let frame = letterFrames[letter] ?? .zero
                        let dropCenter = CGPoint(
                            x: frame.midX + value.translation.width,
                            y: frame.midY + value.translation.height
                        )
                        if blankFrame.contains(dropCenter) {
                            filledLetter = letter
                            if letter == puzzle.correctLetter {
                                SoundManager.shared.playCoinPickup()
                                SpeechManager.shared.speakRewardPhrase()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    SpeechManager.shared.speakWord(puzzle.word)
                                }
                                showReward = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    showReward = false
                                    advanceRound()
                                }
                            } else {
                                SoundManager.shared.playTap()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    filledLetter = nil
                                }
                            }
                        }
                        draggedLetter = nil
                        dragTranslation = .zero
                    }
            )
    }

    private func nextRound() {
        filledLetter = nil
        draggedLetter = nil
        dragTranslation = .zero
        showReward = false
        puzzle = WordPuzzleItem.puzzles[currentRound % WordPuzzleItem.puzzles.count]
        let all = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map { String($0) }
        let others = all.filter { $0 != puzzle.correctLetter }
        let wrongs = Array(others.shuffled().prefix(2))
        options = ([puzzle.correctLetter] + wrongs).shuffled()
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
        GameCompletionView(title: "Word wizard!", subtitle: "You completed the words!", accentColor: ColorManager.letterMint, onDone: onDone) {
            Text("🐱")
                .font(.system(size: Layout.scaled(80)))
        }
    }
}

#Preview {
    DragDropPuzzleGameView(onDone: {})
}
