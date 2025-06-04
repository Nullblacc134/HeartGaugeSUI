// App.swift

//@main
//struct HeartGaugeApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

// ContentView.swift
import SwiftUI
import HealthKit
import Charts

// MARK: - Main Content View
struct HomeViewUI: View {
    var body: some View {
        NavigationStack {
            HealthDashboardView()
        }
    }
}

// MARK: - Notifications View
struct Notifications: View {
    var body: some View {
        ZStack {
            // Background gradient matching the main view
            LinearGradient(
                colors: [
                    Color(red: 98/255, green: 92/255, blue: 229/255),
                    Color(red: 108/255, green: 102/255, blue: 239/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 15) {
                    // Sample notifications
                    NotificationC(
                        icon: "heart.fill",
                        iconColor: .red,
                        title: "Heart Rate Alert",
                        message: "Your heart rate has been elevated for 10 minutes",
                        time: "5 min ago"
                    )
                    
                    NotificationC(
                        icon: "figure.walk",
                        iconColor: .green,
                        title: "Step Goal Achieved",
                        message: "Congratulations! You've reached your daily step goal of 10,000 steps",
                        time: "2 hours ago"
                    )
                    
                    NotificationC(
                        icon: "gamecontroller.fill",
                        iconColor: .purple,
                        title: "Gaming Session Reminder",
                        message: "You've been gaming for 2 hours. Consider taking a break!",
                        time: "3 hours ago"
                    )
                    
                    NotificationC(
                        icon: "cloud.fill",
                        iconColor: .cyan,
                        title: "Meditation Reminder",
                        message: "Time for your daily meditation session",
                        time: "1 day ago"
                    )
                }
                .padding()
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Notification Card Component
struct NotificationC: View {
    let icon: String
    let iconColor: Color
    let title: String
    let message: String
    let time: String
    
    var body: some View {
        CardView(minHeight: 80) {
            HStack(spacing: 15) {
                // Icon
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 40, height: 40)
                    .background(iconColor.opacity(0.2))
                    .clipShape(Circle())
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(time)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Game Data Models
struct Game: Identifiable, Codable {
    let id = UUID()
    let title: String
    let playTime: String
    let imageUrl: URL?
    
    init(title: String, playTime: String, imageUrl: String? = nil) {
        self.title = title
        self.playTime = playTime
        self.imageUrl = URL(string: imageUrl ?? "")
    }
}

// MARK: - Game Data Service
class GameDataService: ObservableObject {
    static let shared = GameDataService()
    
    @Published var currentlyPlaying: Game?
    @Published var recentGames: [Game] = []
    
    private init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Sample data for demonstration
        recentGames = [
            Game(title: "The Legend of Zelda: Breath of the Wild",
                 playTime: "2.5 hours today",
                 imageUrl: "https://via.placeholder.com/80x80/4A90E2/FFFFFF?text=Zelda"),
            Game(title: "Cyberpunk 2077",
                 playTime: "1.8 hours today",
                 imageUrl: "https://via.placeholder.com/80x80/E94B3C/FFFFFF?text=CP77"),
            Game(title: "Elden Ring",
                 playTime: "3.2 hours today",
                 imageUrl: "https://via.placeholder.com/80x80/8E44AD/FFFFFF?text=ER")
        ]
        
        // Set currently playing to first game for demo
        currentlyPlaying = recentGames.first
    }
    
    func setCurrentlyPlaying(_ game: Game?) {
        currentlyPlaying = game
    }
    
    func stopPlaying() {
        currentlyPlaying = nil
    }
}

// MARK: - Cached Remote Image (Placeholder Implementation)
struct CachedRemoteImage: View {
    let url: URL?
    let placeholder: String
    
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Image(systemName: placeholder)
                .foregroundColor(.white.opacity(0.6))
                .font(.title2)
        }
        .clipped()
    }
}

// MARK: - HealthKit Manager
class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    private var heartRateQuery: HKAnchoredObjectQuery?
    private var heartRateAnchor: HKQueryAnchor?
    
    @Published var currentHeartRate: Double?
    @Published var heartRateTimestamp: Date?
    @Published var steps: Double?
    @Published var meditationMinutes: Double?
    @Published var lastMeditationSession: Date?
    @Published var weeklyMeditationStreak: Int = 0
    @Published var heartRateSamples: [HKQuantitySample] = []
    @Published var isAuthorized: Bool = false
    
    private init() {}
    
    // MARK: - Authorization
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }
        
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        ]
        
        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
            DispatchQueue.main.async {
                self.isAuthorized = success
                completion(success, error)
            }
        }
    }
    
