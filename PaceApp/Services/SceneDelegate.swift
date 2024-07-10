//
//  SceneDelegate.swift
//  ProjectRunning
//
//  Created by Marcelo Amaral Alves on 2024-06-26.
//

import Foundation
import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let contentView = MainView()
            .environmentObject(LocationService())

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Restore state when app becomes active
        NotificationCenter.default.post(name: Notification.Name("AppDidBecomeActive"), object: nil)
    }
}
