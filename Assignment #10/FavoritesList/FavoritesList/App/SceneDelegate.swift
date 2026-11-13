import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // The window and the initial view controller come from Main.storyboard.
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard scene is UIWindowScene else { return }
    }
}
