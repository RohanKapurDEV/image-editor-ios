import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    private var wasPrimaryHidden = true

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let splitViewController = UISplitViewController(style: .doubleColumn)
        splitViewController.preferredDisplayMode = .oneOverSecondary
        splitViewController.preferredSplitBehavior = .overlay
        splitViewController.presentsWithGesture = true
        splitViewController.delegate = self
        
        let creationsVC = CreationsViewController()
        let creationsNav = UINavigationController(rootViewController: creationsVC)
        
        let mainVC = MainViewController()
        let mainNav = UINavigationController(rootViewController: mainVC)
        
        splitViewController.setViewController(creationsNav, for: .primary)
        splitViewController.setViewController(mainNav, for: .secondary)
        
        splitViewController.preferredPrimaryColumnWidthFraction = 1.0
        splitViewController.maximumPrimaryColumnWidth = windowScene.screen.bounds.width
        
        feedbackGenerator.prepare()
        
        window?.rootViewController = splitViewController
        window?.makeKeyAndVisible()
    }
}

extension SceneDelegate: UISplitViewControllerDelegate {
    
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        let isPrimaryVisible = (displayMode == .oneOverSecondary || displayMode == .oneBesideSecondary)
        
        if wasPrimaryHidden && isPrimaryVisible {
            feedbackGenerator.impactOccurred()
            feedbackGenerator.prepare()
        }
        
        wasPrimaryHidden = !isPrimaryVisible
    }
}
