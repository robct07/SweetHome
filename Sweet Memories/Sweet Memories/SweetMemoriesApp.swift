import SwiftUI

@main
struct SweetMemoriesApp: App {
    @StateObject private var navigationManager = NavigationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigationManager)
        }
    }
}
//  SweetMemoriesApp.swift
//  Sweet Memories
//
//  Created by Yunuo Jin on 2/18/25.
//

