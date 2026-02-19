import SwiftUI

/// A large, tappable letter button used on the home screen grid.
struct LetterButtonView: View {
    /// The letter character to display on this button.
    let letter: String

    /// Background color chosen from the theme palette.
    let backgroundColor: Color

    /// Action called when the button is tapped.
    let onTap: () -> Void

    var body: some View {
        Button(action: handleTap) {
            Text(letter)
                .font(.system(size: Layout.fontLetter, weight: .heavy, design: .rounded))
                .foregroundColor(ColorManager.textOnLetterButton())
        }
        .buttonStyle(LetterButtonStyle(backgroundColor: backgroundColor))
        .accessibilityLabel("Letter \(letter)")
    }

    /// Handles the tap and forwards the action.
    private func handleTap() {
        SoundManager.shared.playTap()
        onTap()
    }
}

#Preview {
    ZStack {
        Color.blue.opacity(0.4).ignoresSafeArea()
        LetterButtonView(letter: "A", backgroundColor: ColorManager.buttonColor(forLetterIndex: 0), onTap: {})
            .padding()
    }
}

