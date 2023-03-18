//
//  AppDelegate.swift
//  KakaoBookSearch
//
//  Created by 전민수 on 2023/03/18.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            if #available(iOS 13.0, *) {
                return true
            }

            window = UIWindow()
            window?.rootViewController = MainViewController()
            window?.makeKeyAndVisible()

            return true
        }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

