//
//  LetterTracingGameView.swift
//  PlayABC
//

import SwiftUI

/// Interactive writing: kid traces dotted letter with finger. Correct → tiger cheers + sparkles + "Great job!" + star. Wrong → gentle glow shows correct path.
struct LetterTracingGameView: View {
    static let roundsTotal = 5
    static let letters = ["A", "B", "C", "D", "E"]

    let onDone: () -> Void

    @State private var currentRound = 0
    @State private var currentLetter: String = "A"
    @State private var strokePoints: [CGPoint] = []
    @State private var showSuccess = false
    @State private var showWrongGlow = false
    @State private var showCelebration = false
    @State private var starsEarned = 0
    @State private var sparklePositions: [CGPoint] = []
    @State private var letterRect: CGRect = .zero

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
            Text("Trace the letter")
                .gamePromptStyle(glowColor: ColorManager.letterSunshine)
                .padding(.horizontal)

            HStack(spacing: Layout.spacingS) {
                ForEach(0..<Self.roundsTotal, id: \.self) { i in
                    Image(systemName: i < starsEarned ? "star.fill" : "star")
                        .font(.system(size: Layout.scaled(24)))
                        .foregroundColor(i < starsEarned ? ColorManager.letterSunshine : ColorManager.textSecondaryOnLight)
                }
            }

            letterTracingArea
        }
        .padding(.top, Layout.spacingM)
    }

    private var letterTracingArea: some View {
        GeometryReader { geo in
            let rect = geo.frame(in: .local)
            ZStack {
                if let path = LetterPathHelper.path(for: Character(currentLetter), in: rect) {
                    path
                        .stroke(
                            showWrongGlow ? ColorManager.letterSunshine : ColorManager.textOnCard().opacity(0.5),
                            style: StrokeStyle(lineWidth: Layout.scaled(12), lineCap: .round, lineJoin: .round, dash: [Layout.scaled(8), Layout.scaled(6)])
                        )
                        .shadow(color: showWrongGlow ? ColorManager.letterSunshine.opacity(0.8) : .clear, radius: Layout.scaled(16))
                        .animation(.easeInOut(duration: 0.3), value: showWrongGlow)

                    if showWrongGlow {
                        path
                            .stroke(ColorManager.letterSunshine.opacity(0.4), lineWidth: Layout.scaled(20))
                            .blur(radius: Layout.scaled(8))
                    }
                }

                ForEach(Array(strokePoints.enumerated()), id: \.offset) { _, pt in
                    Circle()
                        .fill(ColorManager.letterSunshine.opacity(0.7))
                        .frame(width: Layout.scaled(10), height: Layout.scaled(10))
                        .position(pt)
                }

                ForEach(Array(sparklePositions.enumerated()), id: \.offset) { _, pt in
                    Image(systemName: "sparkle")
                        .font(.system(size: Layout.scaled(14)))
                        .foregroundColor(.white)
                        .position(pt)
                }

                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 2)
                            .onChanged { value in
                                let pt = value.location
                                strokePoints.append(pt)
                                if let path = LetterPathHelper.path(for: Character(currentLetter), in: rect) {
                                    let d = LetterPathHelper.distance(from: pt, to: path, sampleStep: 5)
                                    if d < Layout.scaled(25) && sparklePositions.count < 30 {
                                        sparklePositions.append(pt)
                                    }
                                }
                            }
                            .onEnded { value in
                                evaluateStroke(in: rect)
                            }
                    )
            }
            .background(
                RoundedRectangle(cornerRadius: Layout.cornerRadiusCard, style: .continuous)
                    .fill(ColorManager.accentWhite.opacity(0.6))
                    .shadow(color: .black.opacity(0.08), radius: Layout.scaled(10))
            )
            .onAppear { letterRect = rect }
        }
        .frame(height: Layout.scaled(280))
        .padding(.horizontal, Layout.paddingCard)
    }

    private func evaluateStroke(in rect: CGRect) {
        guard let path = LetterPathHelper.path(for: Character(currentLetter), in: rect) else {
            showWrong()
            return
        }
        let samples = LetterPathHelper.samplePoints(path: path, step: 6)
        guard !samples.isEmpty else {
            showWrong()
            return
        }
        var hitCount = 0
        for pt in strokePoints {
            let d = LetterPathHelper.distance(from: pt, to: path, sampleStep: 8)
            if d < Layout.scaled(30) { hitCount += 1 }
        }
        let ratio = Double(hitCount) / Double(max(1, strokePoints.count))
        let coverage = Double(strokePoints.count) / Double(max(1, samples.count)) * ratio
        if ratio >= 0.5 && strokePoints.count >= 20 {
            showSuccessState()
        } else {
            showWrong()
        }
    }

    private func showSuccessState() {
        SoundManager.shared.playCoinPickup()
        SpeechManager.shared.speakGreatJob()
        if let item = LetterLearningData.item(for: currentLetter) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                SpeechManager.shared.speakLetterSequence(letter: item.letter, word: item.word)
            }
        }
        showSuccess = true
        starsEarned += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showSuccess = false
            advanceRound()
        }
    }

    private func showWrong() {
        showWrongGlow = true
        SoundManager.shared.playTap()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            showWrongGlow = false
            strokePoints = []
            sparklePositions = []
        }
    }

    private func nextRound() {
        strokePoints = []
        sparklePositions = []
        showWrongGlow = false
        currentLetter = Self.letters[currentRound % Self.letters.count]
    }

    private func advanceRound() {
        strokePoints = []
        sparklePositions = []
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
        GameCompletionView(title: "Great job tracing!", subtitle: "You earned \(starsEarned) star\(starsEarned == 1 ? "" : "s")!", accentColor: ColorManager.letterSunshine, onDone: onDone) {
            Text("⭐")
                .font(.system(size: Layout.scaled(80)))
        }
    }
}

#Preview {
    LetterTracingGameView(onDone: {})
}
