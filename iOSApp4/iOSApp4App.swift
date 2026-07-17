//
//  iOSApp4App.swift
//  iOSApp4
//
//  Created by stephanie otteson on 2026-07-12.
//

import SwiftUI
import FirebaseCore // Import the Firebase library

// Create a native AppDelegate wrapper to handle the initialization
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Initialize the Firebase cloud connection using camelCase variables
        FirebaseApp.configure()
        return true
    }
}

@main
struct iOSApp4: App {
    // Inject the delegate into the SwiftUI lifecycle
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}
