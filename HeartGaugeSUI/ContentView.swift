import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color matching your app
                Color(red: 0.4, green: 0.4, blue: 0.9)
                    .ignoresSafeArea()
                
                VStack {
                    // Content area
                    switch selectedTab {
                    case 0:
                        HomeViewUI()
                    case 1:
                        RecentlyPlayedUI()
                    default:
                        EmptyView()
                    }
                    
                    // Navigation buttons at bottom
                    VStack(spacing: 15) {
                        Divider()
                            .background(Color.white)
                      
                        
                        // Google Sign up button
                        
                        HStack(spacing: 20) {
                            ForEach(["Home", "Recently Played"].indices, id: \.self) { index in
                                Button(action: {
                                    withAnimation {
                                        selectedTab = index
                                    }
                                }) {
                                    Text(["Home", "Gaming Logs"][index])
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.white.opacity(selectedTab == index ? 0.3 : 0.2))
                                        )
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .medium))
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// New ProfileView
struct ProfileView: View {
    var body: some View {
        VStack {
            Text("Profile")
                .font(.title)
                .foregroundColor(.white)
                .padding()
            
            // Add profile content here
            Spacer()
        }
    }
}

// Updated SettingsView
struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings")
                .font(.title)
                .foregroundColor(.white)
                .padding()
            
            // Add settings content here
            Spacer()
        }
    }
}

// Updated ContentView to include navigation after login
struct ContentViewUI: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var isActive: Bool = false

    var body: some View {
        NavigationView {
            
            ZStack {
                // Background color
                Color(red: 0.4, green: 0.4, blue: 0.9)
                    .ignoresSafeArea()
                
                if isLoggedIn {
                    MainTabView()
                } else {
                    // Your existing login view content
                    VStack(spacing: 20) {
                        // Logo
                        VStack(spacing: 0) {
                            Image("Untitled-2-removebg-preview")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                            
                            Text("HeartGauge")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.black)
                        }
                        .padding(.bottom, 30)
                        
                        // Input fields
                        TextField("Username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 280)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 280)
                        
                        // Login button
                        Button(action: {
                            // Simulate login
                            isLoggedIn = true
                        }) {
                            Text("Login")
                                .frame(maxWidth: 280)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        
                        // Register button
                        NavigationLink(destination: SignUpViewUI()) {
                            Text("Register New Account")
                                .frame(maxWidth: 280)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }

                        
                        // Forgot password link
                        NavigationLink(destination: ForgotPasswordViewUI()) {
//                             Add forgot password action
                            Text("Forgot Password")
                                .foregroundColor(.black)
                                .underline()
                        }
                        HStack {
                            Line()
                            Text("Already have an account? Log In")
                                .font(.caption)
                                .foregroundColor(.black)
                            Line()
                        }
                        .padding(.vertical)
                        Button(action: {
                            // Add Google sign up action
                        }) {
                            HStack {
                                Image(systemName: "g.circle.fill")
                                    .foregroundColor(.white)
                                Text("Sign up with Google")
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: 280)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                     
                        }
                        Spacer()
                    }
                    .padding(.top, 60)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct Line: View {
    var body: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.black.opacity(0.5))
    }
}
#Preview{
    ContentViewUI()
}

