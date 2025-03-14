import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var navigationManager: NavigationManager 
    @State private var showProfile = false
    @State private var showDeviceConnection = false
    @State private var isDeviceConnected = false
    @State private var showShareView = false
    @State private var showInviteView = false
    @AppStorage("joinDate") private var joinDate = Date()
    @AppStorage("matchedUserId") private var matchedUserId: String?
    
    
    var daysJoined: Int {
        Calendar.current.dateComponents([.day], from: joinDate, to: Date()).day ?? 0
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                // Top section
                HStack {
                    Text("Day \(daysJoined) of Journey")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Button(action: { showProfile = true }) {
                        Circle()
                            .fill(Color(hex: "#FF9D1D"))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(getUserInitials())
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .medium))
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Device connection status
                HStack {
                    if isDeviceConnected {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Printer connected")
                            .foregroundColor(.gray)
                    } else {
                        Text("No device connected")
                            .foregroundColor(.gray)
                        Button("Connect") {
                            showDeviceConnection = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal)
                
                // Main content area
                 if matchedUserId == nil {
                     VStack(spacing: 20) {
                         // Background image
                         Image("waiting_background") // 添加一张静态背景图
                             .resizable()
                             .aspectRatio(contentMode: .fill)
                             .frame(width: 300, height: 10)
                             .clipShape(RoundedRectangle(cornerRadius: 50))
                             .shadow(color: Color.black.opacity(0.1), radius: 10)
                         
                         // GIF overlay
                         GIFView(name: "Invite Friend") // 自定义 GIF 视图
                             .frame(width: 240, height: 240)
                             .clipShape(RoundedRectangle(cornerRadius: 25))
                         
                         Text("Cherish every moment with your loved one!")
                             .font(.title3)
                             .multilineTextAlignment(.center)
                             .padding(.horizontal)
                         
                         Button(action: { showInviteView = true }) {
                             Text("Invite Friend")
                                 .font(.headline)
                                 .foregroundColor(.white)
                                 .frame(maxWidth: .infinity)
                                 .padding()
                                 .background(Color(hex: "#FF9D1D"))
                                 .cornerRadius(25)
                         }
                         .padding(.horizontal, 40)
                     }
                     .padding(.vertical, 30)
                 } else {
                     // Show matched content
                     ScrollView {
                         VStack(alignment: .leading, spacing: 15) {
                             Text("Recent Shares")
                                 .font(.title3)
                                 .fontWeight(.bold)
                                 .padding(.horizontal)
                             
                             // Add your recent shares content here
                             Text("No recent shares")
                                 .foregroundColor(.gray)
                                 .frame(maxWidth: .infinity, alignment: .center)
                                 .padding()
                         }
                     }
                 }
                 
                 Spacer()
                 
                
                // Custom tab bar
                CustomTabBar(showShareView: $showShareView)
            }
            .sheet(isPresented: $showShareView) {
                ShareView()
                    .environmentObject(navigationManager)
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .sheet(isPresented: $showDeviceConnection) {
                DeviceConnectionView()
            }
            .sheet(isPresented: $showShareView) {
                ShareView()
            }
            .sheet(isPresented: $showInviteView) {
                InviteFriendView()
            }
        }
        .onAppear {
            // 添加通知观察者来关闭分享流程
            NotificationCenter.default.addObserver(
                forName: .dismissAllShareViews,
                object: nil,
                queue: .main) { _ in
                    showShareView = false  // 关闭分享视图，返回主页
                }
        }
    }
    
    private func getUserInitials() -> String {
        // Replace with actual user name logic
        "UN"
    }
}
                
            
struct CustomTabBar: View {
    @Binding var showShareView: Bool
    
    var body: some View {
        HStack {
            TabBarButton(image: "house.fill", text: "Home", isSelected: true)
            TabBarButton(image: "square.grid.2x2", text: "Moments", isSelected: false)
            
            // Center add button
            Button(action: { showShareView = true }) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#FF9D1D"))
                        .frame(width: 60, height: 60)
                        .shadow(
                            color: Color(hex: "#FF9D1D").opacity(0.3),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                    
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .offset(y: -20)
            
            TabBarButton(image: "book", text: "Scrapbook", isSelected: false)
            TabBarButton(image: "chart.line.uptrend.xyaxis", text: "Stats", isSelected: false)
        }
        .padding()
        .background(Color.white)
    }
}

struct TabBarButton: View {
    let image: String
    let text: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: image)
                .font(.system(size: 20))
            Text(text)
                .font(.caption2)
        }
        .foregroundColor(isSelected ? Color(hex: "#FF9D1D") : .gray)
        .shadow(
            color: Color(hex: "#FF9D1D").opacity(0.1),
            radius: 4,
            x: 0,
            y: 2
        )
        .frame(maxWidth: .infinity)
    }
}


struct InviteFriendView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var inviteCode = "EBQPMUYF"
    @State private var inputCode = ""
    @State private var showInputField = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Button(action: {}) {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("Invite Friends")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            Text("Cherish every moment with\nyour friends")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            // Invitation card
            VStack {
                // GIF container
                GIFView(name: "Invite Friend2")
                    .frame(width: 280, height: 280) // 设置GIF容器的尺寸
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                
                Button(action: {
                    // Share invitation logic
                }) {
                    HStack {
                        Text("Share the invitation")
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(hex: "#FF9D1D"))
                    .cornerRadius(25)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
            
            Text("or")
                .foregroundColor(.gray)
            
            HStack {
                Text("My code: \(inviteCode)")
                Button(action: {
                    // Copy code logic
                }) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(Color(hex: "#FF9D1D"))
                }
            }
            
            Button(action: { showInputField = true }) {
                Text("Enter code")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#FF9D1D"))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#FF9D1D").opacity(0.1))
                    .cornerRadius(25)
            }
        }
        .padding()
    }
}
             

struct ShareOptionsOverlay: View {
    @Binding var selectedType: ShareType?
    @Binding var showShareOptions: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            ShareOptionButton(
                icon: "face.smiling",
                type: .mood,
                selectedType: $selectedType,
                showShareOptions: $showShareOptions
            )
            ShareOptionButton(
                icon: "camera",
                type: .media,
                selectedType: $selectedType,
                showShareOptions: $showShareOptions
            )
            ShareOptionButton(
                icon: "pencil",
                type: .write,
                selectedType: $selectedType,
                showShareOptions: $showShareOptions
            )
        }
        .offset(y: -80)
    }
}

struct ShareOptionButton: View {
    let icon: String
    let type: ShareType
    @Binding var selectedType: ShareType?
    @Binding var showShareOptions: Bool
    
    var body: some View {
        Button(action: {
            selectedType = type
            showShareOptions = false
        }) {
            Circle()
                .fill(Color(hex: "#FF9D1D"))
                .frame(width: 45, height: 45)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(.white)
                )
        }
    }
}

struct EnterCodeView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var code: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Invitation Code")
                .font(.title2)
                .fontWeight(.medium)
            
            TextField("Enter code", text: $code)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button(action: {
                // Verify code logic
                dismiss()
            }) {
                Text("Confirm")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#FF9D1D"))
                    .cornerRadius(25)
            }
            .padding(.horizontal)
            
            Button("Cancel") {
                dismiss()
            }
            .foregroundColor(.gray)
        }
        .padding()
    }
}


// Preview
#Preview {
    HomeView()
}
