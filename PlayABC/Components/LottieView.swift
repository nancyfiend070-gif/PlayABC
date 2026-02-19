import SwiftUI

#if canImport(Lottie)
import Lottie
#endif

/// Wrapper for Lottie animations.
struct LottieView: UIViewRepresentable {
    let filename: String
    var isLooping: Bool = true
    var speed: CGFloat = 1.0
    var contentMode: UIView.ContentMode = .scaleAspectFit

    func makeCoordinator() -> Coordinator {
        Coordinator(filename: filename, isLooping: isLooping, speed: speed, contentMode: contentMode)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        #if canImport(Lottie)
        let animationView = context.coordinator.animationView
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        context.coordinator.loadAnimation()
        animationView.play()
        #endif
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        #if canImport(Lottie)
        let c = context.coordinator
        if c.filename != filename || c.isLooping != isLooping || c.speed != speed || c.contentMode != contentMode {
            c.filename = filename
            c.isLooping = isLooping
            c.speed = speed
            c.contentMode = contentMode
            c.loadAnimation()
            c.animationView.play()
        }
        #endif
    }

    #if canImport(Lottie)
    class Coordinator {
        let animationView = LottieAnimationView()
        var filename: String
        var isLooping: Bool
        var speed: CGFloat
        var contentMode: UIView.ContentMode

        init(filename: String, isLooping: Bool, speed: CGFloat, contentMode: UIView.ContentMode) {
            self.filename = filename
            self.isLooping = isLooping
            self.speed = speed
            self.contentMode = contentMode
        }

        func loadAnimation() {
            var path: String?
            if let p = Bundle.main.path(forResource: filename, ofType: "json", inDirectory: "Lottie") {
                path = p
            } else if let url = Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "Lottie") {
                path = url.path
            } else if let url = Bundle.main.url(forResource: filename, withExtension: "json") {
                path = url.path
            }
            if let path = path {
                animationView.animation = LottieAnimation.filepath(path)
            }
            animationView.loopMode = isLooping ? .loop : .playOnce
            animationView.animationSpeed = speed
            animationView.contentMode = contentMode
        }
    }
    #else
    class Coordinator {
        init(filename: String, isLooping: Bool, speed: CGFloat, contentMode: UIView.ContentMode) {}
    }
    #endif
}

/// Simplified SwiftUI wrapper that handles common cases.
extension LottieView {
    /// Creates a looping background animation.
    static func background(_ filename: String) -> LottieView {
        LottieView(filename: filename, isLooping: true, speed: 0.8, contentMode: .scaleAspectFill)
    }
    
    /// Creates a one-time celebration animation.
    static func celebration(_ filename: String) -> LottieView {
        LottieView(filename: filename, isLooping: false, speed: 1.0)
    }
    
    /// Creates a mascot character animation.
    static func mascot(_ filename: String) -> LottieView {
        LottieView(filename: filename, isLooping: true, speed: 1.0)
    }
}
