import SwiftUI
import HealthKit
import Charts

// MARK: - HealthKit Manager

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    private var heartRateQuery: HKAnchoredObjectQuery?
    private var heartRateAnchor: HKQueryAnchor?
    
    @Published var currentHeartRate: Double?
    @Published var heartRateTimestamp: Date?
    @Published var steps: Double?
    @Published var activeEnergy: Double?
    @Published var heartRateSamples: [HKQuantitySample] = []
    
    // MARK: - Authorization
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }
        
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]
        
        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
            completion(success, error)
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
                }
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - Active Energy
    func fetchActiveEnergyBurned() {
        guard let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date())
        
        let query = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            DispatchQueue.main.async {
                if let result = result, let sum = result.sumQuantity() {
                    self.activeEnergy = sum.doubleValue(for: HKUnit.kilocalorie())
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
                if let quantitySamples = results as? [HKQuantitySample] {
                    self.heartRateSamples = quantitySamples
                }
            }
        }
        healthStore.execute(query)
    }
    
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
                }
            }
        }
        healthStore.execute(query)
    }
    
    // MARK: - Live Heart Rate Updates
    func startLiveHeartRateUpdates() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        let predicate = HKQuery.predicateForSamples(withStart: Date().addingTimeInterval(-3600), end: nil)
        
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: predicate, anchor: heartRateAnchor, limit: HKObjectQueryNoLimit) { _, samples, _, newAnchor, _ in
            self.handleHeartRateSamples(samples, anchor: newAnchor)
        }
        
        query.updateHandler = { _, samples, _, newAnchor, _ in
            self.handleHeartRateSamples(samples, anchor: newAnchor)
        }
        
        heartRateQuery = query
        healthStore.execute(query)
    }
    
    private func handleHeartRateSamples(_ samples: [HKSample]?, anchor: HKQueryAnchor?) {
        guard let samples = samples as? [HKQuantitySample] else { return }
        
        DispatchQueue.main.async {
            for sample in samples {
                let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                let date = sample.startDate
                self.currentHeartRate = bpm
                self.heartRateTimestamp = date
                
                // Add to samples array for chart
                if !self.heartRateSamples.contains(where: { $0.startDate == sample.startDate }) {
                    self.heartRateSamples.append(sample)
                    // Keep only last 100 samples for performance
                    if self.heartRateSamples.count > 100 {
                        self.heartRateSamples = Array(self.heartRateSamples.suffix(100))
                    }
                }
            }
        }
        
        self.heartRateAnchor = anchor
    }
    
    func fetchAllData() {
        fetchStepCount()
        fetchActiveEnergyBurned()
        fetchHeartRateSamples()
        fetchLatestHeartRateSample()
        startLiveHeartRateUpdates()
    }
}

// MARK: - Main Dashboard View

struct HealthDashboardView: View {
    // Screen size detection for adaptive layout
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    // For device rotation and size changes
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width
    
