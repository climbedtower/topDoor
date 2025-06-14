//
//  topDoorApp.swift
//  topDoor
//
//  Created by yuco on 2025/06/15.
//

import SwiftUI

@main
struct topDoorApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        MenuBarExtra("topDoor", systemImage: "hammer.circle") {
            MenuBarContentView()
                .environmentObject(appState)
                .onAppear {
                    // アプリをバックグラウンドアプリとして設定
                    DispatchQueue.main.async {
                        NSApp.setActivationPolicy(.accessory)
                    }
                }
        }
        .menuBarExtraStyle(.window)
    }
}
