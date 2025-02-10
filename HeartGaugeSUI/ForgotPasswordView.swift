
//
//  ForgotPasswordView.swift
//  HeartGaugeSUI
//
//  Created by Kenny Mayancela Aylla on 2/4/25.
//

import SwiftUI

struct ForgotPasswordViewUI: View {
    @State private var username: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Logo
            Image("Untitled-2-removebg-preview")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .foregroundColor(.white)
            
            Text("HeartGauge")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                TextField("Username", text: $username)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                
                Button(action: requestResetLink) {
                    Text("Forgot Password")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button("Back To Login") {
                    dismiss()
                }
                .foregroundColor(.white)
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.4, green: 0.4, blue: 0.9))
        .edgesIgnoringSafeArea(.all)
    }
    
    private func requestResetLink() {
        // Handle password reset logic here
        print("Password reset requested for: \(username)")
    }
}

// Preview Provider
#Preview {
   ForgotPasswordViewUI()
}
