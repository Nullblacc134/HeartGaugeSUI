import SwiftUI

struct SignUpView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var username = ""
    @State private var birthdate = Date()
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var isLoading = false
    @State private var showDatePicker = false
    @State private var showSuccessAlert = false
    @State private var fieldErrors: [String: String] = [:]
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    
    enum Field {
        case firstName, lastName, username, email, phoneNumber, password, confirmPassword
    }
    
    var passwordStrength: Int {
        var strength = 0
        if password.count >= 8 { strength += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { strength += 1 }
        if password.rangeOfCharacter(from: .lowercaseLetters) != nil { strength += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { strength += 1 }
        if password.rangeOfCharacter(from: CharacterSet.punctuationCharacters.union(.symbols)) != nil { strength += 1 }
        return strength
    }
    
    var passwordStrengthColor: Color {
        switch passwordStrength {
        case 0...1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        case 5: return .blue
        default: return .gray
        }
    }
    
    var passwordStrengthText: String {
        switch passwordStrength {
        case 0...1: return "Weak"
        case 2: return "Fair"
        case 3: return "Good"
        case 4: return "Strong"
        case 5: return "Very Strong"
        default: return ""
        }
    }
    
    var isFormValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !username.isEmpty &&
        !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty &&
        password == confirmPassword && isValidEmail(email) && passwordStrength >= 3
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.purple.opacity(0.8),
                        Color.blue.opacity(0.9),
                        Color.indigo
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Header Section
                        VStack(spacing: 16) {
                            // App Icon
                            ZStack {
                                Image(systemName: "Untitled-2-removebg-preview")
                                    .font(.system(size: 36))
                                    .foregroundColor(.black)
                            }
                            .scaleEffect(1.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isLoading)
                            
                            Text("HeartGauge")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Sign Up")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 30)
                        
                        // Form Section
                        VStack(spacing: 20) {
                            // Name Fields
                            HStack(spacing: 12) {
                                CustomTextField(
                                    text: $firstName,
                                    placeholder: "First Name",
                                    icon: "person.fill",
                                    errorMessage: fieldErrors["firstName"]
                                ) {
                                    focusedField = .firstName
                                }
                                .focused($focusedField, equals: .firstName)
                                
                                CustomTextField(
                                    text: $lastName,
                                    placeholder: "Last Name",
                                    icon: "person.fill",
                                    errorMessage: fieldErrors["lastName"]
                                ) {
                                    focusedField = .lastName
                                }
                                .focused($focusedField, equals: .lastName)
                            }
                            
                            // Username Field
                            CustomTextField(
                                text: $username,
                                placeholder: "Username",
                                icon: "at",
                                errorMessage: fieldErrors["username"]
                            ) {
                                focusedField = .username
                            }
                            .focused($focusedField, equals: .username)
                            .textInputAutocapitalization(.never)
                            
                            // Birthdate Field
                            VStack(alignment: .leading, spacing: 8) {
                                Button(action: {
                                    showDatePicker.toggle()
                                    focusedField = nil
                                }) {
                                    HStack {
                                        Image(systemName: "calendar")
                                            .foregroundColor(.gray)
                                            .frame(width: 20)
                                        
                                        Text(birthdate == Date() ? "Birthdate" : DateFormatter.shortDate.string(from: birthdate))
                                            .foregroundColor(birthdate == Date() ? .gray : .primary)
                                        
                                        Spacer()
                                        
                                        Text("Opt.")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(16)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                }
                            }
                            
                            // Email Field
                            CustomTextField(
                                text: $email,
                                placeholder: "Email",
                                icon: "envelope.fill",
                                keyboardType: .emailAddress,
                                errorMessage: fieldErrors["email"]
                            ) {
                                focusedField = .email
                            }
                            .focused($focusedField, equals: .email)
                            .textInputAutocapitalization(.never)
                            
                            // Phone Number Field
                            CustomTextField(
                                text: $phoneNumber,
                                placeholder: "Phone Number",
                                icon: "phone.fill",
                                keyboardType: .phonePad,
                                isOptional: true,
                                errorMessage: fieldErrors["phoneNumber"]
                            ) {
                                focusedField = .phoneNumber
                            }
                            .focused($focusedField, equals: .phoneNumber)
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                CustomSecureField(
                                    text: $password,
                                    placeholder: "Password",
                                    isSecure: !showPassword,
                                    showToggle: true,
                                    onToggle: { showPassword.toggle() },
                                    errorMessage: fieldErrors["password"]
                                ) {
                                    focusedField = .password
                                }
                                .focused($focusedField, equals: .password)
                                
                                // Password Strength Indicator
                                if !password.isEmpty {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            ForEach(0..<5, id: \.self) { index in
                                                Rectangle()
                                                    .fill(index < passwordStrength ? passwordStrengthColor : Color.gray.opacity(0.3))
                                                    .frame(height: 3)
                                                    .cornerRadius(1.5)
                                            }
                                        }
                                        .animation(.easeInOut(duration: 0.2), value: passwordStrength)
                                        
                                        Text(passwordStrengthText)
                                            .font(.caption)
                                            .foregroundColor(passwordStrengthColor)
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                            
                            // Confirm Password Field
                            CustomSecureField(
                                text: $confirmPassword,
                                placeholder: "Confirm Password",
                                isSecure: !showConfirmPassword,
                                showToggle: true,
                                onToggle: { showConfirmPassword.toggle() },
                                errorMessage: fieldErrors["confirmPassword"]
                            ) {
                                focusedField = .confirmPassword
                            }
                            .focused($focusedField, equals: .confirmPassword)
                            
                            // Sign Up Button
                            Button(action: handleSignUp) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "heart.fill")
                                            .font(.system(size: 16))
                                    }
                                    
                                    Text(isLoading ? "Creating Account..." : "Sign Up")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: isFormValid ?
                                            [Color.pink, Color.red] :
                                            [Color.gray.opacity(0.6), Color.gray.opacity(0.4)]
                                        ),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: isFormValid ? Color.pink.opacity(0.4) : Color.clear,
                                       radius: 8, x: 0, y: 4)
                                .scaleEffect(isFormValid ? 1.0 : 0.98)
                                .animation(.easeInOut(duration: 0.2), value: isFormValid)
                            }
                            .disabled(!isFormValid || isLoading)
                            
                            // FIXED: Back To Login Button
                            Button(action: {
                                dismiss() // ✅ This will go back to the previous screen (Login)
                            }) {
                                Text("Back To Login")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                                    )
                            }
                            .padding(.top, 8)
                            
                            // Terms and Privacy
                            VStack(spacing: 8) {
                                Text("By signing up, you agree to our")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                HStack(spacing: 4) {
                                    Button("Terms of Service") {
                                        // Handle terms tap
                                    }
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    
                                    Text("and")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Button("Privacy Policy") {
                                        // Handle privacy tap
                                    }
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                }
                            }
                            .padding(.top, 16)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(selectedDate: $birthdate, isPresented: $showDatePicker)
        }
        .alert("Welcome to HeartGauge!", isPresented: $showSuccessAlert) {
            Button("Continue") {
                // Handle success
            }
        } message: {
            Text("Your account has been created successfully!")
        }
        .onTapGesture {
            focusedField = nil
        }
    }
    
    // MARK: - Functions
    
    private func handleSignUp() {
        // Clear previous errors
        fieldErrors.removeAll()
        
        // Validate form
        var hasErrors = false
        
        if firstName.trimmingCharacters(in: .whitespaces).isEmpty {
            fieldErrors["firstName"] = "First name is required"
            hasErrors = true
        }
        
        if lastName.trimmingCharacters(in: .whitespaces).isEmpty {
            fieldErrors["lastName"] = "Last name is required"
            hasErrors = true
        }
        
        if username.trimmingCharacters(in: .whitespaces).isEmpty {
            fieldErrors["username"] = "Username is required"
            hasErrors = true
        } else if username.count < 3 {
            fieldErrors["username"] = "Username must be at least 3 characters"
            hasErrors = true
        }
        
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            fieldErrors["email"] = "Email is required"
            hasErrors = true
        } else if !isValidEmail(email) {
            fieldErrors["email"] = "Please enter a valid email"
            hasErrors = true
        }
        
        if password.isEmpty {
            fieldErrors["password"] = "Password is required"
            hasErrors = true
        } else if passwordStrength < 3 {
            fieldErrors["password"] = "Password is too weak"
            hasErrors = true
        }
        
        if confirmPassword.isEmpty {
            fieldErrors["confirmPassword"] = "Please confirm your password"
            hasErrors = true
        } else if password != confirmPassword {
            fieldErrors["confirmPassword"] = "Passwords don't match"
            hasErrors = true
        }
        
        if hasErrors {
            // Shake animation for invalid form
            withAnimation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)) {
                // Trigger shake animation
            }
            return
        }
        
        // Simulate API call
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            showSuccessAlert = true
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }
}

