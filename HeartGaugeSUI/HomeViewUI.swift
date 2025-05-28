
import SwiftUI

// MARK: - Game Model and Data Service

struct Game: Identifiable {
    let id = UUID()
    let title: String
    let playTime: String
    let imageUrl: String
}

class GameDataService: ObservableObject {
    @Published var currentlyPlaying: Game?
    @Published var recentlyPlayed: [Game] = []
    private var imageBaseUrl: String = "https://yourapi.com/images/"
    
    init() {
        // Initialize with sample data
        loadSampleData()
    }
    
    func updateImageBaseUrl(newBaseUrl: String) {
        self.imageBaseUrl = newBaseUrl
    }
    
    private func loadSampleData() {
        // Sample current game
        currentlyPlaying = Game(
            title: "Cyberpunk 2077",
            playTime: "2 hours played today",
            imageUrl: "\(imageBaseUrl)cyberpunk.jpg"
        )
        
        // Sample recently played games
        recentlyPlayed = [
            Game(
                title: "Elden Ring",
                playTime: "Last played yesterday",
                imageUrl: "\(imageBaseUrl)elden-ring.jpg"
            ),
            Game(
                title: "The Witcher 3",
                playTime: "Last played 3 days ago",
                imageUrl: "\(imageBaseUrl)witcher3.jpg"
            ),
            Game(
                title: "Red Dead Redemption 2",
                playTime: "Last played 1 week ago",
                imageUrl: "\(imageBaseUrl)rdr2.jpg"
            )
        ]
    }
}

// MARK: - CachedRemoteImage Component

struct CachedRemoteImage: View {
    let url: String
    var placeholder: String = "photo"
    
    var body: some View {
        // This is a simplified version for demonstration
        // In a real app, you'd implement proper image caching and error handling
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                Image(systemName: placeholder)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white.opacity(0.5))
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure:
                Image(systemName: "exclamationmark.triangle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white.opacity(0.5))
            @unknown default:
                Image(systemName: placeholder)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
}

// MARK: - Main View

struct HomeViewUI: View {
    // Screen size detection for adaptive layout
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    // For device rotation and size changes
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width
    
    // Game data service
    @StateObject private var gameDataService = GameDataService()
    
