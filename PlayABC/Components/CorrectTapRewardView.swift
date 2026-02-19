//
//  CorrectTapRewardView.swift
//  PlayABC
//

import SwiftUI

/// Peaceful “you got it” effect: a star that pops and fades when the user selects the correct answer.
struct CorrectTapRewardView: View {
    @State private var scale: CGFloat = 0.4
    @State private var opacity: Double = 1

    var body: some View {
        Image(systemName: "star.fill")
            .font(.system(size: Layout.scaled(40)))
            .foregroundStyle(
                LinearGradient(
                    colors: [Color(red: 1, green: 0.85, blue: 0.2), Color(red: 1, green: 0.6, blue: 0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .shadow(color: .orange.opacity(0.5), radius: 4)
            .scaleEffect(scale)
            .opacity(opacity)
            .allowsHitTesting(false)
            .onAppear {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.65)) {
                    scale = 1.35
                }
                withAnimation(.easeOut(duration: 0.45).delay(0.25)) {
                    opacity = 0
                }
            }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        CorrectTapRewardView()
    }
}
