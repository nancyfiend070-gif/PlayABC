import SwiftUI

/// Common, reusable animation helpers for soft, playful motion.
enum AnimationConfig {
    static let tapSpring = Animation.spring(response: 0.25, dampingFraction: 0.6)
    static let softBounce = Animation.interpolatingSpring(stiffness: 220, damping: 18)
    static let float = Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)
}

/// Adds a gentle tap bounce effect to any view.
struct TapBounceModifier: ViewModifier {
    let isPressed: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.93 : 1.0)
            .animation(AnimationConfig.tapSpring, value: isPressed)
    }
}

extension View {
    func tapBounce(_ isPressed: Bool) -> some View {
        modifier(TapBounceModifier(isPressed: isPressed))
    }
}

