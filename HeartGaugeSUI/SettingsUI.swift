import SwiftUI

struct SettingsUI: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @State private var notificationsEnabled = true
    @State private var biometricEnabled = true
    @State private var locationEnabled = true
    @State private var autoBackupEnabled = false
    @State private var showingProfile = false

    var body: some View {
        ZStack {
            Color(red: 0.4, green: 0.4, blue: 0.9)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding(8)
                    }

                    Text("Settings")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 20)

                ScrollView {
                    VStack(spacing: 20) {
                        SettingsSection(title: "Account") {
                            SettingsButton(
                                title: "Profile",
                                subtitle: "Manage your account details",
                                icon: "person.circle.fill",
                                iconColor: .blue
                            ) {
                                showingProfile = true
                            }

                            SettingsButton(
                                title: "Sync & Backup",
                                subtitle: "Keep your data safe",
                                icon: "icloud.fill",
                                iconColor: .cyan,
                                showToggle: true,
                                toggleBinding: $autoBackupEnabled
                            ) {}
                        }

                        SettingsSection(title: "Privacy & Security") {
                            SettingsButton(
                                title: "Security",
                                subtitle: "Passwords & authentication",
                                icon: "lock.shield.fill",
                                iconColor: .red
                            ) {}

                            SettingsButton(
                                title: "Location Services",
                                subtitle: "Allow location access",
                                icon: "location.fill",
                                iconColor: .orange,
                                showToggle: true,
                                toggleBinding: $locationEnabled
                            ) {}
                        }

                        SettingsSection(title: "Preferences") {
                            SettingsButton(
                                title: "Notifications",
                                subtitle: "Push notifications & alerts",
                                icon: "bell.fill",
                                iconColor: .yellow,
                                showToggle: true,
                                toggleBinding: $notificationsEnabled
                            ) {}

                            SettingsButton(
                                title: "Dark Mode",
                                subtitle: "Switch to dark theme",
                                icon: "moon.fill",
                                iconColor: .black,
                                showToggle: true,
                                toggleBinding: $darkModeEnabled
                            ) {}

                            SettingsButton(
                                title: "Sound & Haptics",
                                subtitle: "Audio feedback settings",
                                icon: "speaker.wave.3.fill",
                                iconColor: .pink
                            ) {}
                        }

                        SettingsSection(title: "Support") {
                            SettingsButton(
                                title: "Help Center",
                                subtitle: "FAQs and tutorials",
                                icon: "questionmark.circle.fill",
                                iconColor: .teal
                            ) {}

                            SettingsButton(
                                title: "Contact Us",
                                subtitle: "Get support",
                                icon: "envelope.fill",
                                iconColor: .blue
                            ) {}

                            SettingsButton(
                                title: "Rate App",
                                subtitle: "Share your feedback",
                                icon: "star.fill",
                                iconColor: .yellow
                            ) {}
                        }

                        VStack(spacing: 8) {
                            Text("Version 2.1.0")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))

                            Text("Made with ❤️ in Swift")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)

                Spacer()
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingProfile) {
            ProfileView()
        }
    }
}
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.8))
                .kerning(1)

            VStack(spacing: 8) {
                content
            }
        }
    }
}
struct SettingsButton: View {
    let title: String
    var subtitle: String? = nil
    var icon: String? = nil
    var iconColor: Color = .white
    var showToggle: Bool = false
    var toggleBinding: Binding<Bool>? = nil
    let action: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            if let icon = icon {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 36, height: 36)

                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(.system(size: 18, weight: .medium))
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            Spacer()

            if showToggle, let binding = toggleBinding {
                Toggle("", isOn: binding)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                    .scaleEffect(0.8)
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
        )
        .onTapGesture {
            if !showToggle {
                action()
            }
        }
    }
}
#Preview {
    SettingsUI()
}
