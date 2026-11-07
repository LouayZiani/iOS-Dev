import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // The window and the first screen (the UINavigationController) are created
    // from Main.storyboard because Info.plist points to it. Nothing to do here.
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard (scene as? UIWindowScene) != nil else { return }
    }
}
