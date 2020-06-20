//
//  AppDelegate.swift
//  Earth
//
//  Created by Anastasia Myropolska on 20.06.20.
//  Copyright © 2020 Home. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = EarthViewController()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
        return true
    }
}

