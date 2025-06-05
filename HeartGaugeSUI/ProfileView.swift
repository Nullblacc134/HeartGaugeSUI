import SwiftUI

struct ProfileUpdateView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var birthday = Date()
    @State private var password = ""
    @State private var showDatePicker = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.4, green: 0.3, blue: 0.8),
                        Color(red: 0.6, green: 0.4, blue: 0.9),
                        Color(red: 0.5, green: 0.6, blue: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Profile Image Section
                        VStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                    )
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                // Camera icon for editing
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 36, height: 36)
                                            .overlay(
                                                Image(systemName: "camera.fill")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.purple)
                                            )
                                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                    }
                                }
                                .frame(width: 120, height: 120)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Form Fields
                        VStack(spacing: 20) {
                            // Username Field
                            FormField(
                                icon: "person",
                                placeholder: "Username",
                                text: $username
                            )
                            
                            // Email Field
                            FormField(
                                icon: "envelope",
                                placeholder: "Email address",
                                text: $email,
                                keyboardType: .emailAddress
                            )
                            
                            // Phone Field
                            FormField(
                                icon: "phone",
                                placeholder: "Phone number",
                                text: $phoneNumber,
                                keyboardType: .phonePad
                            )
                            
                            // Birthday Field
                            Button(action: {
                                showDatePicker.toggle()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                        .frame(width: 20)
                                    
                                    Text(birthday == Date() ? "Birthday" : DateFormatter.shortDate.string(from: birthday))
                                        .foregroundColor(birthday == Date() ? .white.opacity(0.7) : .white)
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                            }
                            
                            // Password Field
                            FormField(
                                icon: "lock",
                                placeholder: "Password",
                                text: $password,
                                isSecure: true
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        // Update Button
                        Button(action: updateProfile) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Update Profile")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.purple)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                        
                        Spacer(minLength: 30)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Settings")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Edit Profile")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(selectedDate: $birthday, isPresented: $showDatePicker)
        }
    }
    
    private func updateProfile() {
        // Handle profile update logic here
        print("Profile updated!")
        // You might want to call an API or update local storage
        presentationMode.wrappedValue.dismiss()
    }
}

struct FormField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 20)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .medium))
            .keyboardType(keyboardType)
            .autocapitalization(keyboardType == .emailAddress ? .none : .words)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct DatePickerS: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Birthday",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(WheelDatePickerStyle())
                .padding()
                
                Spacer()
            }
            .navigationTitle("Birthday")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// Extension for date formatting
extension DateFormatter {
    static let shortD: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

// Example SettingsUI View that would navigate to this profile view

#Preview{
        ProfileUpdateView()
    }
