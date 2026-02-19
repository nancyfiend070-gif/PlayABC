//
//  GameView.swift
//  PlayABC
//

import SwiftUI

/// Container that shows the correct game screen for the selected game type.
struct GameView: View {
    let gameType: GameType
    let onDone: () -> Void

    var body: some View {
        switch gameType {
        case .matchLetterPicture:
            MatchingGameView(onDone: onDone)
        case .findLetter:
            FindLetterGameView(onDone: onDone)
        // case .letterTracing:
        //     LetterTracingGameView(onDone: onDone)
        case .letterSound:
            LetterSoundGameView(onDone: onDone)
        // case .dragDropPuzzle:
        //     DragDropPuzzleGameView(onDone: onDone)
        case .popBalloon:
            PopBalloonGameView(onDone: onDone)
        case .memoryFlip:
            MemoryFlipGameView(onDone: onDone)
        case .letterRacing:
            LetterRacingGameView(onDone: onDone)
        case .colorLetter:
            ColorLetterGameView(onDone: onDone)
        }
    }
}

#Preview {
    GameView(gameType: .matchLetterPicture, onDone: {})
}
