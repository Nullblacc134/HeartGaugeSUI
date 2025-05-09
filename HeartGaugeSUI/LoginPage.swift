//
//  LoginPage.swift
//  HeartGaugeSUI
//
//  Created by Kenny Mayancela Aylla on 4/3/25.
//

import SwiftUI

import GoogleSignIn

import GoogleSignInSwift



struct GoogleSignInButtonView: View {

    @State private var user: GIDGoogleUser?  // Store the signed-in user

    @State private var isLoggedIn = false   // Track the login state



    var body: some View {

        NavigationStack {

            VStack {

                if isLoggedIn {

                    HomeViewUI(username: user?.profile?.name ?? "User", signOut: {

                        signOut()

                    })

                } else {

                    GoogleSignInButton {

                        signIn()

                    }

                    .padding()

                }

            }

            .navigationTitle("Login")

        }

    }



    func signIn() {

        guard let rootViewController = UIApplication.shared.connectedScenes

            .compactMap({ $0 as? UIWindowScene })

            .flatMap({ $0.windows })

            .first(where: { $0.isKeyWindow })?.rootViewController else {

            print("Failed to access root view controller")

            return

        }



        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in

            if let error = error {

                print("Error during sign-in: \(error.localizedDescription)")

                return

            }



            // Update the user state

            user = signInResult?.user

            isLoggedIn = (user != nil)

        }

    }



    func signOut() {

        GIDSignIn.sharedInstance.signOut()

        user = nil

        isLoggedIn = false

        print("User signed out successfully.")

    }

}



struct HomeView: View {

    let username: String // Receive the username

    let signOut: () -> Void // Closure to handle sign-out



    var body: some View {

        
        
        VStack {
            
            Text("Welcome to the Home View!")

                .font(.largeTitle)

                .padding()



            Text("Hello, \(username)!")

                .font(.title)

                .padding()



            Button("Sign Out") {

                signOut()

            }

            .padding()

            .foregroundColor(.red)

        }

        .navigationTitle("Home")

    }

}



#Preview {

    GoogleSignInButtonView()

}
