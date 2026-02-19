//
//  ColorLetterGameView.swift
//  PlayABC
//

import SwiftUI

/// Show big letter; kid picks color to paint it; unlock sticker reward. Creative mode.
struct ColorLetterGameView: View {
    static let roundsTotal = 3
    static let letters = ["A", "B", "C", "D", "E", "F"]
    static let palette: [Color] = [
        ColorManager.letterCoral,
        ColorManager.letterSkyBlue,
        ColorManager.letterSunshine,
        ColorManager.letterMint,
        ColorManager.letterViolet,
        ColorManager.letterPink
    ]

    let onDone: () -> Void

    @State private var currentRound = 0
    @State private var currentLetter: String = "A"
    @State private var selectedColor: Color = ColorManager.letterCoral
    @State private var letterColor: Color = ColorManager.letterCoral
    @State private var showCelebration = false
    @State private var showSticker = false
    @State private var stickersEarned = 0

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
        VStack(spacing: Layout.spacingL) {
            Text("Color the letter!")
                .gamePromptStyle(glowColor: ColorManager.letterPink)
                .padding(.horizontal)

            HStack(spacing: Layout.spacingS) {
                ForEach(0..<Self.roundsTotal, id: \.self) { i in
                    Image(systemName: i < stickersEarned ? "star.circle.fill" : "star.circle")
                        .font(.system(size: Layout.scaled(26)))
                        .foregroundColor(i < stickersEarned ? ColorManager.letterPink : ColorManager.textSecondaryOnLight)
                }
            }

            Text(currentLetter)
                .font(.system(size: Layout.scaled(120), weight: .black, design: .rounded))
                .foregroundColor(letterColor)
                .shadow(color: letterColor.opacity(0.4), radius: 8)
                .padding(.vertical, Layout.spacingM)

            Text("Tap a color")
                .font(.system(size: Layout.fontCaption, weight: .semibold, design: .rounded))
                .foregroundColor(ColorManager.textSecondaryOnLight)

            HStack(spacing: Layout.spacingM) {
                ForEach(Array(Self.palette.enumerated()), id: \.offset) { _, color in
                    Circle()
                        .fill(color)
                        .frame(width: Layout.scaled(44), height: Layout.scaled(44))
                        .overlay(
                            Circle()
                                .stroke(selectedColor == color ? Color.white : .clear, lineWidth: 4)
                        )
                        .shadow(color: color.opacity(0.5), radius: 4)
                        .onTapGesture {
                            SoundManager.shared.playTap()
                            selectedColor = color
                            letterColor = color
                        }
                }
            }
            .padding(.vertical, Layout.spacingS)

            Button {
                SoundManager.shared.playCoinPickup()
                SpeechManager.shared.speakGreatJob()
                showSticker = true
                stickersEarned += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    showSticker = false
                    advanceRound()
                }
            } label: {
                Text("Done! Get sticker ⭐")
                    .font(.system(size: Layout.fontTitle3, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, Layout.spacingXL)
                    .padding(.vertical, Layout.spacingM)
                    .background(Capsule().fill(ColorManager.letterPink))
            }
            .padding(.top, Layout.spacingM)
            .overlay {
                if showSticker {
                    CorrectTapRewardView()
                }
            }

            Spacer()
        }
        .padding(.top, Layout.spacingM)
    }

    private func nextRound() {
        currentLetter = Self.letters[currentRound % Self.letters.count]
        selectedColor = Self.palette[currentRound % Self.palette.count]
        letterColor = selectedColor
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
        GameCompletionView(title: "You earned \(stickersEarned) stickers!", subtitle: "So creative!", accentColor: ColorManager.letterPink, onDone: onDone) {
            Text("⭐")
                .font(.system(size: Layout.scaled(80)))
        }
    }
}

#Preview {
    ColorLetterGameView(onDone: {})
}
