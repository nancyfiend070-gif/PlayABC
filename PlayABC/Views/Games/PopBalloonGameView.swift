//
//  PopBalloonGameView.swift
//  PlayABC
//

import SwiftUI
import Combine

/// Same style as in-game pop letter balloon (pastel, 50% opacity, glossy). Use for completion screen and menu card.
struct BalloonIconView: View {
    var size: CGFloat = Layout.scaled(56)
    var color: Color = Color(red: 1.0, green: 0.7, blue: 0.8)
    /// Letter shown inside the balloon for clarity (e.g. "A" or "ABC"). Use "A" for a clean look.
    var letter: String? = "A"

    var body: some View {
        let corner = size * 0.45
        ZStack {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(color.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .stroke(color.opacity(0.6), lineWidth: 2)
                )
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.5), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
            if let letter = letter, !letter.isEmpty {
                Text(letter)
                    .font(.system(size: size * (letter.count == 1 ? 0.5 : 0.28), weight: .bold, design: .rounded))
                    .foregroundStyle(Color.primary.opacity(0.85))
            }
        }
        .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
        .frame(width: size, height: size * 1.15)
    }
}

/// One alphabet as question; colorful balloons float; kid pops the matching letter. Burst + confetti on correct.
struct PopBalloonGameView: View {
    static let roundsTotal = 5
    static let balloonsPerRound = 6
    static let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map { String($0) }

    /// Soft pastel colors, 50% opacity for balloons
    private static let balloonPastels: [Color] = [
        Color(red: 1.0, green: 0.7, blue: 0.8),   // soft pink
        Color(red: 0.7, green: 0.85, blue: 1.0),   // soft blue
        Color(red: 1.0, green: 0.9, blue: 0.6),    // soft yellow
        Color(red: 0.7, green: 0.95, blue: 0.85),  // soft mint
        Color(red: 0.85, green: 0.75, blue: 1.0), // soft violet
        Color(red: 1.0, green: 0.8, blue: 0.7),   // soft peach
    ]

    let onDone: () -> Void

    @State private var currentRound = 0
    @State private var targetLetter: String = "A"
    @State private var balloonLetters: [String] = []
    @State private var showCelebration = false
    @State private var showPopConfetti = false
    @State private var encouragingText: String? = nil
    /// Index of balloon that was just popped (burst + then invisible)
    @State private var poppedIndex: Int? = nil
    /// Wrong tap: shake this index
    @State private var wrongShakeIndex: Int? = nil
    /// Burst scale for pop animation
    @State private var burstScale: CGFloat = 1
    @State private var burstOpacity: Double = 1
    /// Floating phase per balloon (0..<1) for gentle drift
    @State private var floatPhases: [CGFloat] = []
    /// Time value for continuous gentle floating (slow, kid-friendly)
    @State private var floatTime: Double = 0
    @State private var floatTimerCancellable: AnyCancellable?
    /// Cancel delayed round/celebration work when leaving the screen.
    @State private var delayedWorkItem: DispatchWorkItem?