    // MARK: - Step Count
    func fetchStepCount() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            DispatchQueue.main.async {
                if let result = result, let sum = result.sumQuantity() {
                    self.steps = sum.doubleValue(for: HKUnit.count())
                } else {
                    // Provide sample data if no real data available
                    self.steps = Double.random(in: 2000...12000)
                }
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - Meditation/Mindfulness Data
    func fetchMeditationData() {
        guard let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else { return }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())
        
        let query = HKSampleQuery(sampleType: mindfulType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
            DispatchQueue.main.async {
                if let samples = results as? [HKCategorySample], !samples.isEmpty {
                    // Calculate total meditation minutes for today
                    let totalMinutes = samples.reduce(0.0) { total, sample in
                        total + sample.endDate.timeIntervalSince(sample.startDate) / 60.0
                    }
                    self.meditationMinutes = totalMinutes
                    self.lastMeditationSession = samples.last?.endDate
                } else {
                    // Provide sample data if no real data available
                    self.generateSampleMeditationData()
                }
                
                // Fetch weekly streak
                self.fetchWeeklyMeditationStreak()
            }
        }
        healthStore.execute(query)
    }
    
    private func generateSampleMeditationData() {
        // Generate realistic sample data
        let todayMinutes = Double.random(in: 5...45)
        self.meditationMinutes = todayMinutes
        self.lastMeditationSession = Date().addingTimeInterval(-Double.random(in: 3600...21600)) // 1-6 hours ago
    }
    
    private func fetchWeeklyMeditationStreak() {
        guard let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else { return }
        
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: startOfWeek, end: Date())
        
        let query = HKSampleQuery(sampleType: mindfulType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
            DispatchQueue.main.async {
                if let samples = results as? [HKCategorySample] {
                    // Count unique days with meditation sessions
                    let uniqueDays = Set(samples.map { calendar.startOfDay(for: $0.startDate) })
                    self.weeklyMeditationStreak = uniqueDays.count
                } else {
                    // Sample data
                    self.weeklyMeditationStreak = Int.random(in: 2...7)
                }
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - Heart Rate Samples (Last 24 Hours)
    func fetchHeartRateSamples() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        let startDate = Calendar.current.date(byAdding: .hour, value: -24, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, results, error in
            DispatchQueue.main.async {
                if let quantitySamples = results as? [HKQuantitySample], !quantitySamples.isEmpty {
                    self.heartRateSamples = quantitySamples
                } else {
                    // Generate sample data for demo purposes
                    self.generateSampleHeartRateData()
                }
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - Generate Sample Data for Demo
    private func generateSampleHeartRateData() {
        var samples: [HeartRateDataPoint] = []
        let now = Date()
        
        for i in 0..<24 {
            let time = now.addingTimeInterval(-Double(i) * 3600) // Every hour for 24 hours
            let baseRate = 70.0
            let variation = Double.random(in: -15...25)
            let heartRate = max(50, min(120, baseRate + variation))
            
            samples.append(HeartRateDataPoint(date: time, heartRate: heartRate))
        }
        
        self.sampleHeartRateData = samples.reversed()
        
        // Set current heart rate to the most recent sample
        if let latest = samples.first {
            self.currentHeartRate = latest.heartRate
            self.heartRateTimestamp = latest.date
        }
    }
    
    @Published var sampleHeartRateData: [HeartRateDataPoint] = []
    
    // MARK: - Most Recent Heart Rate Sample
    func fetchLatestHeartRateSample() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
            DispatchQueue.main.async {
                if let sample = results?.first as? HKQuantitySample {
                    let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                    self.currentHeartRate = bpm
                    self.heartRateTimestamp = sample.startDate
                } else {
                    // Provide sample data
                    self.currentHeartRate = Double.random(in: 60...100)
                    self.heartRateTimestamp = Date()
                }
            }
        }
        healthStore.execute(query)
    }
    
    func fetchAllData() {
        fetchStepCount()
        fetchMeditationData()
        fetchHeartRateSamples()
        fetchLatestHeartRateSample()
    }
}

// MARK: - Sample Data Structure
struct HeartRateDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let heartRate: Double
}

// MARK: - Main Dashboard View
struct HealthDashboardView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width
    
