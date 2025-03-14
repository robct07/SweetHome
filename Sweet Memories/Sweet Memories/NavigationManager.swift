import SwiftUI

class NavigationManager: ObservableObject {
    static let shared = NavigationManager()
    @Published var shouldNavigateToHome = false
    
    func navigateToHome() {
        shouldNavigateToHome = true
    }
}
//
//  NavigationManager.swift
//  Sweet Memories
//
//  Created by Yunuo Jin on 2/27/25.
//

