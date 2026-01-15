import UIKit
import ImageIO

class MainViewController: UIViewController {

    private let imageView = UIImageView()
    private let captionLabel = UILabel()
    private let promptBox = PromptBoxView()
    private var promptBoxBottomConstraint: NSLayoutConstraint!
    private var hasPlayedStartupAnimation = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupImageView()
        setupPromptBox()
        setupKeyboardObservers()
        setupTapToDismiss()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasPlayedStartupAnimation {
            hasPlayedStartupAnimation = true
            promptBox.playRainbowAnimation()
        }
    }

    private func setupImageView() {
        if let asset = NSDataAsset(name: "horsegif"),
           let animatedImage = createAnimatedImage(from: asset.data) {
            imageView.image = animatedImage
        }
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        captionLabel.text = "The first moving image ever made"
        captionLabel.font = .systemFont(ofSize: 12, weight: .regular)
        captionLabel.textColor = .secondaryLabel
        captionLabel.textAlignment = .center
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(captionLabel)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            imageView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.5),

            captionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            captionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupPromptBox() {
        promptBox.delegate = self
        promptBox.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(promptBox)

        // Pin to bottom of view (not safe area) to fill whitespace
        promptBoxBottomConstraint = promptBox.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        NSLayoutConstraint.activate([
            promptBox.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            promptBox.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            promptBoxBottomConstraint
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Set bottom padding to account for safe area
        promptBox.bottomPadding = view.safeAreaInsets.bottom
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func setupTapToDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        promptBoxBottomConstraint.constant = -keyboardHeight

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        promptBoxBottomConstraint.constant = 0

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func dismissKeyboard() {
        promptBox.dismissKeyboard()
    }

    private func createAnimatedImage(from data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }

        let count = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        var totalDuration: Double = 0

        for i in 0..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else { continue }

            // Get frame duration
            var frameDuration: Double = 0.1
            if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
               let webpProps = properties["{WebP}"] as? [String: Any],
               let delay = webpProps["DelayTime"] as? Double {
                frameDuration = delay
            } else if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
                      let gifProps = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any],
                      let delay = gifProps[kCGImagePropertyGIFDelayTime as String] as? Double {
                frameDuration = delay
            }

            totalDuration += frameDuration
            images.append(UIImage(cgImage: cgImage))
        }

        guard !images.isEmpty else { return nil }

        return UIImage.animatedImage(with: images, duration: totalDuration)
    }
}

extension MainViewController: PromptBoxViewDelegate {
    func promptBoxDidTapImagePicker() {
        // TODO: Implement image picker
    }

    func promptBoxDidTapModelSelection() {
        // TODO: Implement model selection
    }

    func promptBoxDidTapSend(text: String) {
        // TODO: Implement send
        dismissKeyboard()
    }
}
