//
//  GameMenuView.swift
//  PlayABC
//

import SwiftUI

/// Game types available for practice. Kept short and simple for kids.
enum GameType: String, CaseIterable, Identifiable, Hashable {
    case matchLetterPicture = "Match Letter & Picture"
    case findLetter = "Find the Letter"
    // case letterTracing = "Letter Tracing"
    case letterSound = "Letter Sound"
    // case dragDropPuzzle = "Drag & Drop Puzzle"
    case popBalloon = "Pop the Letter"
    case memoryFlip = "Memory Flip"
    case letterRacing = "Letter Racing"
    case colorLetter = "Color the Letter"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .matchLetterPicture: return "🖼️"
        case .findLetter: return "🔍"
        // case .letterTracing: return "✏️"
        case .letterSound: return "🔊"
        // case .dragDropPuzzle: return "🧩"
        case .popBalloon: return "🎈"
        case .memoryFlip: return "🃏"
        case .letterRacing: return "🐯"
        case .colorLetter: return "🖍️"
        }
    }

    var shortDescription: String {
        switch self {
        case .matchLetterPicture: return "Tap the picture that goes with the letter"
        case .findLetter: return "Tap the letter we ask for"
        // case .letterTracing: return "Trace the letter with your finger"
        case .letterSound: return "Listen to the sound, then pick the letter"
        // case .dragDropPuzzle: return "Drag the letter to complete the word"
        case .popBalloon: return "Pop the letter we say!"
        case .memoryFlip: return "Match letter with picture"
        case .letterRacing: return "Help the tiger run with correct answers"
        case .colorLetter: return "Color the letter and earn stickers"
        }
    }

    /// Accent color for this game’s card (gradient tint, border).
    var cardAccent: Color {
        switch self {
        case .matchLetterPicture: return ColorManager.letterCoral
        case .findLetter: return ColorManager.letterSkyBlue
        // case .letterTracing: return ColorManager.letterSunshine
        case .letterSound: return ColorManager.letterViolet
        // case .dragDropPuzzle: return ColorManager.letterMint
        case .popBalloon: return ColorManager.letterPink
        case .memoryFlip: return ColorManager.letterTeal
        case .letterRacing: return ColorManager.letterPeach
        case .colorLetter: return ColorManager.letterPink
        }
    }
}

/// Menu that lists available games. Tapping a row navigates to that game.
struct GameMenuView: View {
    /// Binding so the game screen is pushed from this view (back goes to menu, not home).
    @Binding var selectedGameType: GameType?
    /// Called when the user taps the back arrow to return to the home screen.
    var onBack: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AnimatedScreenBackground(gradientPageIndex: 1)

            VStack(spacing: 0) {
                headerWithBack
                ScrollView {
                    VStack(spacing: Layout.spacingXL) {
                        ForEach(GameType.allCases) { game in
                            gameCard(game)
                        }
                    }
                    .padding(.horizontal, Layout.paddingCard)
                    .padding(.bottom, Layout.spacingXXL)
                }
            }
            CornerMascotView()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(item: $selectedGameType) { gameType in
            GameView(gameType: gameType, onDone: { selectedGameType = nil })
        }
    }

    /// "Let's Play!" title, subtitle, and back arrow in one header for clear navigation.
    private var headerWithBack: some View {
        HStack(alignment: .top, spacing: Layout.spacingM) {
            if let onBack = onBack {
                Button {
                    SoundManager.shared.playTap()
                    onBack()
                } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: Layout.scaled(48)))
                        .foregroundColor(ColorManager.titleOnGradient())
                        .symbolRenderingMode(.hierarchical)
                }
                .accessibilityLabel("Back")
                .accessibilityHint("Returns to home screen")
            }

            VStack(alignment: .leading, spacing: Layout.spacingS) {
                Text("Let's Play!")
                    .font(.system(size: Layout.fontDisplay, weight: .black, design: .rounded))
                    .foregroundColor(ColorManager.titleOnGradient())
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if onBack != nil {
                Color.clear
                    .frame(width: Layout.scaled(48), height: Layout.scaled(48))
            }
        }
        .padding(.horizontal, Layout.paddingCard)
        .padding(.top, Layout.spacingL)
        .padding(.bottom, Layout.spacingM)
    }

    private func gameCard(_ game: GameType) -> some View {
        Button {
            SoundManager.shared.playTap()
            selectedGameType = game
        } label: {
            HStack(spacing: Layout.spacingXL) {
                ZStack {
                    Circle()
                        .fill(game.cardAccent.opacity(0.25))
                        .frame(width: Layout.iconSizeMedium, height: Layout.iconSizeMedium)
                    if case .popBalloon = game {
                        BalloonIconView(size: Layout.iconSizeMedium * 0.85)
                    } else {
                        Text(game.emoji)
                            .font(.system(size: Layout.fontLetter * 0.55))
                    }
                }
                VStack(alignment: .leading, spacing: Layout.spacingM) {
                    Text(game.rawValue)
                        .font(.system(size: Layout.fontTitle2, weight: .bold, design: .rounded))
                        .foregroundColor(ColorManager.textOnCard())
                        .lineLimit(2)
                    Text(game.shortDescription)
                        .font(.system(size: Layout.fontBody, weight: .medium, design: .rounded))
                        .foregroundColor(ColorManager.textSecondaryOnLight)
                        .lineLimit(2)
                }
                Spacer(minLength: Layout.spacingM)
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: Layout.fontTitle1))
                    .foregroundColor(game.cardAccent.opacity(0.9))
            }
            .padding(Layout.paddingCard)
            .background(
                RoundedRectangle(cornerRadius: Layout.cornerRadiusCard, style: .continuous)
                    .fill(ColorManager.accentWhite)
                    .overlay(
                        RoundedRectangle(cornerRadius: Layout.cornerRadiusCard, style: .continuous)
                            .stroke(game.cardAccent.opacity(0.35), lineWidth: 2)
                    )
                    .shadow(color: game.cardAccent.opacity(0.2), radius: Layout.scaled(12), x: 0, y: Layout.scaled(6))
                    .shadow(color: .black.opacity(0.06), radius: Layout.spacingL, x: 0, y: 4)
            )
        }
        .buttonStyle(PressableCardStyle())
    }
}

#Preview {
    NavigationStack {
        GameMenuView(selectedGameType: .constant(nil))
    }
}
