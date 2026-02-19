import Foundation
import AVFoundation

/// Handles all spoken feedback in the app using iOS built-in speech.
/// Uses a little-girl-style voice: female voice + high pitch so it sounds like a young girl, not an adult woman or man.
/// Access is serialized via the private queue; safe to use from main actor.
final class SpeechManager: NSObject, AVSpeechSynthesizerDelegate, @unchecked Sendable {
    /// Shared instance used across the app.
    static let shared = SpeechManager()

    /// Underlying speech synthesizer. All use is on the private queue.
    private let synthesizer = AVSpeechSynthesizer()

    /// Serial queue so speech actions do not fight with each other.
    private let queue = DispatchQueue(label: "SpeechManager.queue")

    /// Completion called when kid-voice phrase finishes (e.g. letter learning).
    private var kidSongCompletion: (() -> Void)?

    /// Cached little-girl-style voice: prefer female en-US (with high pitch sounds like a young girl).
    private static let kidVoice: AVSpeechSynthesisVoice? = {
        let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("en-US") }
        if #available(iOS 16.0, *) {
            if let enhanced = voices.first(where: { $0.quality == .enhanced && $0.gender == .female }) { return enhanced }
            if let premium = voices.first(where: { $0.quality == .premium && $0.gender == .female }) { return premium }
            if let enhanced = voices.first(where: { $0.quality == .enhanced }) { return enhanced }
            if let premium = voices.first(where: { $0.quality == .premium }) { return premium }
        }
        if #available(iOS 13.0, *) {
            if let female = voices.first(where: { $0.gender == .female }) { return female }
        }
        return voices.first ?? AVSpeechSynthesisVoice(language: "en-US")
    }()

    /// Private initializer to configure the speech engine once.
    private override init() {
        super.init()
        synthesizer.delegate = self
        ensureAudioSessionForSpeech()
    }

    /// Ensures the audio session is active so TTS is heard. Does not change category (SoundManager sets .ambient).
    private func ensureAudioSessionForSpeech() {
        queue.async {
            do {
                try AVAudioSession.sharedInstance().setActive(true, options: [])
            } catch {
                #if DEBUG
                print("SpeechManager: setActive error \(error)")
                #endif
            }
        }
    }

    /// Speaks only the letter, for example "A" — in kid voice (higher pitch).
    func speakLetter(_ letter: String) {
        let text = letter.uppercased()
        speak(text: text, rate: 0.45, pitch: 1.28)
    }

    /// Speaks only the word, for example "Apple" — in kid voice.
    func speakWord(_ word: String) {
        speak(text: word, rate: 0.45, pitch: 1.22)
    }

    /// Speaks any short sentence, for example "A for Apple" — in kid voice.
    func speakSentence(_ sentence: String) {
        speak(text: sentence, rate: 0.42, pitch: 1.22)
    }

    /// Speaks only "E for Egg" (one phrase; no separate letter or word) — in kid voice.
    func speakLetterSequence(letter: String, word: String) {
        let sentence = "\(letter.uppercased()) for \(word)"
        speak(text: sentence, rate: 0.42, pitch: 1.22)
    }

    /// Cute kid reactions for mascot taps — playful and varied so kids want to tap again.
    private static let kidReactionPhrases = ["Wow", "Yay", "Ooh", "Whoa", "Oh", "Huh", "Oops", "Oop", "Ha", "Whee"]

    /// Short, positive reward phrases when the child gets something right.
    private static let rewardPhrases = ["Yes!", "Good!", "Nice!", "Got it!", "Yay!", "Super!", "You did it!", "Nice one!"]

    /// Speaks "Great job!" in a kid voice (e.g. after tracing or completing a challenge).
    func speakGreatJob() {
        speak(text: "Great job!", rate: 0.4, pitch: 1.38)
    }

    /// Speaks the phonics sound for a letter (e.g. "buh" for B) in kid voice. Used in the Letter Sound game.
    func speakPhonicsSound(letter: String) {
        let sound = PhonicsSound.sound(for: letter)
        speak(text: sound, rate: 0.35, pitch: 1.32)
    }

    /// Speaks "Oops!" in a soft kid voice (e.g. wrong balloon tap).
    func speakOops() {
        speak(text: "Oops!", rate: 0.38, pitch: 1.32)
    }

    /// Speaks a gentle reward phrase in kid voice (e.g. after a correct answer).
    func speakRewardPhrase() {
        guard let phrase = Self.rewardPhrases.randomElement() else { return }
        queue.async { [weak self] in
            guard let self else { return }
            _ = try? AVAudioSession.sharedInstance().setActive(true, options: [])
            self._stopNow()
            let utterance = self.makeUtterance(text: phrase, rate: 0.4, pitch: 1.38)
            self.synthesizer.speak(utterance)
        }
    }

    /// Plays a random cute kid-voice reaction (e.g. on tiger/fish/doggie tap).
    func speakRandomKidReaction() {
        guard let phrase = Self.kidReactionPhrases.randomElement() else { return }
        queue.async { [weak self] in
            guard let self else { return }
            _ = try? AVAudioSession.sharedInstance().setActive(true, options: [])
            self._stopNow()
            self.kidSongCompletion = nil
            let utterance = self.makeUtterance(text: phrase, rate: 0.38, pitch: 1.48)
            self.synthesizer.speak(utterance)
        }
    }

    /// Speaks "A for Apple" style in a cute little-kid voice (slower, higher pitch). Calls completion when done.
    func speakLetterSequenceKidVoice(letter: String, word: String, completion: @escaping () -> Void) {
        queue.async { [weak self] in
            guard let self else { return }
            _ = try? AVAudioSession.sharedInstance().setActive(true, options: [])
            self._stopNow()
            self.kidSongCompletion = completion
            let sentence = "\(letter.uppercased()) for \(word)"
            let utterance = self.makeUtterance(text: sentence, rate: 0.36, pitch: 1.5)
            self.synthesizer.speak(utterance)
        }
    }

    /// Stops any current speech immediately so the next one can start.
    func stopSpeaking() {
        queue.async { [weak self] in
            self?._stopNow()
        }
    }

    /// Stops current speech synchronously. Must only be called from the serial queue.
    private func _stopNow() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    /// Creates a configured utterance with kid-style voice (higher pitch, preferred enhanced en-US when available).
    private func makeUtterance(text: String, rate: Float, pitch: Float) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = Self.kidVoice ?? AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.volume = 1.0
        return utterance
    }

    /// Simple helper used by the public methods to speak a single phrase.
    private func speak(text: String, rate: Float, pitch: Float) {
        queue.async { [weak self] in
            guard let self else { return }
            _ = try? AVAudioSession.sharedInstance().setActive(true, options: [])
            self._stopNow()
            let utterance = self.makeUtterance(text: text, rate: rate, pitch: pitch)
            self.synthesizer.speak(utterance)
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let completion = kidSongCompletion
        kidSongCompletion = nil
        if let completion = completion {
            DispatchQueue.main.async { completion() }
        }
    }
}

