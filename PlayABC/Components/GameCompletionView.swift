//
//  GameCompletionView.swift
//  PlayABC
//

import SwiftUI

/// Shared completion screen for all games: icon, title, subtitle, "Play Again or Back" button, and WinningDoggieView.
struct GameCompletionView<Icon: View>: View {
    let title: String
    let subtitle: String
    let accentColor: Color
    let onDone: () -> Void
    @ViewBuilder let icon: () -> Icon

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: Layout.scaled(32)) {
                icon()
                VStack(spacing: Layout.spacingL) {
                    Text(title)
                        .font(.system(size: Layout.fontLarge, weight: .black, design: .rounded))
                        .foregroundColor(ColorManager.textOnCard())
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(subtitle)
                        .font(.system(size: Layout.fontTitle2, weight: .semibold, design: .rounded))
                        .foregroundColor(ColorManager.textSecondaryOnLight)
                }
                .padding(.horizontal, Layout.scaled(36))
                .padding(.vertical, Layout.scaled(28))
                .background(
                    RoundedRectangle(cornerRadius: Layout.cornerRadiusCard, style: .continuous)
                        .fill(ColorManager.accentWhite)
                        .shadow(color: accentColor.opacity(0.25), radius: Layout.spacingL, x: 0, y: Layout.spacingS)
                        .shadow(color: .black.opacity(0.08), radius: Layout.scaled(10), x: 0, y: 4)
                )
                Button {
                    SoundManager.shared.playTap()
                    onDone()
                } label: {
                    Text(String(localized: "Play Again or Back"))
                        .font(.system(size: Layout.fontTitle3, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, Layout.scaled(28))
                        .padding(.vertical, Layout.scaled(14))
                        .background(Capsule().fill(accentColor))
                }
                .accessibilityLabel(String(localized: "Play Again or Back"))
                .accessibilityHint("Returns to the game menu")
                .padding(.top, Layout.spacingM)
            }
            .padding(Layout.scaled(28))
            .frame(maxWidth: .infinity)

            Spacer(minLength: Layout.spacingL)

            WinningDoggieView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(title). \(subtitle)")
    }
}
