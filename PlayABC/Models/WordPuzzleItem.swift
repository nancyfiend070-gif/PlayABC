import Foundation

/// One puzzle: word with a blank at blankIndex, e.g. "C_T" for CAT with blank at 1.
struct WordPuzzleItem {
    let word: String
    let blankIndex: Int

    var correctLetter: String {
        let idx = word.index(word.startIndex, offsetBy: blankIndex)
        return String(word[idx]).uppercased()
    }

    /// Display string with blank, e.g. "C _ T"
    var prompt: String {
        var chars = Array(word.uppercased())
        chars[blankIndex] = "_"
        return String(chars).replacingOccurrences(of: "_", with: " _ ")
    }

    static let puzzles: [WordPuzzleItem] = [
        WordPuzzleItem(word: "CAT", blankIndex: 1),
        WordPuzzleItem(word: "DOG", blankIndex: 1),
        WordPuzzleItem(word: "BAT", blankIndex: 0),
        WordPuzzleItem(word: "HAT", blankIndex: 0),
        WordPuzzleItem(word: "BED", blankIndex: 1),
        WordPuzzleItem(word: "SUN", blankIndex: 0),
        WordPuzzleItem(word: "RUN", blankIndex: 0),
        WordPuzzleItem(word: "BAG", blankIndex: 0),
        WordPuzzleItem(word: "LOG", blankIndex: 1),
        WordPuzzleItem(word: "FAN", blankIndex: 0),
    ]
}