    private var isGameComplete: Bool { currentRound >= Self.roundsTotal }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                AnimatedScreenBackground(gradientPageIndex: 1)
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
                if showPopConfetti {
                    LottieView.celebration(LottieManager.Celebration.confetti)
                        .opacity(0.85)
                        .allowsHitTesting(false)
                }
                if let text = encouragingText {
                    Text(text)
                        .font(.system(size: Layout.fontDisplay, weight: .black, design: .rounded))
                        .foregroundColor(ColorManager.textOnCard())
                        .shadow(color: .white.opacity(0.8), radius: 4)
                        .transition(.scale.combined(with: .opacity))
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
            floatTimerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    guard !isGameComplete else { return }
                    floatTime += 0.04
                }
        }
        .onDisappear {
            floatTimerCancellable?.cancel()
            delayedWorkItem?.cancel()
            delayedWorkItem = nil
        }
    }

    private var roundView: some View {
        GeometryReader { geo in
            let padding = Layout.paddingCard * 2
            let spacing = Layout.spacingL
            let cols: CGFloat = 3
            let availableW = geo.size.width - padding * 2 - spacing * (cols - 1)
            let cellSize = min(availableW / cols, Layout.scaled(130))
            let cellHeight = cellSize * 1.15

            VStack(spacing: Layout.spacingM) {
                Text("Tiger says: Pop the letter \(targetLetter)!")
                    .font(.system(size: Layout.fontTitle2, weight: .bold, design: .rounded))
                    .foregroundColor(ColorManager.textOnCard())
                    .gamePromptStyle(glowColor: ColorManager.letterPink)
                    .padding(.horizontal)
                    .accessibilityLabel("Tiger says: Pop the letter \(targetLetter)")
                    .accessibilityAddTraits(.isHeader)

                Color.clear
                    .frame(height: Layout.scaled(20))

                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: spacing),
                    GridItem(.flexible(), spacing: spacing),
                    GridItem(.flexible(), spacing: spacing)
                ], spacing: spacing) {
                    ForEach(Array(balloonLetters.enumerated()), id: \.offset) { index, letter in
                        balloonCell(letter: letter, index: index, cellSize: cellSize, cellHeight: cellHeight)
                    }
                }
                .padding(.horizontal, Layout.paddingCard)
                .frame(maxWidth: .infinity)

                Spacer(minLength: 0)
            }
            .padding(.top, Layout.spacingS)
        }
    }

    private func balloonCell(letter: String, index: Int, cellSize: CGFloat, cellHeight: CGFloat) -> some View {
        let isPopped = poppedIndex == index
        let isWrongShake = wrongShakeIndex == index
        let color = Self.balloonPastels[index % Self.balloonPastels.count]
        let phase = floatPhases.indices.contains(index) ? floatPhases[index] : 0

        return Button {
            if isPopped { return }
            if letter == targetLetter {
                correctPop(index: index)
            } else {
                wrongTap(index: index)
            }
        } label: {
            ZStack {
                if !isPopped || poppedIndex == index {
                    balloonShape(color: color, cellSize: cellSize, cellHeight: cellHeight, index: index)
                        .scaleEffect(poppedIndex == index ? burstScale : 1)
                        .opacity(poppedIndex == index ? burstOpacity : 1)
                }
                if poppedIndex == index {
                    burstFragmentsView(size: cellSize)
                }
                Text(letter)
                    .font(.system(size: cellSize * 0.48, weight: .bold, design: .rounded))
                    .foregroundColor(ColorManager.textOnCard())
                    .opacity(isPopped ? 0 : 1)
            }
            .frame(width: cellSize, height: cellHeight)
            .offset(y: floatOffset(phase: phase + CGFloat(floatTime)))
            .offset(x: isWrongShake ? -6 : 0)
            .animation(.default.repeatCount(3, autoreverses: true).speed(20), value: isWrongShake)
        }
        .buttonStyle(.plain)
        .disabled(isPopped)
    }

    private func balloonShape(color: Color, cellSize: CGFloat, cellHeight: CGFloat, index: Int) -> some View {
        let corner = cellSize * 0.45
        return ZStack {
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(color.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .stroke(color.opacity(0.6), lineWidth: 2)
                )
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.5), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .allowsHitTesting(false)
        }
        .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
    }

    private func burstFragmentsView(size: CGFloat) -> some View {
        let positions: [(CGFloat, CGFloat)] = [(0, -1), (0.7, -0.7), (0.7, 0.7), (-0.7, 0.7), (-0.7, -0.7), (1, 0), (-1, 0), (0, 1)]
        return ZStack {
            ForEach(Array(positions.enumerated()), id: \.offset) { i, p in
                Circle()
                    .fill(Self.balloonPastels[i % Self.balloonPastels.count].opacity(0.7))
                    .frame(width: size * 0.15, height: size * 0.15)
                    .offset(x: p.0 * size * 0.4, y: p.1 * size * 0.4)
            }
        }
        .allowsHitTesting(false)
    }

    private func floatOffset(phase: CGFloat) -> CGFloat {
        sin(phase * .pi * 2) * 10
    }

    private func correctPop(index: Int) {
        SoundManager.shared.playCoinPickup()
        SpeechManager.shared.speakRewardPhrase()
        withAnimation(.easeOut(duration: 0.15)) {
            burstScale = 1.2
        }
        withAnimation(.easeOut(duration: 0.25).delay(0.1)) {
            burstScale = 0
            burstOpacity = 0
        }
        poppedIndex = index
        showPopConfetti = true
        encouragingText = ["⭐ Great!", "🎉 Awesome!", "🌟 Nice!", "✨ Super!", "💫 You did it!"].randomElement()
        withAnimation(.easeOut(duration: 0.3)) {
            encouragingText = encouragingText
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            showPopConfetti = false
            encouragingText = nil
            poppedIndex = nil
            burstScale = 1
            burstOpacity = 1
            advanceRound()
        }
    }

    private func wrongTap(index: Int) {
        SoundManager.shared.playTap()
        SpeechManager.shared.speakOops()
        wrongShakeIndex = index
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            wrongShakeIndex = nil
        }
    }

    private func nextRound() {
        poppedIndex = nil
        burstScale = 1
        burstOpacity = 1
        let all = Self.letters
        guard let target = all.randomElement() else { return }
        targetLetter = target
        var balloons: [String] = [target]
        let others = all.filter { $0 != target }
        while balloons.count < Self.balloonsPerRound {
            balloons.append(others.randomElement() ?? "A")
        }
        balloons.shuffle()
        balloonLetters = balloons
        floatPhases = (0..<balloons.count).map { _ in CGFloat.random(in: 0...1) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            SpeechManager.shared.speakLetter(targetLetter)
        }
    }

    private func advanceRound() {
        currentRound += 1
        if currentRound >= Self.roundsTotal {
            SoundManager.shared.playRewardCelebration()
            showCelebration = true
            let item = DispatchWorkItem { showCelebration = false }
            delayedWorkItem = item
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: item)
        } else {
            let item = DispatchWorkItem { nextRound() }
            delayedWorkItem = item
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: item)
        }
    }

    private var completionView: some View {
        GameCompletionView(title: "You popped them all!", subtitle: "Super fast!", accentColor: ColorManager.letterPink, onDone: onDone) {
            BalloonIconView(size: Layout.scaled(72))
        }
    }
}

#Preview {
    PopBalloonGameView(onDone: {})
}
