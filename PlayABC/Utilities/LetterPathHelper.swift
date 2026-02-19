//
//  LetterPathHelper.swift
//  PlayABC
//

import SwiftUI
import UIKit
import CoreText

/// Creates a SwiftUI Path for a single letter (for tracing, drawing, etc.).
enum LetterPathHelper {
    /// Returns a Path for the given character, scaled to fit in rect, or nil if unavailable.
    static func path(for character: Character, in rect: CGRect) -> Path? {
        let str = String(character).uppercased()
        guard str.first != nil else { return nil }
        let font = UIFont.systemFont(ofSize: 100, weight: .bold)
        let unichars = [UniChar](str.utf16)
        var glyphs = [CGGlyph](repeating: 0, count: unichars.count)
        guard CTFontGetGlyphsForCharacters(font, unichars, &glyphs, unichars.count),
              let cgPath = CTFontCreatePathForGlyph(font, glyphs[0], nil) else {
            return nil
        }
        let path = Path(cgPath)
        let bounds = path.boundingRect
        guard bounds.width > 0, bounds.height > 0 else { return nil }
        let scale = min(rect.width / bounds.width, rect.height / bounds.height) * 0.9
        let t = CGAffineTransform(translationX: -bounds.midX, y: -bounds.midY)
            .scaledBy(x: scale, y: -scale)
            .translatedBy(x: rect.midX, y: rect.midY)
        return path.applying(t)
    }

    /// Sample points along the path for hit-testing (e.g. every 2pt).
    static func samplePoints(path: Path, step: CGFloat = 3) -> [CGPoint] {
        var points: [CGPoint] = []
        let cgPath = path.cgPath
        cgPath.applyWithBlock { element in
            switch element.pointee.type {
            case .moveToPoint:
                points.append(element.pointee.points[0])
            case .addLineToPoint:
                points.append(element.pointee.points[0])
            case .addQuadCurveToPoint:
                points.append(element.pointee.points[0])
                points.append(element.pointee.points[1])
            case .addCurveToPoint:
                points.append(element.pointee.points[0])
                points.append(element.pointee.points[1])
                points.append(element.pointee.points[2])
            case .closeSubpath:
                break
            @unknown default:
                break
            }
        }
        if points.count < 2 { return points }
        var sampled: [CGPoint] = []
        for i in 0..<(points.count - 1) {
            let a = points[i]
            let b = points[i + 1]
            let dx = b.x - a.x
            let dy = b.y - a.y
            let dist = sqrt(dx * dx + dy * dy)
            let steps = max(1, Int(dist / step))
            for j in 0...steps {
                let t = CGFloat(j) / CGFloat(steps)
                sampled.append(CGPoint(x: a.x + dx * t, y: a.y + dy * t))
            }
        }
        return sampled
    }

    /// Minimum distance from point to path (approximate via sampled points).
    static func distance(from point: CGPoint, to path: Path, sampleStep: CGFloat = 4) -> CGFloat {
        let samples = samplePoints(path: path, step: sampleStep)
        guard !samples.isEmpty else { return .infinity }
        var minD: CGFloat = .infinity
        for s in samples {
            let dx = point.x - s.x
            let dy = point.y - s.y
            minD = min(minD, sqrt(dx * dx + dy * dy))
        }
        return minD
    }
}
