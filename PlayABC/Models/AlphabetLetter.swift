import Foundation

/// Represents a single alphabet letter and its display properties.
/// Conforms to `Identifiable` and `Hashable` by letter so it can be used
/// safely in SwiftUI lists and navigation destinations.
struct AlphabetLetter: Identifiable, Hashable {
    /// Identifier for SwiftUI; same letter has same id.
    var id: String { character }

    /// The uppercase character for this letter (for example: "A").
    let character: String

    func hash(into hasher: inout Hasher) { hasher.combine(character) }
    static func == (lhs: AlphabetLetter, rhs: AlphabetLetter) -> Bool { lhs.character == rhs.character }
}

