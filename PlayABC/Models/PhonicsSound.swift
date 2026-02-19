import Foundation

/// Phonics sound for each letter (what to speak in the Letter Sound game).
enum PhonicsSound {
    private static let sounds: [String: String] = [
        "A": "ah", "B": "buh", "C": "kuh", "D": "duh", "E": "eh", "F": "fuh",
        "G": "guh", "H": "huh", "I": "ih", "J": "juh", "K": "kuh", "L": "luh",
        "M": "muh", "N": "nuh", "O": "oh", "P": "puh", "Q": "kwuh", "R": "ruh",
        "S": "sss", "T": "tuh", "U": "uh", "V": "vuh", "W": "wuh", "X": "ks",
        "Y": "yuh", "Z": "zzz"
    ]

    static func sound(for letter: String) -> String {
        sounds[letter.uppercased()] ?? letter
    }
}