    // API configuration
    private let imageBaseUrl = "https://yourapi.com/images/" // Change this to your actual image hosting URL
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background with improved color
                Color(red: 98/255, green: 92/255, blue: 229/255)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: getSpacing()) {
                        // Header
                        HStack {
                            Text("Dashboard")
                                .font(Font.custom("Jomhuria-Regular", size: isCompact() ? 45 : 55))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Image(systemName: "bell.fill")
                                    .font(isCompact() ? .title3 : .title2)
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "gearshape.fill")
                                    .font(isCompact() ? .title3 : .title2)
                                    .foregroundColor(.white)
                                    .padding(.leading, isCompact() ? 5 : 10)
                            }
                        }
                        .padding(.bottom, 5)
                        
                        // Adapt layout based on orientation and size
                        if isLandscapeOnIpad(geometry) {
                            HStack(alignment: .top, spacing: 15) {
                                // Left column
                                VStack(spacing: 15) {
                                    heartbeatCard
                                    currentlyPlayingCard
                                }
                                .frame(width: geometry.size.width * 0.5)
                                
                                // Right column
                                recentlyPlayedCard
                                    .frame(width: geometry.size.width * 0.5 - 15)
                            }
                        } else {
                            // Standard vertical layout
                            heartbeatCard
                            currentlyPlayingCard
                            recentlyPlayedCard
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(isCompact() ? 15 : 20)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                    self.screenWidth = UIScreen.main.bounds.width
                }
            }
        }
        .onAppear {
            // If needed, you could update the base URL for images
            // gameDataService.updateImageBaseUrl(newBaseUrl: "https://newapi.com/images/")
        }
    }
    
    // Helper functions for responsive design
    private func isCompact() -> Bool {
        return horizontalSizeClass == .compact || screenWidth < 390
    }
    
    private func getSpacing() -> CGFloat {
        return isCompact() ? 15 : 20
    }
    
    private func isLandscapeOnIpad(_ geometry: GeometryProxy) -> Bool {
        return horizontalSizeClass == .regular &&
               geometry.size.width > geometry.size.height
    }
    
    // MARK: - Card Components
    
    private var heartbeatCard: some View {
        CardView(
            minHeight: 180
        ) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                    
                    Text("Current Heartbeat")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("180 BPM")
                        .font(isCompact() ? .title2 : .title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Last checked: 1:04 PM")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Custom Heartbeat Graph
                HeartbeatView()
                    .frame(height: 90)
                    .padding(.top, 5)
            }
            .padding()
        }
    }
    
    private var currentlyPlayingCard: some View {
        CardView(
            minHeight: 120
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Currently Playing:")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if let game = gameDataService.currentlyPlaying {
                    HStack {
                        CachedRemoteImage(url: game.imageUrl, placeholder: "download")
                            .frame(width: isCompact() ? 50 : 80, height: isCompact() ? 50 : 80)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                        
                        VStack(alignment: .leading) {
                            Text(game.title)
                                .font(isCompact() ? .body : .title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Text(game.playTime)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                    }
                } else {
                    Text("No game currently playing")
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding()
        }
    }
    
    private var recentlyPlayedCard: some View {
        CardView(
            minHeight: 250
        ) {
            VStack(alignment: .leading, spacing: 15) {
                Text("Recently played:")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: isCompact() ? 20 : 20) {
                    ForEach(gameDataService.recentlyPlayed) { game in
                        AdvancedGameRow(game: game, isCompact: isCompact())
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Supporting Components

// Advanced Game Row Component
struct AdvancedGameRow: View {
    let game: Game
    let isCompact: Bool
    
    var body: some View {
        HStack {
            CachedRemoteImage(url: game.imageUrl)
                .frame(width: isCompact ? 32 : 40, height: isCompact ? 32 : 40)
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: isCompact ? 1 : 2) {
                Text(game.title)
                    .font(isCompact ? .callout : .body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(game.playTime)
                    .font(isCompact ? .caption2 : .caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "play.fill")
                    .foregroundColor(.white)
                    .padding(isCompact ? 6 : 8)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(isCompact ? 6 : 8)
            }
        }
    }
}

// Card View Component
struct CardView<Content: View>: View {
    let content: Content
    var backgroundColor: Color = Color(red: 91/255, green: 86/255, blue: 218/255)
    var cornerRadius: CGFloat = 20
    var shadowRadius: CGFloat = 8
    var minHeight: CGFloat? = nil
    
    init(
        backgroundColor: Color = Color(red: 91/255, green: 86/255, blue: 218/255),
        cornerRadius: CGFloat = 20,
        shadowRadius: CGFloat = 8,
        minHeight: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.minHeight = minHeight
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(backgroundColor)
            .overlay(content)
            .shadow(color: .black.opacity(0.2), radius: shadowRadius, x: 0, y: 4)
            .frame(minHeight: minHeight)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// Heartbeat View Component
struct HeartbeatView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let midY = height / 2
                
                path.move(to: CGPoint(x: 0, y: midY))
                
                // Calculate number of heartbeat patterns based on width
                let patternWidth: CGFloat = isCompact() ? 60 : 80
                let patterns = max(1, Int(width / patternWidth))
                
                // Create a more natural-looking heartbeat pattern
                for i in 0..<patterns {
                    let startX = width / CGFloat(patterns) * CGFloat(i)
                    let scale = isCompact() ? 0.8 : 1.0
                    
                    // Flat line
                    path.addLine(to: CGPoint(x: startX + 10 * scale, y: midY))
                    
                    // P wave
                    path.addLine(to: CGPoint(x: startX + 15 * scale, y: midY - 5 * scale))
                    path.addLine(to: CGPoint(x: startX + 20 * scale, y: midY))
                    
                    // QRS complex
                    path.addLine(to: CGPoint(x: startX + 25 * scale, y: midY - 5 * scale))
                    path.addLine(to: CGPoint(x: startX + 30 * scale, y: midY + 30 * scale)) // R peak
                    path.addLine(to: CGPoint(x: startX + 35 * scale, y: midY - 15 * scale))
                    path.addLine(to: CGPoint(x: startX + 40 * scale, y: midY))
                    
                    // T wave
                    path.addLine(to: CGPoint(x: startX + 50 * scale, y: midY + 10 * scale))
                    path.addLine(to: CGPoint(x: startX + 60 * scale, y: midY))
                    
                    // Flat line to end
                    path.addLine(to: CGPoint(x: startX + (patternWidth - 5) * scale, y: midY))
                }
            }
            .stroke(Color.red, lineWidth: isCompact() ? 2.0 : 2.5)
        }
    }
    
    private func isCompact() -> Bool {
        return horizontalSizeClass == .compact
    }
}

// Preview
#Preview {
    HomeViewUI()
}
