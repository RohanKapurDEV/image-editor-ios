import UIKit

protocol PromptBoxViewDelegate: AnyObject {
    func promptBoxDidTapImagePicker()
    func promptBoxDidTapModelSelection()
    func promptBoxDidTapSend(text: String)
}

class PromptBoxView: UIView {

    weak var delegate: PromptBoxViewDelegate?

    private let blurView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .systemMaterial)
        let view = UIVisualEffectView(effect: blur)
        return view
    }()

    private let rainbowGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        // Lighter, more pastel rainbow colors
        layer.colors = [
            UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0).cgColor,   // Light red/pink
            UIColor(red: 1.0, green: 0.8, blue: 0.5, alpha: 1.0).cgColor,   // Light orange
            UIColor(red: 1.0, green: 1.0, blue: 0.6, alpha: 1.0).cgColor,   // Light yellow
            UIColor(red: 0.6, green: 1.0, blue: 0.7, alpha: 1.0).cgColor,   // Light green
            UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 1.0).cgColor,   // Light blue
            UIColor(red: 0.8, green: 0.6, blue: 1.0, alpha: 1.0).cgColor,   // Light purple
            UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0).cgColor    // Light red/pink
        ]
        layer.startPoint = CGPoint(x: -1.0, y: 0.5)
        layer.endPoint = CGPoint(x: 0.0, y: 0.5)
        layer.opacity = 0
        return layer
    }()

    private let rainbowMaskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 3
        return layer
    }()

    // Glow layer - renders the path with soft shadow for glow effect
    private let glowLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.withAlphaComponent(0.4).cgColor
        layer.lineWidth = 2
        layer.shadowColor = UIColor.white.cgColor
        layer.shadowOffset = .zero
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.8
        layer.opacity = 0
        return layer
    }()


    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter prompt..."
        tf.borderStyle = .none
        tf.font = .systemFont(ofSize: 16)
        tf.returnKeyType = .send
        return tf
    }()

    private let imagePickerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "photo.on.rectangle"), for: .normal)
        btn.tintColor = .label
        return btn
    }()

    private let modelSelectionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "cpu"), for: .normal)
        btn.tintColor = .label
        return btn
    }()

    private let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        btn.tintColor = .systemBlue
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        btn.setPreferredSymbolConfiguration(config, forImageIn: .normal)
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private let baseBottomPadding: CGFloat = 27

    var bottomPadding: CGFloat = 0 {
        didSet {
            bottomPaddingConstraint?.constant = -(baseBottomPadding + bottomPadding)
        }
    }

    private var bottomPaddingConstraint: NSLayoutConstraint?

    private func setup() {
        // Drop shadow on the view itself
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: -4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.15

        // Add blur background with rounded top corners
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 20
        blurView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        blurView.clipsToBounds = true
        addSubview(blurView)

        // Add glow layer behind (for soft light effect)
        layer.addSublayer(glowLayer)

        // Add rainbow gradient layer on top with shape mask for rounded corners
        rainbowGradientLayer.mask = rainbowMaskLayer
        layer.addSublayer(rainbowGradientLayer)

        // Content view inside blur
        let contentView = blurView.contentView

        // Text field row
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        contentView.addSubview(textField)

        // Button row
        let leftButtonStack = UIStackView(arrangedSubviews: [imagePickerButton, modelSelectionButton])
        leftButtonStack.axis = .horizontal
        leftButtonStack.spacing = 16
        leftButtonStack.translatesAutoresizingMaskIntoConstraints = false

        sendButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(leftButtonStack)
        contentView.addSubview(sendButton)

        bottomPaddingConstraint = leftButtonStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -baseBottomPadding)

        // Layout
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            leftButtonStack.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 12),
            leftButtonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bottomPaddingConstraint!,

            sendButton.centerYAnchor.constraint(equalTo: leftButtonStack.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])

        // Button actions
        imagePickerButton.addTarget(self, action: #selector(imagePickerTapped), for: .touchUpInside)
        modelSelectionButton.addTarget(self, action: #selector(modelSelectionTapped), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

        // Pan gesture for drag to focus/defocus
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)

        switch gesture.state {
        case .ended:
            // Dragged up with enough velocity or distance -> focus
            if translation.y < -30 || velocity.y < -200 {
                textField.becomeFirstResponder()
            }
            // Dragged down with enough velocity or distance -> defocus
            else if translation.y > 30 || velocity.y > 200 {
                textField.resignFirstResponder()
            }
        default:
            break
        }
    }

    @objc private func imagePickerTapped() {
        delegate?.promptBoxDidTapImagePicker()
    }

    @objc private func modelSelectionTapped() {
        delegate?.promptBoxDidTapModelSelection()
    }

    @objc private func sendTapped() {
        delegate?.promptBoxDidTapSend(text: textField.text ?? "")
    }

    func dismissKeyboard() {
        textField.resignFirstResponder()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let cornerRadius: CGFloat = 20
        let lineWidth: CGFloat = 2
        let inset = lineWidth / 2

        // Gradient layer covers the top area where the border will be
        rainbowGradientLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: cornerRadius + lineWidth)

        // Create path that follows the top rounded border
        let path = UIBezierPath()
        path.move(to: CGPoint(x: inset, y: cornerRadius + inset))
        path.addArc(withCenter: CGPoint(x: cornerRadius + inset, y: cornerRadius + inset),
                    radius: cornerRadius,
                    startAngle: .pi,
                    endAngle: .pi * 1.5,
                    clockwise: true)
        path.addLine(to: CGPoint(x: bounds.width - cornerRadius - inset, y: inset))
        path.addArc(withCenter: CGPoint(x: bounds.width - cornerRadius - inset, y: cornerRadius + inset),
                    radius: cornerRadius,
                    startAngle: .pi * 1.5,
                    endAngle: 0,
                    clockwise: true)
        rainbowMaskLayer.path = path.cgPath
        rainbowMaskLayer.lineWidth = lineWidth
        glowLayer.path = path.cgPath
    }

    func playRainbowAnimation() {
        // Make visible for animation
        rainbowGradientLayer.opacity = 1
        glowLayer.opacity = 1

        // Animate startPoint from -1 to 1
        let startPointAnim = CABasicAnimation(keyPath: "startPoint")
        startPointAnim.fromValue = CGPoint(x: -1.0, y: 0.5)
        startPointAnim.toValue = CGPoint(x: 1.0, y: 0.5)

        // Animate endPoint from 0 to 2
        let endPointAnim = CABasicAnimation(keyPath: "endPoint")
        endPointAnim.fromValue = CGPoint(x: 0.0, y: 0.5)
        endPointAnim.toValue = CGPoint(x: 2.0, y: 0.5)

        // Fade out at the end
        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.fromValue = 1.0
        fadeAnim.toValue = 0.0
        fadeAnim.beginTime = 1.5
        fadeAnim.duration = 0.5
        fadeAnim.fillMode = .forwards

        // Main gradient animation group
        let group = CAAnimationGroup()
        group.animations = [startPointAnim, endPointAnim, fadeAnim]
        group.duration = 1
        group.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false

        // Glow fade animation
        let glowFadeAnim = CABasicAnimation(keyPath: "opacity")
        glowFadeAnim.fromValue = 1.0
        glowFadeAnim.toValue = 0.0
        glowFadeAnim.beginTime = 1.5
        glowFadeAnim.duration = 0.5
        glowFadeAnim.fillMode = .forwards
        glowFadeAnim.isRemovedOnCompletion = false

        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.rainbowGradientLayer.opacity = 0
            self?.glowLayer.opacity = 0
            self?.rainbowGradientLayer.removeAnimation(forKey: "rainbowSweep")
            self?.glowLayer.removeAnimation(forKey: "glowFade")
        }
        rainbowGradientLayer.add(group, forKey: "rainbowSweep")
        glowLayer.add(glowFadeAnim, forKey: "glowFade")
        CATransaction.commit()
    }
}

extension PromptBoxView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.promptBoxDidTapSend(text: textField.text ?? "")
        return true
    }
}
