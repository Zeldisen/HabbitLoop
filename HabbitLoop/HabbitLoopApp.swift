//
//  HabbitLoopApp.swift
//  HabbitLoop
//
//  Created by Jeanette Norberg on 2025-04-29.
//

import SwiftUI
import FirebaseCore
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Fel vid förfrågan om notis-tillstånd: \(error)")
            } else {
                print("Tillstånd beviljat? \(granted)")
            }
        }
    }
}

@main
struct HabbitLoopApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var auth = AuthViewModel()
    var body: some Scene {
        WindowGroup {
            RootView()
             .environmentObject(auth)
        }
    }
}
