//
//  ProfileView.swift
//  HeartGaugeSUI
//
//  Created by Kenny Mayancela Aylla on 1/28/25.
//

import SwiftUI

struct ProfileViewUI: View {
    @Environment(\.dismiss) var dismiss
    @State private var username: String = "randomUser"
    @State private var email: String = "yourname@gmail.com"
    @State private var phoneNumber: String = "(XXX) XXX-XXXX"
    @State private var birthday: String = "MM/DD/YYYY"
    @State private var password: String = "••••••••••••"
    
    var body: some View {
        ZStack {
            // Background color
            Color(red: 0.4, green: 0.4, blue: 0.9)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                // Header with back button
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                // Profile Image
                HStack {
                    Spacer()
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.bottom, 20)
                
                // Profile Fields
                VStack(alignment: .leading, spacing: 15) {
                    ProfileField(title: "Username", text: $username)
                    ProfileField(title: "Email address", text: $email)
                    ProfileField(title: "Phone number", text: $phoneNumber)
                    ProfileField(title: "Birthday", text: $birthday)
                    ProfileField(title: "Password", text: $password, isSecure: true)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Update Button
                Button(action: {
                    // Add update action
                }) {
                    Text("Update profile")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .padding(.top, 20)
        }
        .navigationBarHidden(true)
    }
}

struct ProfileField: View {
    let title: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .medium))
            
            if isSecure {
                SecureField("", text: $text)
                    .padding(10)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(8)
                    .disabled(true)
            } else {
                TextField("", text: $text)
                    .padding(10)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(8)
            }
        }
    }
}


#Preview {
    ProfileViewUI()
}
