//
//  AnimatedScreenBackground.swift
//  PlayABC
//

import SwiftUI

/// Reusable animated Lottie background with a colored gradient overlay.
/// Use different `gradientPageIndex` (0–4) on each screen, or pass `customGradient` (e.g. home logo blue).
struct AnimatedScreenBackground: View {
    /// Which gradient theme to use (0–4). Ignored if `customGradient` is set.
    var gradientPageIndex: Int = 0
    /// When set, this gradient is used instead of the page index (e.g. home logo blue).
    var customGradient: LinearGradient?
    /// Opacity of the gradient overlay so the Lottie animation stays visible.
    var gradientOpacity: Double = 0.7

    var body: some View {
        ZStack {
            LottieView.background(LottieManager.Background.aurora)
                .ignoresSafeArea()

            (customGradient ?? ColorManager.gradientForPage(gradientPageIndex))
                .opacity(gradientOpacity)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    AnimatedScreenBackground(gradientPageIndex: 0)
        .ignoresSafeArea()
}
