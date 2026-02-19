import SwiftUI

/// A bubbly, colorful letter button style used on the home screen.
struct LetterButtonStyle: ButtonStyle {
    let backgroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: Layout.letterButtonHeight)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Layout.cornerRadiusButton, style: .continuous)
                    .fill(backgroundColor)
                    .shadow(color: Color.black.opacity(0.12), radius: Layout.spacingL, x: 0, y: 4)
            )
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .animation(AnimationConfig.tapSpring, value: configuration.isPressed)
    }
}

