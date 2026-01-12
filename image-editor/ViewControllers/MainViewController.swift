import UIKit

class MainViewController: UIViewController {

    let blurView = UIVisualEffectView(effect: nil)
    private var blurAnimator: UIViewPropertyAnimator?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let blueSquare = UIView()
        blueSquare.backgroundColor = .systemBlue
        blueSquare.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blueSquare)

        NSLayoutConstraint.activate([
            blueSquare.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            blueSquare.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            blueSquare.widthAnchor.constraint(equalToConstant: 100),
            blueSquare.heightAnchor.constraint(equalToConstant: 100)
        ])

        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func setBlurFraction(_ fraction: CGFloat) {
        blurAnimator?.stopAnimation(true)
        blurAnimator?.finishAnimation(at: .current)

        blurView.effect = nil
        blurAnimator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [weak self] in
            self?.blurView.effect = UIBlurEffect(style: .systemMaterial)
        }
        blurAnimator?.fractionComplete = max(0, min(1, fraction))
        blurAnimator?.pausesOnCompletion = true
    }

    func finalizeBlur(to enabled: Bool, animated: Bool = true) {
        blurAnimator?.stopAnimation(true)
        blurAnimator?.finishAnimation(at: .current)
        blurAnimator = nil

        let targetEffect: UIBlurEffect? = enabled ? UIBlurEffect(style: .systemMaterial) : nil
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.blurView.effect = targetEffect
            }
        } else {
            blurView.effect = targetEffect
        }
    }
}
