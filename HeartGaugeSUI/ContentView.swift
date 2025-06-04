import SwiftUI


// Updated ContentView to include navigation after login
struct ContentViewUI: View {
   @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var isActive: Bool = false
//    let username: String // Receive the username
    @State private var showSplash = true

    let signOut: () -> Void
    var body: some View {
        NavigationView {
            
            ZStack {
                
                Color(red: 0.4, green: 0.4, blue: 0.9)
                    .ignoresSafeArea()
                
                if isLoggedIn {
                    HomeViewUI()
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
                        NavigationLink(destination: SignUpView()) {
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
//                            handleSignupButton()
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
//        func handleSignupButton() {
//            print("sign in with google clicked")
//            
//            if let rootViewController = getRootViewController(){
                
//            
//            GIDSignIn.sharedInstance.signIn(
//                withPresenting: rootViewController
//            ){ result, error in
//                guard let result else{
//                    return
//                }
//                print(result.user.profile?.name ?? "d" as Any)
//                print(result.user.profile?.email, ??"default value!" as Any)
////                print(result.user.profile?.imageURL(withDimension: 200) ?? "d"! as Any)
//            }
//        }
//    }

struct Line: View {
    var body: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.black.opacity(0.5))
    }
}

//func getRootViewController() -> UIViewController? {
//        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let rootViewController = scene.windows.first?.rootViewController else {
//            return nil
//        }
//        
//        return getVisibleViewController(from: rootViewController)
//    }
//    
    /// Recursively traverses the view controller hierarchy to find the topmost visible controller.
    /// - Parameter vc: The starting view controller to traverse from
    /// - Returns: The currently visible view controller
//private func getVisibleViewController(from vc: UIViewController) -> UIViewController {
//        if let nav = vc as? UINavigationController {
//            return getVisibleViewController(from: nav.visibleViewController!)
//        }
//        
//        if let tab = vc as? UITabBarController {
//            return getVisibleViewController(from: tab.selectedViewController!)
//        }
//        
//        if let presented = vc.presentedViewController {
//            return getVisibleViewController(from: presented)
//        }
//        
//        return vc
//    }
#Preview {
    ContentViewUI(signOut: {})
}
