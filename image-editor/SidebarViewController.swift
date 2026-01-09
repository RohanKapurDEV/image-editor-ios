import UIKit

class SidebarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Creations"
        view.backgroundColor = .systemBackground

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .font: UIFont.systemFont(
                ofSize: 37,
                weight: .bold,
                width: .expanded
            )
        ]
        navigationItem.largeTitleDisplayMode = .always

        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeSidebar)
        )
        navigationItem.rightBarButtonItem = closeButton

        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(openSettings)
        )
        navigationItem.leftBarButtonItem = settingsButton

        let swipeGesture = UISwipeGestureRecognizer(
            target: self,
            action: #selector(closeSidebar)
        )
        swipeGesture.direction = .left
        view.addGestureRecognizer(swipeGesture)
    }

    @objc private func closeSidebar() {
        guard let splitVC = splitViewController else { return }
        splitVC.show(.secondary)
    }

    @objc private func openSettings() {
        let settingsVC = SettingsViewController()
        let navController = UINavigationController(
            rootViewController: settingsVC
        )
        navController.modalPresentationStyle = .pageSheet

        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }

        present(navController, animated: true)
    }
}