    @StateObject private var healthKitManager = HealthKitManager.shared
    @StateObject private var gameDataService = GameDataService.shared
    @State private var authorizationStatus: String = "Requesting authorization..."
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 98/255, green: 92/255, blue: 229/255),
                        Color(red: 108/255, green: 102/255, blue: 239/255)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: getSpacing()) {
                        // Header
                        HStack {
                            VStack(alignment: .leading) {
                                Text("HeartGauge")
                                    .font(.system(size: isCompact() ? 32 : 38, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text("Health & Gaming Dashboard")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 15) {
                                NavigationLink(destination: NotificationsView()) {
                                    Image(systemName: "bell.fill")
                                        .font(isCompact() ? .title3 : .title2)
                                        .foregroundColor(.white)
                                        .background(
                                            Circle()
                                                .fill(.white.opacity(0.2))
                                                .frame(width: 40, height: 40)
                                        )
                                }
                                
                                Button(action: {
                                    healthKitManager.fetchAllData()
                                }) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(isCompact() ? .title3 : .title2)
                                        .foregroundColor(.white)
                                        .background(
                                            Circle()
                                                .fill(.white.opacity(0.2))
                                                .frame(width: 40, height: 40)
                                        )
                                }
                            }
                        }
                        .padding(.bottom, 10)
                        
                        // Cards Layout
                        if isLandscapeOnIpad(geometry) {
                            HStack(alignment: .top, spacing: 15) {
                                VStack(spacing: 15) {
                                    heartbeatCard
                                    currentlyPlayingCard
                                    stepsCard
                                }
                                .frame(width: geometry.size.width * 0.48)
                                
                                VStack(spacing: 15) {
                                    meditationCard
                                    heartRateChartCard
                                }
                                .frame(width: geometry.size.width * 0.48)
                            }
                        } else {
                            heartbeatCard
                            currentlyPlayingCard
                            
                            HStack(spacing: 15) {
                                stepsCard
                                meditationCard
                            }
                            
                            heartRateChartCard
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(isCompact() ? 16 : 20)
                }
            }
        }
        .onAppear {
            requestHealthKitAuthorization()
        }
    }
    
    private func requestHealthKitAuthorization() {
        healthKitManager.requestAuthorization { success, error in
            DispatchQueue.main.async {
                if success {
                    self.authorizationStatus = "Authorized"
                    self.healthKitManager.fetchAllData()
                } else {
                    self.authorizationStatus = "Demo Mode"
                    // Still fetch sample data for demo
                    self.healthKitManager.fetchAllData()
                }
            }
        }
    }
    // Helper functions
    private func isCompact() -> Bool {
        return horizontalSizeClass == .compact || screenWidth < 390
    }
    
    private func getSpacing() -> CGFloat {
        return isCompact() ? 15 : 20
    }
    
    private func isLandscapeOnIpad(_ geometry: GeometryProxy) -> Bool {
        return horizontalSizeClass == .regular && geometry.size.width > geometry.size.height
    }
    
    // MARK: - Cards
    private var currentlyPlayingCard: some View {
         CardView(minHeight: 120) {
             VStack(alignment: .leading, spacing: 12) {
                 HStack {
                     Image(systemName: "gamecontroller.fill")
                         .foregroundColor(.purple)
                         .font(.title2)
                     
                     Text("Currently Playing")
                         .font(.headline)
                         .fontWeight(.bold)
                         .foregroundColor(.white)
                     
                     Spacer()
                     
                     Button(action: {
                         if gameDataService.currentlyPlaying != nil {
                             gameDataService.stopPlaying()
                         } else if let firstGame = gameDataService.recentGames.first {
                             gameDataService.setCurrentlyPlaying(firstGame)
                         }
                     }) {
                         Image(systemName: gameDataService.currentlyPlaying != nil ? "stop.fill" : "play.fill")
                             .font(.caption)
                             .foregroundColor(.white)
                             .frame(width: 24, height: 24)
                             .background(Circle().fill(.white.opacity(0.2)))
                     }
                 }
                 
                 if let game = gameDataService.currentlyPlaying {
                     HStack {
                         CachedRemoteImage(url: game.imageUrl, placeholder: "gamecontroller")
                             .frame(width: isCompact() ? 50 : 60, height: isCompact() ? 50 : 60)
                             .background(Color.white.opacity(0.2))
                             .cornerRadius(10)
                         
                         VStack(alignment: .leading, spacing: 4) {
                             Text(game.title)
                                 .font(isCompact() ? .body : .title3)
                                 .fontWeight(.semibold)
                                 .foregroundColor(.white)
                                 .lineLimit(2)
                             Text(game.playTime)
                                 .font(.subheadline)
                                 .foregroundColor(.white.opacity(0.7))
                         }
                         
                         Spacer()
                     }
                 } else {
                     HStack {
                         Image(systemName: "gamecontroller")
                             .font(.title)
                             .foregroundColor(.white.opacity(0.4))
                             .frame(width: isCompact() ? 50 : 60, height: isCompact() ? 50 : 60)
                             .background(Color.white.opacity(0.1))
                             .cornerRadius(10)
                         
                         VStack(alignment: .leading) {
                             Text("No game currently playing")
                                 .foregroundColor(.white.opacity(0.7))
                                 .font(.subheadline)
                             Text("Tap play to start gaming")
                                 .foregroundColor(.white.opacity(0.5))
                                 .font(.caption)
                         }
                         
                         Spacer()
                     }
                 }
             }
             .padding()
         }
     }
     
    private var heartbeatCard: some View {
        CardView(minHeight: 200) {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                    
                    Text("Heart Rate")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if let timestamp = healthKitManager.heartRateTimestamp {
                        Text(timestamp.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        if let heartRate = healthKitManager.currentHeartRate {
                            HStack(alignment: .bottom, spacing: 4) {
                                Text("\(Int(heartRate))")
                                    .font(.system(size: isCompact() ? 36 : 42, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text("BPM")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.bottom, 4)
                            }
                            
                            Text(getHeartRateStatus(heartRate))
                                .font(.subheadline)
                                .foregroundColor(getHeartRateColor(heartRate))
                                .fontWeight(.medium)
                        } else {
                            Text("--")
                                .font(.system(size: isCompact() ? 36 : 42, weight: .bold))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    
                    Spacer()
                }
                
                HeartbeatView(heartRate: healthKitManager.currentHeartRate)
                    .frame(height: 60)
                    .padding(.top, 5)
            }
            .padding()
        }
    }
    
    private var stepsCard: some View {
        CardView(minHeight: 140) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "figure.walk")
                        .foregroundColor(.green)
                        .font(.title2)
                    
                    Text("Steps")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                if let steps = healthKitManager.steps {
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("\(Int(steps).formatted())")
                            .font(.system(size: isCompact() ? 24 : 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("steps")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.bottom, 2)
                    }
                    
                    let progress = min(steps / 10000, 1.0)
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                        .scaleEffect(y: 2)
                    
                    Text("\(Int(progress * 100))% of daily goal")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                } else {
                    Text("Loading...")
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding()
        }
    }
    
    private var meditationCard: some View {
        CardView(minHeight: 140) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "cloud.fill")
                        .foregroundColor(.cyan)
                        .font(.title2)
                    
                    Text("Meditation")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                if let minutes = healthKitManager.meditationMinutes {
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("\(Int(minutes))")
                            .font(.system(size: isCompact() ? 24 : 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("min")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.bottom, 2)
                    }
                    
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.cyan)
                            .font(.caption)
                        
                        Text("\(healthKitManager.weeklyMeditationStreak) day streak")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    if let lastSession = healthKitManager.lastMeditationSession {
                        Text("Last session: \(lastSession.formatted(date: .omitted, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                } else {
                    Text("Loading...")
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding()
        }
    }
    
    private var heartRateChartCard: some View {
        CardView(minHeight: 280) {
            VStack(alignment: .leading, spacing: 15) {
                Text("Heart Rate Trend (24h)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                if !healthKitManager.sampleHeartRateData.isEmpty {
                    Chart(healthKitManager.sampleHeartRateData) { dataPoint in
                        LineMark(
                            x: .value("Time", dataPoint.date),
                            y: .value("BPM", dataPoint.heartRate)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.red)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                        
                        AreaMark(
                            x: .value("Time", dataPoint.date),
                            y: .value("BPM", dataPoint.heartRate)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.red.opacity(0.3), .red.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                    .frame(height: 180)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .hour, count: 6)) {
                            AxisValueLabel(format: .dateTime.hour())
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .chartYAxis {
                        AxisMarks {
                            AxisValueLabel()
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.5))
                        Text("Loading heart rate data...")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
    }
    
    // Helper functions for heart rate status
    private func getHeartRateStatus(_ heartRate: Double) -> String {
        switch heartRate {
        case 0..<60: return "Low"
        case 60...100: return "Normal"
        case 100...120: return "Elevated"
        default: return "High"
        }
    }
    
    private func getHeartRateColor(_ heartRate: Double) -> Color {
        switch heartRate {
        case 0..<60: return .blue
        case 60...100: return .green
        case 100...120: return .yellow
        default: return .red
        }
    }
}

// MARK: - Supporting Components

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
            .shadow(color: .black.opacity(0.15), radius: shadowRadius, x: 0, y: 4)
            .frame(minHeight: minHeight)
            .frame(maxWidth: .infinity)
    }
}
struct HeartbeatView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    let heartRate: Double?
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let midY = height / 2
                
                path.move(to: CGPoint(x: 0, y: midY))
                
                let basePatternWidth: CGFloat = isCompact() ? 80 : 100
                let hrMultiplier = heartRate != nil ? max(0.6, min(1.8, (heartRate! / 80.0))) : 1.0
                let patternWidth = basePatternWidth / hrMultiplier
                
                let patterns = max(1, Int(width / patternWidth) + 1)
                
                for i in 0..<patterns {
                    let startX = (width / CGFloat(patterns-1) * CGFloat(i)) + animationOffset
                    let scale = isCompact() ? 0.7 : 0.9
                    let amplitude = heartRate != nil ? max(0.4, min(1.2, (heartRate! / 85.0))) : 0.8
                    
                    if startX > -patternWidth && startX < width + patternWidth {
                        // Flat line
                        path.addLine(to: CGPoint(x: startX + 15 * scale, y: midY))
                        
                        // P wave
                        path.addLine(to: CGPoint(x: startX + 20 * scale, y: midY - 3 * scale * amplitude))
                        path.addLine(to: CGPoint(x: startX + 25 * scale, y: midY))
                        
                        // QRS complex
                        path.addLine(to: CGPoint(x: startX + 30 * scale, y: midY + 5 * scale * amplitude))
                        path.addLine(to: CGPoint(x: startX + 35 * scale, y: midY - 25 * scale * amplitude)) // R peak
                        path.addLine(to: CGPoint(x: startX + 40 * scale, y: midY + 10 * scale * amplitude))
                        path.addLine(to: CGPoint(x: startX + 45 * scale, y: midY))
                        
                        // T wave
                        path.addLine(to: CGPoint(x: startX + 55 * scale, y: midY + 8 * scale * amplitude))
                        path.addLine(to: CGPoint(x: startX + 65 * scale, y: midY))
                    }
                }
            }
            .stroke(
                LinearGradient(
                    colors: [.red, .red.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: isCompact() ? 2.0 : 2.5
            )
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        let speed = heartRate != nil ? max(2.0, min(4.0, heartRate! / 30.0)) : 3.0
        
        withAnimation(Animation.linear(duration: speed).repeatForever(autoreverses: false)) {
            animationOffset = -(isCompact() ? 80 : 100)
        }
    }
    
    private func isCompact() -> Bool {
        return horizontalSizeClass == .compact
    }
}

// MARK: - Preview
#Preview {
    HomeViewUI()
}
