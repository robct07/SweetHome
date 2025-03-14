import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("hasSelectedRelation") var hasSelectedRelation = false 
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            if !isLoggedIn {
                LoginView()
            } else if !hasSelectedRelation {
                RelationSelectionView()  // 添加关系选择视图
            } else {
                HomeView()
            }
        }
        .onChange(of: navigationManager.shouldNavigateToHome) { _, shouldNavigate in
            if shouldNavigate {
                path = NavigationPath()
                navigationManager.shouldNavigateToHome = false
                
                // 确保用户已完成所有必要步骤
                if !isLoggedIn {
                    isLoggedIn = true
                }
                if !hasSelectedRelation {
                    hasSelectedRelation = true
                }
            }
        }
    }
}
#Preview {
    ContentView()
        .environmentObject(NavigationManager.shared)
}
//
//  Untitled.swift
//  Sweet Memories
//
//  Created by Yunuo Jin on 2/18/25.
//

