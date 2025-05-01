//
//  HomeView.swift
//  HeartGaugeSUI
//
//  Created by Kenny Mayancela Aylla on 1/16/25.
//

import SwiftUI

struct HomeViewUI: View {
    let username: String // Receive the username

    let signOut: () -> Void // Closure to handle sign-out

    var body: some View {
            ZStack {
                // Background
                Color(red: 0.4, green: 0.4, blue: 0.9)
                    .ignoresSafeArea()
                Button("Sign Out") {

                    signOut()

                }
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        Text("Dashboard").font(Font.custom("Jomhuria-Regular", size: 55))
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Image(systemName: "bell")
                            .font(.title2)
                        
                        Image(systemName: "gearshape")
                            .font(.title2)
                            .padding(.leading, 10)
                    }
                    
                    // Heartbeat Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Current Heartbeat")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("180 BPM")
                            .font(.title)
                        
                        // Heartbeat Graph
                        HeartbeatView()
                            .frame(height: 100)
                            .foregroundColor(.red)
                    }
                    
                    Divider()
                        .background(Color.black)
                    
                    // Currently Playing Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Currently Playing:")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            Image("roblox")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .cornerRadius(8)
                            
                            VStack(alignment: .leading) {
                                Text("Roblox")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Text("1:30:09")
                                    .font(.subheadline)
                            }
                        }
                    }
                    
                    // Recently Played Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recently played:")
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            GameRow(imageName: "lol", title: "League of Legends")
                            GameRow(imageName: "minecraft", title: "Minecraft")
                            GameRow(imageName: "dbd", title: "Dead by Daylight")
                            GameRow(imageName: "persona", title: "Persona 4 Golden")
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .font(Font.custom("Jomhuria-Regular", size: 55))
                
            }
        }
    }

    // Heartbeat Waveform View
    struct HeartbeatView: View {
        var body: some View {
            Path { path in
                let width = UIScreen.main.bounds.width - 40
                let height: CGFloat = 50
                let midY = height / 2
                
                path.move(to: CGPoint(x: 0, y: midY))
                
                // Create three heartbeat patterns
                for i in 0..<3 {
                    let startX = width / 3 * CGFloat(i)
                    
                    path.addLine(to: CGPoint(x: startX + 10, y: midY))
                    path.addLine(to: CGPoint(x: startX + 15, y: midY - 20))
                    path.addLine(to: CGPoint(x: startX + 20, y: midY + 20))
                    path.addLine(to: CGPoint(x: startX + 25, y: midY - 10))
                    path.addLine(to: CGPoint(x: startX + 30, y: midY))
                }
            }
            .stroke(Color.red, lineWidth: 2)
        }
    }

    // Game Row Component
    struct GameRow: View {
        let imageName: String
        let title: String
        
        var body: some View {
            HStack {
                Image(imageName)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(8)
                
                Text(title)
                    .font(.body)
            }
        }
    }

//#Preview {
//    HomeViewUI()
//}
