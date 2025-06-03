import SwiftUI

struct GamingLog {
    let id = UUID()
    let gameName: String
    let gameImage: String
    let duration: String
    let maxHR: Int
    let minHR: Int
    let intensity: String
    let color: Color
    let genre: String
}

struct RecentlyPlayedUI: View {
    let gamingLogs = [
        GamingLog(gameName: "Call of Duty", gameImage: "gamecontroller.fill", duration: "3 hrs", maxHR: 120, minHR: 80, intensity: "Moderate", color: .green, genre: "FPS"),
        GamingLog(gameName: "Fortnite", gameImage: "target", duration: "1 hr", maxHR: 140, minHR: 100, intensity: "High", color: .orange, genre: "Battle Royale"),
        GamingLog(gameName: "Minecraft", gameImage: "cube.fill", duration: "45 mins", maxHR: 90, minHR: 77, intensity: "Low", color: .blue, genre: "Sandbox"),
        GamingLog(gameName: "Apex Legends", gameImage: "bolt.fill", duration: "1 hr 30 mins", maxHR: 151, minHR: 85, intensity: "Intense", color: .red, genre: "Battle Royale"),
        GamingLog(gameName: "Animal Crossing", gameImage: "leaf.fill", duration: "2 hrs", maxHR: 75, minHR: 60, intensity: "Calm", color: .mint, genre: "Simulation")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated gradient background
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.2, green: 0.1, blue: 0.3),
                        Color(red: 0.1, green: 0.2, blue: 0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        // Header Stats Card
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Gaming Sessions")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("Today's Activity")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                Spacer()
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.title2)
                                    .foregroundColor(.cyan)
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.2))
                            
                            HStack(spacing: 30) {
                                VStack(spacing: 4) {
                                    Text("5")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("Total Sessions")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                VStack(spacing: 4) {
                                    Text("8h 15m")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("Total Time")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                VStack(spacing: 4) {
                                    Text("95")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("Avg HR")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color.cyan.opacity(0.5), Color.purple.opacity(0.5)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .padding(.horizontal)
                        
                        // Gaming Log Cards
                        ForEach(Array(gamingLogs.enumerated()), id: \.element.id) { index, log in
                            GamingLogCard(log: log, index: index)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Gaming Logs")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .preferredColorScheme(.dark)
        }
    }
}

struct GamingLogCard: View {
    let log: GamingLog
    let index: Int
    @State private var isAnimated = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Handle game selection
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            HStack(spacing: 16) {
                // Game Image and Info
                VStack(spacing: 12) {
                    ZStack {
                        // Game icon background
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [log.color.opacity(0.3), log.color.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(log.color.opacity(0.5), lineWidth: 1)
                            )
                        
                        // Game icon
                        Image(systemName: log.gameImage)
                            .font(.title2)
                            .foregroundColor(log.color)
                            .scaleEffect(isAnimated ? 1.1 : 1.0)
                            .animation(
                                Animation.easeInOut(duration: 0.8)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                value: isAnimated
                            )
                    }
                    
                    // Genre badge
                    Text(log.genre)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(log.color.opacity(0.2))
                        .foregroundColor(log.color)
                        .clipShape(Capsule())
                }
                
                // Game and session details
                VStack(alignment: .leading, spacing: 12) {
                    // Game name and duration
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(log.gameName)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                Text(log.duration)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        
                        HStack(spacing: 4) {
                            Text("Intensity:")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            Text(log.intensity)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(log.color)
                        }
                    }
                    
                    // Heart rate data
                    VStack(spacing: 8) {
                        HStack(spacing: 20) {
                            HStack(spacing: 4) {
                                Image(systemName: "heart.fill")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Max: \(log.maxHR)")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    Text("Min: \(log.minHR)")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Avg: \((log.maxHR + log.minHR) / 2)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Text("BPM")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        
                        // Heart rate range visualization
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background bar
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 6)
                                
                                // Progress bar
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(
                                        LinearGradient(
                                            colors: [log.color.opacity(0.6), log.color],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: isAnimated ? geometry.size.width * CGFloat(log.maxHR - log.minHR) / 100.0 : 0,
                                        height: 6
                                    )
                                    .animation(.easeInOut(duration: 1.2).delay(Double(index) * 0.15), value: isAnimated)
                            }
                        }
                        .frame(height: 6)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.2),
                                        log.color.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: log.color.opacity(0.2), radius: 8, x: 0, y: 4)
            )
            .scaleEffect(isPressed ? 0.98 : (isAnimated ? 1.0 : 0.9))
            .opacity(isAnimated ? 1.0 : 0.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(Double(index) * 0.1)) {
                isAnimated = true
            }
        }
    }
}

#Preview {
    RecentlyPlayedUI()
}
