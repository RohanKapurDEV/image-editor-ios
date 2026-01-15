import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    private weak var splitViewController: UISplitViewController?
    private var screenWidth: CGFloat = 0

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        screenWidth = windowScene.screen.bounds.width

        let splitVC = UISplitViewController(style: .doubleColumn)
        splitVC.preferredDisplayMode = .oneOverSecondary
        splitVC.preferredSplitBehavior = .overlay
        splitVC.presentsWithGesture = true
        splitVC.delegate = self
        self.splitViewController = splitVC

        let creationsVC = CreationsViewController()
        let creationsNav = UINavigationController(rootViewController: creationsVC)

        let mainVC = MainViewController()
        let mainNav = UINavigationController(rootViewController: mainVC)

        splitVC.setViewController(creationsNav, for: .primary)
        splitVC.setViewController(mainNav, for: .secondary)

        splitVC.preferredPrimaryColumnWidthFraction = 1.0
        splitVC.maximumPrimaryColumnWidth = screenWidth

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        splitVC.view.addGestureRecognizer(panGesture)

        feedbackGenerator.prepare()

        window?.rootViewController = splitVC
        window?.makeKeyAndVisible()
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
    }
}

extension SceneDelegate: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension SceneDelegate: UISplitViewControllerDelegate {

    func splitViewController(_ svc: UISplitViewController, willShow column: UISplitViewController.Column) {
        if column == .primary {
            feedbackGenerator.impactOccurred()
            feedbackGenerator.prepare()
        }
    }

    func splitViewController(_ svc: UISplitViewController, willHide column: UISplitViewController.Column) {
    }
}
