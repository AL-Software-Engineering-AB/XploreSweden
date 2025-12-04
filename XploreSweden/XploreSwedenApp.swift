//
//  XploreSwedenApp.swift
//  XploreSweden
//
//  Created by Linus Rengbrandt on 2025-11-11.
//

import SwiftUI
import GoogleMobileAds

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
     //   let ads = MobileAds()
     //   ads.start()
        return true
    }
}

@main
struct XploreSwedenApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
