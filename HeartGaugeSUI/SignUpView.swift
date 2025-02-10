//
//  SignUpView.swift
//  HeartGaugeSUI
//
//  Created by Kenny Mayancela Aylla on 1/28/25.
//

import SwiftUI

struct SignUpViewUI: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var username: String = ""
    @State private var birthdate: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    var body: some View {
        ZStack {
            // Background color
            Color(red: 0.4, green: 0.4, blue: 0.9)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("HeartGauge")
                        .font(.title)
                        .bold()
                        .foregroundColor(.black)
                    
                    Text("Sign Up")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.black)
                    
                    // Input fields
                    Group {
                        CustomTextField(placeholder: "First Name", text: $firstName)
                        CustomTextField(placeholder: "Last Name", text: $lastName)
                        CustomTextField(placeholder: "Username", text: $username)
                        CustomTextField(placeholder: "Birthdate", text: $birthdate, optional: true)
                        CustomTextField(placeholder: "Email", text: $email)
                        CustomTextField(placeholder: "Phone Number", text: $phoneNumber, optional: true)
                        SecureTextField(placeholder: "Password", text: $password)
                        SecureTextField(placeholder: "Confirm Password", text: $confirmPassword)
                    }
                    
                    Button(action: {
                       
                    }) {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }
                    
                    // Divider with text
                    
                }
                .padding()
            }
        }
    }
}

// Custom TextField with optional tag
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var optional: Bool = false
    
    var body: some View {
            HStack {
                TextField(placeholder, text: $text)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .frame(maxHeight: 45)
                
                if optional {
                    Text("Opt.")
                        .font(.caption)
                        .foregroundColor(.black)
                        .padding(.leading, -8)
                }
            }
    }
}

// Secure TextField for passwords
struct SecureTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        SecureField(placeholder, text: $text)
            .padding()
            .background(Color.white)
            .cornerRadius(8)
    }
}

// Custom line for divider


#Preview {
    SignUpViewUI()
}
