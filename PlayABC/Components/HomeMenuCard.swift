//
//  HomeMenuCard.swift
//  PlayABC
//

import SwiftUI

/// One of the two home cards: Learning or Games. Use `action` for navigation/callback; set `playSound: false` for silent tap (e.g. Learn ABC).
struct HomeMenuCard: View {
    var label: String?
    let title: String
    let subtitle: String
    let emoji: String
    let accent: Color
    let action: () -> Void
    var playSound: Bool = true

    private var cardContent: some View {
        HStack(spacing: Layout.spacingXL) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.3))
                    .frame(width: Layout.scaled(92), height: Layout.scaled(92))
                Text(emoji)
                    .font(.system(size: Layout.scaled(48)))
            }
            VStack(alignment: .leading, spacing: Layout.spacingS) {
                if let label = label, !label.isEmpty {
                    Text(label)
                        .font(.system(size: Layout.fontCaption, weight: .bold, design: .rounded))
                        .foregroundColor(ColorManager.textSecondaryOnLight)
                }
                Text(title)
                    .font(.system(size: Layout.fontTitle3, weight: .bold, design: .rounded))
                    .foregroundColor(ColorManager.textOnCard())
                Text(subtitle)
                    .font(.system(size: Layout.fontCaption, weight: .medium, design: .rounded))
                    .foregroundColor(ColorManager.textSecondaryOnLight)
            }
            Spacer()
            Image(systemName: "chevron.right.circle.fill")
                .font(.system(size: Layout.fontLarge))
                .foregroundColor(accent)
        }
        .padding(Layout.paddingCard)
        .background(
            RoundedRectangle(cornerRadius: Layout.cornerRadiusCard, style: .continuous)
                .fill(ColorManager.accentWhite)
                .shadow(color: .white.opacity(0.8), radius: Layout.scaled(20), x: 0, y: 0)
                .shadow(color: .white.opacity(0.4), radius: Layout.scaled(8), x: 0, y: 0)
                .shadow(color: accent.opacity(0.2), radius: Layout.scaled(12), x: 0, y: Layout.scaled(6))
                .shadow(color: .black.opacity(0.06), radius: Layout.spacingL, x: 0, y: 4)
        )
    }

    var body: some View {
        Button(action: {
            if playSound { SoundManager.shared.playTap() }
            action()
        }) { cardContent }
        .buttonStyle(PressableCardStyle())
        .accessibilityLabel("\(title). \(subtitle)")
        .accessibilityHint("Double tap to open")
    }
}

/// Scale on press for cards.
struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
