//
//  LearnABCView.swift
//  PlayABC
//

import SwiftUI

/// Learning section: shows the ABC letter PageView (swipeable carousel) directly.
struct LearnABCView: View {
    var body: some View {
        SwipeableLettersView(startIndex: 0, skipInitialSpeech: true)
    }

    // MARK: - Commented: ABC learning grid (replaced by direct PageView above)
    /*
    private let letters: [AlphabetLetter] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map {
        AlphabetLetter(character: String($0))
    }

    private var lettersGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: Layout.gridSpacing), count: Layout.gridColumns)
        return ScrollView {
            LazyVGrid(columns: columns, spacing: Layout.gridSpacing) {
                ForEach(Array(letters.enumerated()), id: \.element.id) { index, letter in
                    LetterButtonView(
                        letter: letter.character,
                        backgroundColor: ColorManager.buttonColor(forLetterIndex: index)
                    ) {
                        onLetterSelected(index)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, Layout.spacingXXL)
        }
    }
    */
}

#Preview {
    NavigationStack {
        LearnABCView()
    }
}
