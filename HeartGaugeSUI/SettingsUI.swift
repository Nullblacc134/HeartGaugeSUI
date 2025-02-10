//
//  SettingsUI.swift
//  HeartGaugeSUI
//
//  Created by Kenny Mayancela Aylla on 1/28/25.
//

import SwiftUI

struct Settings: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background color
            Color(red: 0.4, green: 0.4, blue: 0.9)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Header with back button
                HStack {
                    Text("Settings")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.leading, 8)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                // Settings options
                VStack(spacing: 15) {
                    SettingsButton(title: "Security") {
                        // Add security action
                    }
                    
                    SettingsButton(title: "Notifications") {
                        // Add notifications action
                    }
                    
                    SettingsButton(title: "Display") {
                        // Add display action
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

struct SettingsButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.red.opacity(0.7))
            )
        }
    }
}

// Example of how to use in HomeView
struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                // Other content
                
                NavigationLink(destination: SettingsView()) {
                    Text("Settings")
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
    }
}

#Preview {
    Settings()
}
