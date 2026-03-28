//
//  BootstrapDemoApp.swift
//  BootstrapDemo
//
//  Created by 김동현 on 3/23/26.
//

import SwiftUI
import BootstrapFirebase

@main
struct BootstrapDemoApp: App {
    
    init() {
        // BootstrapFirebase.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
