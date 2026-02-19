import Foundation

/// Describes the type of reward that should be shown.
enum RewardEvent {
    case none
    case star
    case celebration
}

/// Tracks simple reward milestones based on how many times
/// kids tap on the main learning image.
final class RewardManager {
    /// Shared instance used across the app.
    static let shared = RewardManager()

    /// Counts how many times the image has been tapped.
    private var tapCount: Int = 0

    private init() {}

    /// Registers a new tap and returns which reward, if any, should be shown.
    func registerTap() -> RewardEvent {
        tapCount += 1

        if tapCount % 10 == 0 {
            return .celebration
        } else if tapCount % 5 == 0 {
            return .star
        } else {
            return .none
        }
    }
}

