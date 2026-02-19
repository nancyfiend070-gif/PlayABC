# Lottie Animation Setup

## Step 1: Add Lottie Package

1. Open Xcode
2. Go to **File > Add Package Dependencies...**
3. Enter this URL: `https://github.com/airbnb/lottie-ios`
4. Select version **4.0.0** or later
5. Click **Add Package**
6. Make sure **PlayABC** target is selected
7. Click **Add Package**

## Step 2: Enable Lottie in Code

After adding the package, edit `Components/LottieView.swift`:

1. Add `import Lottie` at the top (after `import SwiftUI`)
2. Uncomment the code block inside `makeUIView` method (remove the `/*` and `*/` comments)
3. Change `isLooping` parameter to use `LottieLoopMode`:
   - Replace `isLooping: Bool` with `loopMode: LottieLoopMode = .loop`
   - Update `.loop` to `loopMode` in the animation view setup

## Available Lottie Files

All animations are in `PlayABC/Lottie/` folder:

- **Backgrounds:**
  - `Aurora Gradient Blobs Background.json` - Used on home and letter screens

- **Mascots:**
  - `Cute Tiger.json` - Used on home screen
  - `Running Cat.json` - Alternative mascot
  - `tiger in box.json` - Alternative mascot
  - `fish with bowl.json` - Alternative mascot

- **Celebrations:**
  - `Confetti.json` - Shown when kids earn rewards (every 10 taps)

- **Loading:**
  - `Glowing Fish Loader.json` - For future loading states

- **Welcome:**
  - `Welcome.json` - For future welcome screen

## Current Integration

✅ **Home Screen:**
- Aurora background blobs (subtle, looping)
- Cute Tiger mascot (friendly, looping)

✅ **Letter Screen:**
- Aurora background blobs (subtle, looping)
- Confetti celebration (triggers every 10 taps)

## Next Steps

After enabling Lottie, the animations will automatically appear! The app is already wired to use them.