    // HealthKit manager
    @StateObject private var healthKitManager = HealthKitManager.shared
    @State private var authorizationStatus: String = "Requesting authorization..."
    
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
                            Text("HeartGauge")
                                .font(Font.custom("Jomhuria-Regular", size: isCompact() ? 45 : 55))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Image(systemName: "bell.fill")
                                    .font(isCompact() ? .title3 : .title2)
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: {
                                healthKitManager.fetchAllData()
                            }) {
                                Image(systemName: "arrow.clockwise")
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
                                    stepsCard
                                }
                                .frame(width: geometry.size.width * 0.5)
                                
                                // Right column
                                VStack(spacing: 15) {
                                    activeEnergyCard
                                    heartRateChartCard
                                }
                                .frame(width: geometry.size.width * 0.5 - 15)
                            }
                        } else {
                            // Standard vertical layout
                            heartbeatCard
                            stepsCard
                            activeEnergyCard
                            heartRateChartCard
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
                    self.authorizationStatus = "Authorization failed: \(error?.localizedDescription ?? "Unknown error")"
                }
            }
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
        CardView(minHeight: 180) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                    
                    Text("Current Heart Rate")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                HStack {
                    if let heartRate = healthKitManager.currentHeartRate {
                        Text("\(Int(heartRate)) BPM")
                            .font(isCompact() ? .title2 : .title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    } else {
                        Text("-- BPM")
                            .font(isCompact() ? .title2 : .title)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    if let timestamp = healthKitManager.heartRateTimestamp {
                        Text("Last: \(timestamp.formatted(date: .omitted, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        Text("Waiting for data...")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                // Custom Heartbeat Graph using real data
                HeartbeatView(heartRate: healthKitManager.currentHeartRate)
                    .frame(height: 90)
                    .padding(.top, 5)
            }
            .padding()
        }
    }
    
    private var stepsCard: some View {
        CardView(minHeight: 120) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "figure.walk")
                        .foregroundColor(.green)
                        .font(.title2)
                    
                    Text("Steps Today")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                HStack {
                    if let steps = healthKitManager.steps {
                        Text("\(Int(steps))")
                            .font(isCompact() ? .title2 : .title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("steps")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        Text("Loading...")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Progress indicator (assuming 10,000 step goal)
                    if let steps = healthKitManager.steps {
                        let progress = min(steps / 10000, 1.0)
                        CircularProgressView(progress: progress)
                            .frame(width: 40, height: 40)
                    }
                }
            }
            .padding()
        }
    }
    
    private var activeEnergyCard: some View {
        CardView(minHeight: 120) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                    
                    Text("Active Energy")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                HStack {
                    if let energy = healthKitManager.activeEnergy {
                        Text("\(Int(energy))")
                            .font(isCompact() ? .title2 : .title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("kcal")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        Text("Loading...")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text("Today")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding()
        }
    }
    
    private var heartRateChartCard: some View {
        CardView(minHeight: 250) {
            VStack(alignment: .leading, spacing: 15) {
                Text("Heart Rate (24h)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if !healthKitManager.heartRateSamples.isEmpty {
                    Chart(healthKitManager.heartRateSamples, id: \.startDate) { sample in
                        LineMark(
                            x: .value("Time", sample.startDate),
                            y: .value("BPM", sample.quantity.doubleValue(for: HKUnit(from: "count/min")))
                        )
                        .interpolationMethod(.monotone)
                        .foregroundStyle(.red)
                    }
                    .frame(height: 150)
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
                    VStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.5))
                        Text("Loading heart rate data...")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
    }
}

// MARK: - Supporting Components

// Circular Progress View
struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 3)
                .opacity(0.3)
                .foregroundColor(.white)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .foregroundColor(.white)
                .rotationEffect(Angle(degrees: 270.0))
            
            Text("\(Int(progress * 100))%")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
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

// Enhanced Heartbeat View Component
struct HeartbeatView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    let heartRate: Double?
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let midY = height / 2
                
                path.move(to: CGPoint(x: 0, y: midY))
                
                // Calculate pattern based on heart rate (higher HR = more frequent patterns)
                let basePatternWidth: CGFloat = isCompact() ? 60 : 80
                let hrMultiplier = heartRate != nil ? max(0.5, min(2.0, (heartRate! / 100.0))) : 1.0
                let patternWidth = basePatternWidth / hrMultiplier
                
                let patterns = max(1, Int(width / patternWidth))
                
                // Create a more natural-looking heartbeat pattern
                for i in 0..<patterns {
                    let startX = width / CGFloat(patterns) * CGFloat(i)
                    let scale = isCompact() ? 0.8 : 1.0
                    let amplitude = heartRate != nil ? max(0.5, min(1.5, (heartRate! / 80.0))) : 1.0
                    
                    // Flat line
                    path.addLine(to: CGPoint(x: startX + 10 * scale, y: midY))
                    
                    // P wave
                    path.addLine(to: CGPoint(x: startX + 15 * scale, y: midY - 5 * scale * amplitude))
                    path.addLine(to: CGPoint(x: startX + 20 * scale, y: midY))
                    
                    // QRS complex
                    path.addLine(to: CGPoint(x: startX + 25 * scale, y: midY - 5 * scale * amplitude))
                    path.addLine(to: CGPoint(x: startX + 30 * scale, y: midY + 30 * scale * amplitude)) // R peak
                    path.addLine(to: CGPoint(x: startX + 35 * scale, y: midY - 15 * scale * amplitude))
                    path.addLine(to: CGPoint(x: startX + 40 * scale, y: midY))
                    
                    // T wave
                    path.addLine(to: CGPoint(x: startX + 50 * scale, y: midY + 10 * scale * amplitude))
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

// Main Content View
struct ContentView: View {
    var body: some View {
        NavigationStack {
            HealthDashboardView()
                .navigationBarHidden(true)
        }
    }
}

// Preview
#Preview {
    ContentView()
}
