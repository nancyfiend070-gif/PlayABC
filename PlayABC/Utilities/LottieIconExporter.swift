//
//  LottieIconExporter.swift
//  PlayABC
//

import UIKit

#if canImport(Lottie)
import Lottie
#endif

/// Exports a single frame from the Cute Tiger Lottie as a 1024×1024 PNG so the app icon uses the exact same character.
enum LottieIconExporter {

    static let iconSize: CGFloat = 1024
    static let tigerFilename = "Cute Tiger"
    /// Frame to export (0–1). 0.25 = early wave, 0.5 = mid.
    static let exportFrame: AnimationProgressTime = 0.35

    /// Renders the Cute Tiger Lottie at one frame to a 1024×1024 image. Call from main thread.
    /// Saves to Documents as "CuteTigerIcon.png" for copying into AppIcon.appiconset.
    static func exportCuteTigerIconIfNeeded() {
        #if canImport(Lottie)
        guard let image = renderCuteTigerFrame() else { return }
        saveToDocuments(image, filename: "CuteTigerIcon.png")
        #endif
    }

    #if canImport(Lottie)
    static func renderCuteTigerFrame() -> UIImage? {
        let path: String? = {
            if let p = Bundle.main.path(forResource: tigerFilename, ofType: "json", inDirectory: "Lottie") { return p }
            if let url = Bundle.main.url(forResource: tigerFilename, withExtension: "json", subdirectory: "Lottie") { return url.path }
            if let url = Bundle.main.url(forResource: tigerFilename, withExtension: "json") { return url.path }
            return nil
        }()
        guard let path = path,
              let animation = LottieAnimation.filepath(path) else { return nil }

        let view = LottieAnimationView(animation: animation)
        view.frame = CGRect(origin: .zero, size: CGSize(width: iconSize, height: iconSize))
        view.contentMode = .scaleAspectFit
        view.currentProgress = exportFrame
        view.layoutIfNeeded()

        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        let image = renderer.image { ctx in
            view.layer.render(in: ctx.cgContext)
        }
        return image
    }

    static func saveToDocuments(_ image: UIImage, filename: String) {
        guard let data = image.pngData() else { return }
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(filename)
        try? data.write(to: url)
        print("[LottieIconExporter] Saved: \(url.path)")
    }
    #endif
}
