//
//  RecentlyPlayed.swift
//  HeartGaugeSUI
//
//  Created by Kenny Mayancela Aylla on 1/27/25.
//

import SwiftUI

// Model for game log data
struct GameLog {
    let gameName: String
    let imageName: String
    let time: String
    let maxHeartRate: Int
    let minHeartRate: Int
}

struct RecentlyPlayedUI: View {
    //  data
    let gameLogs = [
        GameLog(gameName: "Roblox", imageName: "roblox", time: "3 hrs", maxHeartRate: 120, minHeartRate: 80),
        GameLog(gameName: "League of Legends", imageName: "lol", time: "1 hr", maxHeartRate: 140, minHeartRate: 100),
        GameLog(gameName: "Minecraft", imageName: "minecraft", time: "45 mins", maxHeartRate: 90, minHeartRate: 77),
        GameLog(gameName: "Dead by Daylight", imageName: "dbd", time: "1 hr 30 mins", maxHeartRate: 151, minHeartRate: 85),
        GameLog(gameName: "Persona", imageName: "persona", time: "2 hrs", maxHeartRate: 75, minHeartRate: 60)
    ]
    
    var body: some View {
        ZStack {
            // Background color
            Color(red: 0.4, green: 0.4, blue: 0.9)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Text("Gaming logs")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.leading, 8)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                // Game logs list
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(gameLogs, id: \.gameName) { log in
                            GameLogRow(log: log)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct GameLogRow: View {
    let log: GameLog
    
    var body: some View {
        HStack(spacing: 15) {
            // Game icon
            Image(log.imageName)
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(8)
                .background(Color.gray.opacity(0.3))
            
            VStack(alignment: .leading, spacing: 4) {
                // Time played
                Text("Time: \(log.time)")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                
                // Heart rate range
                HStack {
                    Text("Max HR: \(log.maxHeartRate)")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                    
                    Text("Min HR: \(log.minHeartRate)")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                }
            }
            
            Spacer()
            
            // Heart rate graph representation
            Image(systemName: "waveform.path.ecg")
                .foregroundColor(.red)
                .font(.system(size: 24))
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    RecentlyPlayedUI()
}
