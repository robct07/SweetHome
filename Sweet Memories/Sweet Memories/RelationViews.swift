import SwiftUI

// 关系类型枚举
enum RelationType: String, CaseIterable {
    case family = "Family"
    case friends = "Friends"
    case lovedOne = "Loved one"
    
    var backgroundColor: Color {
        switch self {
        case .family: return Color(hex: "#FFF5E9")
        case .friends: return Color(hex: "#F5F5FF")
        case .lovedOne: return Color(hex: "#FFF5F5")
        }
    }
}

struct RelationSelectionView: View {
    @AppStorage("hasSelectedRelation") var hasSelectedRelation = false
    @State private var selectedRelation: RelationType?
    @State private var navigateToShare = false
    
    let cardWidth: CGFloat = 147  // 固定卡片宽度
    let cardHeight: CGFloat = 173  // 固定卡片高度
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // 标题部分
            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Who would you like to create memories with?")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 40)
            .padding(.top, 10)
            
            // 卡片布局
            ZStack {
                // Family 卡片 - 左上
                VStack(spacing: 8) {
                    RelationCard(type: .family, isSelected: .family == selectedRelation)
                        .frame(width: cardWidth, height: cardHeight)
                        .onTapGesture {
                            selectedRelation = .family
                        }
                    Text("Family")
                        .font(.headline)
                }
                .offset(x: -90, y: -110)
                
                // Friends 卡片 - 右中
                VStack(spacing: 8) {
                    RelationCard(type: .friends, isSelected: .friends == selectedRelation)
                        .frame(width: cardWidth, height: cardHeight)
                        .onTapGesture {
                            selectedRelation = .friends
                        }
                    Text("Friends")
                        .font(.headline)
                }
                .offset(x: 90, y: -10)
                
                // Loved one 卡片 - 左下
                VStack(spacing: 8) {
                    RelationCard(type: .lovedOne, isSelected: .lovedOne == selectedRelation)
                        .frame(width: cardWidth, height: cardHeight)
                        .onTapGesture {
                            selectedRelation = .lovedOne
                        }
                    Text("Loved one")
                        .font(.headline)
                }
                .offset(x: -90, y: 120)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Next 按钮
            Button(action: {
                if selectedRelation != nil {
                    navigateToShare = true  // 触发导航到分享页面
                }
            }) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedRelation != nil ? Color(hex: "#FF9D1D") : Color.gray)
                    .cornerRadius(25)
            }
            .disabled(selectedRelation == nil)
            .padding()
            .navigationDestination(isPresented: $navigateToShare) {
                ShareView()
                    .navigationBarBackButtonHidden()
            }
        }
        .padding(.top, 40)
    }
}

struct RelationCard: View {
    let type: RelationType
    let isSelected: Bool
    
    var body: some View {
        VStack {
            Image(type.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)  // 调整图标大小
                .padding(.top, 20)  // 增加顶部间距
            
            Spacer()  // 使图标位于卡片上部
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(type.backgroundColor)
        .cornerRadius(20)
        .shadow(color: isSelected ? Color(hex: "#FF9D1D").opacity(0.3) : .clear,
                radius: isSelected ? 4 : 0,
                x: 0,
                y: isSelected ? 4 : 0)
    }
}

// RelationType 保持不变
extension RelationType {
    
    var imageName: String {
        switch self {
        case .family: return "family_icon"
        case .friends: return "friends_icon"
        case .lovedOne: return "loved_one_icon"
        }
    }
}

// Color 扩展
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                 red: Double(r) / 255,
                 green: Double(g) / 255,
                 blue: Double(b) / 255,
                 opacity: Double(a) / 255)
    }
}

#Preview {
    RelationSelectionView()
        .environmentObject(NavigationManager.shared)  
}
//  RelationViews.swift
//  Sweet Memories
//
//  Created by Yunuo Jin on 2/18/25.
//

