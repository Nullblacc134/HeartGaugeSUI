import SwiftUI

// Enhanced ContentView with improved visuals
struct ContentViewUI: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var isActive: Bool = false
    @State private var showSplash = true
    @State private var isPasswordVisible: Bool = false
    @State private var showSignUp = false
    @State private var showForgotPassword = false
    
    let signOut: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                // Enhanced gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.3, green: 0.3, blue: 0.8),
                        Color(red: 0.5, green: 0.4, blue: 0.95),
                        Color(red: 0.4, green: 0.5, blue: 0.9)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Floating particles effect
                ParticleView()
                
                if isLoggedIn {
                   HomeViewUI()
                } else {
                    ScrollView {
                        VStack(spacing: 30) {
                            // Enhanced Logo Section
                            VStack(spacing: 15) {
                                // Logo with shadow and glow effect
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                        .frame(width: 140, height: 140)
                                        .blur(radius: 20)
                                    
                                    VStack(spacing: 8) {
                                        // Gaming controller with hearts icon
                                        
                                            Image("Untitled-2-removebg-preview")
                                        .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 120, height: 120)
                                                .foregroundColor(.black)
                                            
                                            .offset(y: 10)
                                        
                                        Text("HeartGauge")
                                            .font(.system(size: 28, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                                        
                                        Text("Monitor Your Gaming Wellness")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                            }
                            .padding(.top, 40)
                            
                            // Enhanced Input Section - Fields remain for UI but not required
                            VStack(spacing: 20) {
                                // Username Field
                                CustomTextFi(
                                    text: $username,
                                    placeholder: "Username (Optional)",
                                    icon: "person.fill"
                                )
                                
                                // Password Field
                                CustomSecureF(
                                    text: $password,
                                    placeholder: "Password (Optional)",
                                    isVisible: $isPasswordVisible
                                )
                            }
                            .padding(.horizontal, 40)
                            
                            // Enhanced Buttons Section
                            VStack(spacing: 16) {
                                // Login Button - Now works without validation
                                Button(action: {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        isLoggedIn = true
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.right.circle.fill")
                                        Text("Login")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.white, Color.white.opacity(0.9)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundColor(.black)
                                    .cornerRadius(28)
                                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                                }
                                .scaleEffect(1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isLoggedIn)
                                
                                // Register Button
                                NavigationLink(destination: SignUpView()) {
                                    HStack {
                                        Image(systemName: "person.badge.plus")
                                        Text("Create New Account")
                                            .fontWeight(.medium)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color.white.opacity(0.15))
                                    .foregroundColor(.white)
                                    .cornerRadius(28)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 28)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.horizontal, 40)
                            
                            // Forgot Password Link
                            NavigationLink(destination: ForgotPasswordViewUI()) {
                                Text("Forgot Password?")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .underline()
                            }
                            .padding(.top, 10)
                            
                            // Divider with text
                            HStack {
                                EnhancedLine()
                                Text("or continue with")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.horizontal, 16)
                                EnhancedLine()
                            }
                            .padding(.horizontal, 40)
                            .padding(.vertical, 20)
                            
                            // Google Sign Up Button
                            Button(action: {
                                // This could also directly login without authentication
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    isLoggedIn = true
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "globe")
                                        .font(.system(size: 18, weight: .medium))
                                    Text("Continue with Google")
                                        .fontWeight(.medium)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .cornerRadius(28)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .padding(.horizontal, 40)
                            
                            Spacer(minLength: 40)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            // Updated sheet presentations with proper navigation
            }
        }
    }


// Custom TextField Component
struct CustomTextFi: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// Custom SecureField Component
struct CustomSecureF: View {
    @Binding var text: String
    let placeholder: String
    @Binding var isVisible: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "lock.fill")
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 20)
            
            if isVisible {
                TextField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            } else {
                SecureField(placeholder, text: $text)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            Button(action: {
                isVisible.toggle()
            }) {
                Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// Enhanced Line Component
struct EnhancedLine: View {
    var body: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.white.opacity(0.3))
    }
}

// Particle Animation Effect
struct ParticleView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<15, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: CGFloat.random(in: 4...12))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .scaleEffect(animate ? 1.2 : 0.8)
                    .opacity(animate ? 0.3 : 0.1)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...2)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Placeholder Views for SignUp and ForgotPassword
// You can replace these with your actual view implementations

#Preview {
    ContentViewUI(signOut: {})
}
