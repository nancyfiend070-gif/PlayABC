import Foundation

/// Centralized names for Lottie animation files.
enum LottieManager {
    /// Background animations (looping, subtle).
    enum Background {
        static let aurora = "Aurora Gradient Blobs Background"
    }
    
    /// Character/mascot animations (looping, friendly).
    enum Mascot {
        static let cuteTiger = "Cute Tiger"
        static let runningCat = "Running Cat"
        static let tigerInBox = "tiger in box"
        static let fishWithBowl = "fish with bowl"
        static let cuteDoggie = "Cute Doggie"
    }

    /// Celebration/reward animations (one-time, exciting).
    enum Celebration {
        static let confetti = "Confetti"
    }
    
    /// Loading/transition animations.
    enum Loading {
        static let glowingFish = "Glowing Fish Loader"
    }
    
    /// Welcome screen animation.
    enum Welcome {
        static let welcome = "Welcome"
    }
}
