import Foundation

/// Describes the learning content for a single alphabet letter.
struct LetterLearningItem {
    /// The letter this item belongs to (for example: "A").
    let letter: String

    /// The word that goes with the letter (for example: "Apple").
    let word: String

    /// A simple emoji used as a friendly placeholder image.
    /// Later, this can be replaced with real image asset names.
    let emoji: String
}

/// Provides static learning data for each letter.
enum LetterLearningData {
    /// Returns the learning item for a given letter, if it exists.
    static func item(for letter: String) -> LetterLearningItem? {
        let key = letter.uppercased()
        return items[key]
    }

    /// All letters A–Z as learning items, for games and lists.
    static var allItems: [LetterLearningItem] {
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ".compactMap { item(for: String($0)) }
    }

    /// Returns a random subset of items (e.g. for multiple-choice options).
    static func randomItems(count: Int, excludingLetter: String? = nil) -> [LetterLearningItem] {
        var pool = allItems
        if let ex = excludingLetter?.uppercased(), let idx = pool.firstIndex(where: { $0.letter == ex }) {
            pool.remove(at: idx)
        }
        return Array(pool.shuffled().prefix(count))
    }

    /// A small dictionary of sample content for A–Z.
    /// This can grow over time into a richer dataset.
    private static let items: [String: LetterLearningItem] = [
        "A": LetterLearningItem(letter: "A", word: "Apple", emoji: "🍎"),
        "B": LetterLearningItem(letter: "B", word: "Ball", emoji: "⚽️"),
        "C": LetterLearningItem(letter: "C", word: "Cat", emoji: "🐱"),
        "D": LetterLearningItem(letter: "D", word: "Dog", emoji: "🐶"),
        "E": LetterLearningItem(letter: "E", word: "Elephant", emoji: "🐘"),
        "F": LetterLearningItem(letter: "F", word: "Fish", emoji: "🐟"),
        "G": LetterLearningItem(letter: "G", word: "Grapes", emoji: "🍇"),
        "H": LetterLearningItem(letter: "H", word: "Hat", emoji: "🎩"),
        "I": LetterLearningItem(letter: "I", word: "Ice cream", emoji: "🍦"),
        "J": LetterLearningItem(letter: "J", word: "Juice", emoji: "🧃"),
        "K": LetterLearningItem(letter: "K", word: "Kite", emoji: "🪁"),
        "L": LetterLearningItem(letter: "L", word: "Lion", emoji: "🦁"),
        "M": LetterLearningItem(letter: "M", word: "Moon", emoji: "🌙"),
        "N": LetterLearningItem(letter: "N", word: "Nest", emoji: "🪺"),
        "O": LetterLearningItem(letter: "O", word: "Orange", emoji: "🍊"),
        "P": LetterLearningItem(letter: "P", word: "Panda", emoji: "🐼"),
        "Q": LetterLearningItem(letter: "Q", word: "Queen", emoji: "👑"),
        "R": LetterLearningItem(letter: "R", word: "Rainbow", emoji: "🌈"),
        "S": LetterLearningItem(letter: "S", word: "Sun", emoji: "☀️"),
        "T": LetterLearningItem(letter: "T", word: "Turtle", emoji: "🐢"),
        "U": LetterLearningItem(letter: "U", word: "Umbrella", emoji: "☂️"),
        "V": LetterLearningItem(letter: "V", word: "Violin", emoji: "🎻"),
        "W": LetterLearningItem(letter: "W", word: "Whale", emoji: "🐳"),
        "X": LetterLearningItem(letter: "X", word: "Xylophone", emoji: "🎼"),
        "Y": LetterLearningItem(letter: "Y", word: "Yogurt", emoji: "🥛"),
        "Z": LetterLearningItem(letter: "Z", word: "Zebra", emoji: "🦓")
    ]
}

