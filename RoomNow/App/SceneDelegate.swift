//
//  SceneDelegate.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 21.03.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }

        configureGlobalNavigationBarAppearance()

        AuthManager.shared.observeAuthState { user in
            DispatchQueue.main.async {
                let window = UIWindow(windowScene: windowScene)
                window.overrideUserInterfaceStyle = .dark

                let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")

                if !hasSeenOnboarding {
                    window.rootViewController = OnboardingContainerVC()
                } else {
                    if let user = user {
                        AuthManager.shared.fetchUserData { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let appUser):
                                    print("Fetched AppUser:", appUser.role.rawValue)
                                    if appUser.role == .admin {
                                        window.rootViewController = AdminTabBarVC()
                                    } else {
                                        window.rootViewController = UserTabBarVC()
                                    }

                                case .failure(let error):
                                    print("Failed to fetch AppUser:", error)
                                    window.rootViewController = UserTabBarVC()
                                }

                                window.makeKeyAndVisible()
                                self.window = window
                            }
                        }
                    } else {
                        print("User is not logged in")
                        let tabBarVC = UserTabBarVC()
                        tabBarVC.reloadTabsAfterLogout()
                        window.rootViewController = tabBarVC
                        window.makeKeyAndVisible()
                        self.window = window
                    }
                }


                window.makeKeyAndVisible()
                self.window = window
            }
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
    }
    
    func configureGlobalNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .appSecondaryBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.appPrimaryText]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        
        //self.navigationBar.tintColor = .appPrimaryText
        UIBarButtonItem.appearance().tintColor = .appAccent
    }


}

