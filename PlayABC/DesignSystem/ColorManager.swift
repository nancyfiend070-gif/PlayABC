import SwiftUI

/// Centralized color system using the professional kids-app palette.
/// Each letter has a unique color; each page uses a different gradient; accents ensure readability.
enum ColorManager {

    // MARK: - Letter colors (8 unique, mapped A–Z)

    static let letterCoral = Color(red: 1, green: 0.42, blue: 0.42)       // #FF6B6B
    static let letterSkyBlue = Color(red: 0.30, green: 0.59, blue: 1)       // #4D96FF
    static let letterSunshine = Color(red: 1, green: 0.85, blue: 0.24)     // #FFD93D
    static let letterMint = Color(red: 0.42, green: 0.80, blue: 0.47)       // #6BCB77
    static let letterViolet = Color(red: 0.73, green: 0.51, blue: 1)        // #B983FF
    static let letterPink = Color(red: 1, green: 0.56, blue: 0.67)          // #FF8FAB
    static let letterTeal = Color(red: 0.31, green: 0.80, blue: 0.77)       // #4ECDC4
    static let letterPeach = Color(red: 1, green: 0.64, blue: 0.32)         // #FFA351

    /// Fixed order: each letter index 0–25 maps to one of 8 colors (cycles).
    private static let letterColors: [Color] = [
        letterCoral, letterSkyBlue, letterSunshine, letterMint,
        letterViolet, letterPink, letterTeal, letterPeach
    ]

    /// Unique color for each letter by index (A=0 … Z=25). Ensures readability via contrast.
    static func letterColor(forLetterIndex index: Int) -> Color {
        letterColors[index % letterColors.count]
    }

    // MARK: - Gradients (5 pairs, one per page theme)

    private static let gradientMintCream: (Color, Color) = (
        Color(red: 0.63, green: 1, blue: 0.81),   // #A1FFCE
        Color(red: 0.98, green: 1, blue: 0.82)   // #FAFFD1
    )
    private static let gradientPinkBlue: (Color, Color) = (
        Color(red: 0.98, green: 0.76, blue: 0.92), // #FBC2EB
        Color(red: 0.65, green: 0.76, blue: 0.93)  // #A6C1EE
    )
    private static let gradientYellowGold: (Color, Color) = (
        Color(red: 0.99, green: 0.92, blue: 0.44), // #FDEB71
        Color(red: 0.97, green: 0.85, blue: 0)     // #F8D800
    )
    private static let gradientCyanBlue: (Color, Color) = (
        Color(red: 0.54, green: 0.97, blue: 1),   // #89F7FE
        Color(red: 0.4, green: 0.65, blue: 1)     // #66A6FF
    )
    private static let gradientPinkMint: (Color, Color) = (
        Color(red: 1, green: 0.87, blue: 0.91),   // #FFDEE9
        Color(red: 0.71, green: 1, blue: 0.99)    // #B5FFFC
    )

    private static let gradientPairs: [(Color, Color)] = [
        gradientMintCream, gradientPinkBlue, gradientYellowGold,
        gradientCyanBlue, gradientPinkMint
    ]

    // MARK: - Home screen cycling (original 5 + purple)

    private static let gradientPurple: (Color, Color) = (
        Color(red: 0.75, green: 0.55, blue: 0.95),   // soft purple
        Color(red: 0.88, green: 0.72, blue: 1.00)   // lavender
    )

    /// Gradient pairs for home screen cycling: original set plus purple.
    private static let homeCycleGradientPairs: [(Color, Color)] = [
        gradientMintCream, gradientPinkBlue, gradientYellowGold,
        gradientCyanBlue, gradientPinkMint,
        gradientPurple
    ]

    /// Gradient for home screen cycling; index cycles through original 5 + purple.
    static func gradientForHomeCycle(_ index: Int) -> LinearGradient {
        let pair = homeCycleGradientPairs[index % homeCycleGradientPairs.count]
        return LinearGradient(
            gradient: Gradient(colors: [pair.0, pair.1]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Number of gradients in the home cycle.
    static var homeCycleGradientCount: Int { homeCycleGradientPairs.count }

    /// Different gradient per page (deterministic: pageIndex % 5). No single-color screens.
    static func gradientForPage(_ pageIndex: Int) -> LinearGradient {
        let pair = gradientPairs[pageIndex % gradientPairs.count]
        return LinearGradient(
            gradient: Gradient(colors: [pair.0, pair.1]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Home screen uses first gradient so it feels distinct and consistent.
    static func homeGradient() -> LinearGradient {
        gradientForPage(0)
    }

    /// Light blue app-logo gradient (soft blue, grey-blue, pale) for home screen.
    static func homeLogoGradient() -> LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.75, green: 0.88, blue: 0.98),
                Color(red: 0.65, green: 0.82, blue: 0.95),
                Color(red: 0.55, green: 0.75, blue: 0.92),
                Color(red: 0.72, green: 0.82, blue: 0.96)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Accents (contrast & readability)

    static let accentGold = Color(red: 1, green: 0.84, blue: 0)            // #FFD700
    static let accentLime = Color(red: 0.49, green: 0.99, blue: 0)           // #7CFC00
    static let accentWhite = Color.white                                     // #FFFFFF
    /// Black 20% opacity for shadows / overlays.
    static let overlayDark = Color.black.opacity(0.125)                       // #00000020

    /// Text color on light/white backgrounds – dark for strong contrast and readability.
    private static let textOnLight = Color(red: 0.12, green: 0.10, blue: 0.28)

    /// Slightly lighter dark for secondary text on white (e.g. subtitles).
    static let textSecondaryOnLight = Color(red: 0.35, green: 0.32, blue: 0.45)

    /// Title color on gradient backgrounds (home, letter screen) – high contrast.
    static func titleOnGradient() -> Color { accentWhite }

    /// Text color for letter and "A for Apple" on white card – dark for contrast.
    static func textOnCard() -> Color { textOnLight }

    /// Text color for letter inside a colored button (dark for contrast on bright pastels).
    static func textOnLetterButton() -> Color { textOnLight }

    // MARK: - Theme (per-screen: gradient + letter color + accent)

    struct Theme {
        let backgroundGradient: LinearGradient
        let primary: Color
        let secondary: Color
        let accent: Color
    }

    /// Home screen theme: one gradient, accent for title.
    static func homeTheme() -> Theme {
        Theme(
            backgroundGradient: homeGradient(),
            primary: gradientMintCream.0,
            secondary: gradientMintCream.1,
            accent: textOnLight
        )
    }

    /// Letter page theme: unique gradient per page + that letter’s color + readable accent.
    static func themeForPage(_ pageIndex: Int) -> Theme {
        let pair = gradientPairs[pageIndex % gradientPairs.count]
        let letter = letterColor(forLetterIndex: pageIndex)
        return Theme(
            backgroundGradient: LinearGradient(
                gradient: Gradient(colors: [pair.0, pair.1]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            primary: letter,
            secondary: pair.1,
            accent: textOnCard()
        )
    }

    /// Button color for home grid: unique per letter index.
    static func buttonColor(forLetterIndex index: Int) -> Color {
        letterColor(forLetterIndex: index)
    }
}
