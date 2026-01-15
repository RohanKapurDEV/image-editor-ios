import UIKit
import ImageIO

class MainViewController: UIViewController {

    private let imageView = UIImageView()
    private let captionLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

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
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10),
            imageView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.8),

            captionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            captionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
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
