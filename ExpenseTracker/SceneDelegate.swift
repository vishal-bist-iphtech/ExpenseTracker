//
//  SceneDelegate.swift
//  ExpenseTracker
//
//  Created by iPHTech 34 on 01/09/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }

        // Skip Landing when a previous login session is still valid.
        if AuthVM(repository: AppContainer.shared.userRepository).isLoggedIn {
            showMain(animated: false)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        AppContainer.shared.saveContext()
    }

    // MARK: - Auth routing

    /// Returns the SceneDelegate owning the given view controller's window.
    static func of(_ viewController: UIViewController) -> SceneDelegate? {
        viewController.view.window?.windowScene?.delegate as? SceneDelegate
    }

    /// Switches the window root to the main app (Dashboard navigation).
    /// Used after login/signup so the auth screens are discarded and
    /// the back button can never return to them.
    func showMain(animated: Bool = true) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let main = storyboard.instantiateViewController(withIdentifier: "MainNavigationController")
        setRoot(main, animated: animated)
    }

    /// Switches the window root back to Landing (logged-out entry point).
    /// Used after logout so the back button can never return to the app.
    func showLanding(animated: Bool = true) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let landing = storyboard.instantiateViewController(withIdentifier: "LandingViewController")
        setRoot(landing, animated: animated)
    }

    private func setRoot(_ viewController: UIViewController, animated: Bool) {
        guard let window = window else { return }
        guard window.rootViewController !== viewController else { return }
        if animated {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
                window.rootViewController = viewController
            }
        } else {
            window.rootViewController = viewController
        }
        window.makeKeyAndVisible()
    }


}