// MARK: - Custom TextField

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    var isOptional: Bool = false
    var errorMessage: String?
    let onEditingChanged: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                TextField(placeholder, text: $text, onEditingChanged: { _ in
                    onEditingChanged()
                })
                .keyboardType(keyboardType)
                
                if isOptional {
                    Text("Opt.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(errorMessage != nil ? Color.red : Color.clear, lineWidth: 1)
            )
            
            if let error = errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

// MARK: - Custom Secure Field

struct CustomSecureField: View {
    @Binding var text: String
    let placeholder: String
    let isSecure: Bool
    let showToggle: Bool
    let onToggle: () -> Void
    var errorMessage: String?
    let onEditingChanged: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                if isSecure {
                    SecureField(placeholder, text: $text, onCommit: {
                        onEditingChanged()
                    })
                } else {
                    TextField(placeholder, text: $text, onEditingChanged: { _ in
                        onEditingChanged()
                    })
                }
                
                if showToggle {
                    Button(action: onToggle) {
                        Image(systemName: isSecure ? "eye" : "eye.slash")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(errorMessage != nil ? Color.red : Color.clear, lineWidth: 1)
            )
            
            if let error = errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

// MARK: - Date Picker Sheet

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select Birthdate", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Birthdate")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Done") {
                    isPresented = false
                }
            )
        }
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

// MARK: - Preview

#Preview {
      SignUpView()
}
