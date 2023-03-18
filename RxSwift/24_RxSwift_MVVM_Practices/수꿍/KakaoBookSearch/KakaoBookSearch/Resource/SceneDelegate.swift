//
//  SceneDelegate.swift
//  KakaoBookSearch
//
//  Created by 전민수 on 2023/03/18.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            guard let windowScene = (scene as? UIWindowScene) else { return }

            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = MainViewController()
            window.makeKeyAndVisible()
            self.window = window
        }
}

