//
//  HeartGaugeSUIApp.swift
//  HeartGaugeSUI
//
//  Created by Kenny Mayancela Aylla on 1/15/25.
//

import SwiftUI
import GoogleSignIn

@main
struct MyApp: App {
    
    init() {

              GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in

                  if let user = user {

                      print("Restored session for: \(user.profile?.name ?? "Unknown")")

                  } else {

                      print("No previous session found.")

                  }

              }

          }



          var body: some Scene {

              WindowGroup {

//                  GoogleSignInButtonView()
                  ContentViewUI(signOut: {})

              }

          }

      }
