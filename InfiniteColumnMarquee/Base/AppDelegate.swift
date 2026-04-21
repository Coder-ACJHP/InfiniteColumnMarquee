//
//  AppDelegate.swift
//  InfinityScrollAnimation
//
//  Created by Coder ACJHP on 8.11.2023.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let bounds = UIScreen.main.bounds
        window = UIWindow(frame: bounds)
        let rootViewController = ViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }

}
