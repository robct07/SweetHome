import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("userName") private var userName = "User Name"
    @AppStorage("userEmail") private var userEmail = "user@example.com"
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image("userAvatar") // 替换为实际的用户头像
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(userName)
                                .font(.title2)
                                .fontWeight(.medium)
                            Text(userEmail)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Account") {
                    NavigationLink {
                        Text("Edit Profile")
                    } label: {
                        Label("Edit Profile", systemImage: "person")
                    }
                    
                    NavigationLink {
                        Text("Notifications")
                    } label: {
                        Label("Notifications", systemImage: "bell")
                    }
                    
                    NavigationLink {
                        Text("Privacy")
                    } label: {
                        Label("Privacy", systemImage: "lock")
                    }
                }
                
                Section("Preferences") {
                    NavigationLink {
                        Text("Theme")
                    } label: {
                        Label("Theme", systemImage: "paintbrush")
                    }
                    
                    NavigationLink {
                        Text("Language")
                    } label: {
                        Label("Language", systemImage: "globe")
                    }
                }
                
                Section("Device") {
                    NavigationLink {
                        Text("Connected Devices")
                    } label: {
                        Label("Connected Devices", systemImage: "printer")
                    }
                    
                    NavigationLink {
                        Text("Device Settings")
                    } label: {
                        Label("Device Settings", systemImage: "gearshape")
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        // Handle logout
                    } label: {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}

//
//  ProfileView.swift
//  Sweet Memories
//
//  Created by Yunuo Jin on 2/27/25.
//

