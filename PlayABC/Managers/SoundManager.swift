import Foundation
import AVFoundation

/// Handles all app sounds in one place so audio can stay
/// fast, simple, and easy to change later.
/// Expects .mp3 files in the app bundle: tap, reward_star, reward_celebration, background_music, coin_pickup (optional).
/// If files are missing, playback is skipped and `soundsAvailable` is false.
final class SoundManager {
    /// Shared instance used across the app.
    static let shared = SoundManager()

    /// True if at least one effect file was found. Use to hide sound UI or show "sounds unavailable" if desired.
    private(set) static var soundsAvailable: Bool = true

    /// Player for short sound effects such as taps and rewards.
    private var effectPlayer: AVAudioPlayer?

    /// Player for longer background music.
    private var backgroundPlayer: AVAudioPlayer?

    /// Queue used to keep audio work off the main thread.
    private let queue = DispatchQueue(label: "SoundManager.queue")

    /// Private initializer so the manager is a singleton.
    private init() {
        configureAudioSession()
        Self.soundsAvailable = Bundle.main.url(forResource: "tap", withExtension: "mp3") != nil
    }

    /// Configures the audio session so sounds play nicely with other apps.
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true, options: [])
        } catch {
            #if DEBUG
            print("SoundManager audio session error: \(error)")
            #endif
        }
    }

    /// Plays the short tap sound when a child taps on a button.
    func playTap() {
        playEffect(named: "tap")
    }

    /// Plays a gentle reward sound, for example when a star is earned.
    func playRewardStar() {
        playEffect(named: "reward_star")
    }

    /// Plays an excited celebration sound, for bigger achievements.
    func playRewardCelebration() {
        playEffect(named: "reward_celebration")
    }

    /// Plays a coin-pickup style sound when the kid gets a correct answer (e.g. in games). Feels like "collecting" a point. If coin_pickup.mp3 is missing, falls back to reward_star.
    func playCoinPickup() {
        let name = Bundle.main.url(forResource: "coin_pickup", withExtension: "mp3") != nil ? "coin_pickup" : "reward_star"
        playEffect(named: name)
    }

    /// Starts looping background music. Played a little slow (90% speed) for a calmer, kid-friendly feel.
    func startBackgroundMusic() {
        queue.async { [weak self] in
            guard let player = self?.makePlayer(fileName: "background_music") else { return }
            player.numberOfLoops = -1
            player.enableRate = true
            player.rate = 0.9  // Slightly slow so background music stays calm for kids
            self?.backgroundPlayer = player
            player.play()
        }
    }

    /// Stops any background music that is playing.
    func stopBackgroundMusic() {
        queue.async { [weak self] in
            self?.backgroundPlayer?.stop()
            self?.backgroundPlayer = nil
        }
    }

    /// Loads and plays a single short sound effect. No-op if file is missing.
    private func playEffect(named fileName: String) {
        queue.async { [weak self] in
            guard let self else { return }
            guard let player = self.makePlayer(fileName: fileName) else { return }
            self.effectPlayer = player
            player.play()
        }
    }

    /// Creates an audio player for a given file name in the main bundle.
    /// Expects `.mp3` files added to the app target (e.g. in a Sounds group). Returns nil if missing or invalid.
    private func makePlayer(fileName: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            return nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            return player
        } catch {
            #if DEBUG
            print("SoundManager player error for \(fileName): \(error)")
            #endif
            return nil
        }
    }
}

