import SwiftUI

// 用户模型
struct User: Codable {
    let username: String
    let email: String
    let password: String
}


// 登录视图
struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingSignUp = false
    @State private var errorMessage = ""
    @State private var showError = false
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("currentUserEmail") var currentUserEmail = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome Back")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding(.horizontal)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button(action: login) {
                Text("Sign In")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#FF9D1D"))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button("Don't have an account? Sign Up") {
                isShowingSignUp = true
            }
        }
        .padding()
        .sheet(isPresented: $isShowingSignUp) {
            SignUpView()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    func login() {
        if let userData = UserDefaults.standard.data(forKey: email),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            if user.password == password {
                isLoggedIn = true
                currentUserEmail = email
            } else {
                errorMessage = "Incorrect password"
                showError = true
            }
        } else {
            errorMessage = "User not found"
            showError = true
        }
    }
}

// 注册视图
struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding(.horizontal)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: signUp) {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#FF9D1D"))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func signUp() {
        // 验证输入
        if username.isEmpty || email.isEmpty || password.isEmpty {
            errorMessage = "All fields are required"
            showError = true
            return
        }
        
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            showError = true
            return
        }
        
        // 检查邮箱是否已被注册
        if UserDefaults.standard.data(forKey: email) != nil {
            errorMessage = "Email already registered"
            showError = true
            return
        }
        
        // 创建新用户
        let user = User(username: username, email: email, password: password)
        
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: email)
            dismiss()
        } else {
            errorMessage = "Failed to create account"
            showError = true
        }
    }
}

// 主页面视图
struct MainView: View {
    let userEmail: String
    @AppStorage("isLoggedIn") var isLoggedIn = true
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome!")
                    .font(.largeTitle)
                
                Text("Logged in as: \(userEmail)")
                    .padding()
                
                Button("Sign Out") {
                    isLoggedIn = false
                }
                .padding()
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    ContentView()
}
