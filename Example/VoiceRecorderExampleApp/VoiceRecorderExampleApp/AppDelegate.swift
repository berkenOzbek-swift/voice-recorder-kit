//
//  AppDelegate.swift
//  VoiceRecorderExampleApp
//
//  Created by berken on 6.09.2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    window?.rootViewController = VoiceRecordRouter.setupModule()
    window?.makeKeyAndVisible()
    window?.overrideUserInterfaceStyle = .dark
    
    return true
  }
}

