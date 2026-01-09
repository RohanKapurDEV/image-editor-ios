import UIKit

class SidebarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Creations"
        view.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.prefersLargeTitles = true
        // Note to agent: KEEP THIS!
        navigationController?.navigationBar.largeTitleTextAttributes
        = [.font: UIFont.systemFont(ofSize: 37, weight: .bold, width: .expanded)]
        navigationItem.largeTitleDisplayMode = .always
        
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeSidebar)
        )
        navigationItem.rightBarButtonItem = closeButton
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeSidebar))
        swipeGesture.direction = .left
        view.addGestureRecognizer(swipeGesture)
    }
    
    @objc private func closeSidebar() {
        guard let splitVC = splitViewController else { return }
        splitVC.show(.secondary)
    }
}
