//
//  BootstrapDemoApp.swift
//  BootstrapDemo
//
//  Created by 김동현 on 3/23/26.
//

import SwiftUI
import BootstrapFirebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        BootstrapFirebase.configure(
            BootstrapConfig(
                firebase: true,
                kakaoAppKey: "")
        )
        return true
    }
}

@main
struct BootstrapDemoApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            // LoginView()
            ContentView()
        }
    }
}
