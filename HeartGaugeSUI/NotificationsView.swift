import SwiftUI

struct NotificationModel: Identifiable, Hashable {
    let id = UUID()
    let type: NotificationType
    let title: String
    let subtitle: String
    let description: String
    let date: String
    var isRead: Bool
    let priority: Priority
    
    enum NotificationType {
        case reward, welcome, promotion
        
        var icon: String {
            switch self {
            case .reward: return "gift.fill"
            case .welcome: return "star.fill"
            case .promotion: return "creditcard.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .reward: return .purple
            case .welcome: return .blue
            case .promotion: return .green
            }
        }
    }
    
    enum Priority {
        case high, medium, low
        
        var color: Color {
            switch self {
            case .high: return .red
            case .medium: return .orange
            case .low: return .green
            }
        }
    }
}

struct NotificationsView: View {
    @State private var notifications: [NotificationModel] = [
        NotificationModel(
            type: .reward,
            title: "Vista Rewards Club",
            subtitle: "Earn Points without making a purchase",
            description: "Complete your first mission today!",
            date: "Dec 16, 2023",
            isRead: false,
            priority: .high
        ),
        NotificationModel(
            type: .reward,
            title: "Vista Rewards Club",
            subtitle: "Boost your points and unlock rewards",
            description: "Keep paying with Vista to boost your points and unlock rewards. It's as simple as that.",
            date: "Dec 12, 2023",
            isRead: false,
            priority: .medium
        ),
        NotificationModel(
            type: .welcome,
            title: "Vista Rewards Club",
            subtitle: "Welcome to Vista rewards!",
            description: "Now you're a member of Vista rewards club, start picking up points with every purchase.",
            date: "Dec 8, 2023",
            isRead: true,
            priority: .low
        )
    ]
    
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
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
                
                VStack(spacing: 0) {
                    // Header Section
                    VStack(spacing: 16) {
                        HStack {
                            HStack(spacing: 12) {
                                Image(systemName: "bell.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                
                                Text("Notifications")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            if unreadCount > 0 {
                                Text("\(unreadCount)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.red)
                                    .clipShape(Capsule())
                                    .scaleEffect(unreadCount > 0 ? 1.0 : 0.8)
                                    .animation(.spring(response: 0.3), value: unreadCount)
                            }
                        }
                        
                        // Action Button
                        HStack {
                            Button("Mark All Read") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    for index in notifications.indices {
                                        notifications[index].isRead = true
                                    }
                                }
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(25)
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                    
                    // Notifications List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if notifications.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "bell.slash")
                                        .font(.system(size: 60))
                                        .foregroundColor(.white.opacity(0.6))
                                    
                                    Text("No notifications")
                                        .font(.title2)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text("You're all caught up!")
                                        .font(.body)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .padding(.top, 80)
                            } else {
                                ForEach(notifications) { notification in
                                    NotificationCard(
                                        notification: notification,
                                        onToggleRead: { toggleRead(for: notification) },
                                        onDelete: { deleteNotification(notification) }
                                    )
                                    .transition(.asymmetric(
                                        insertion: .scale.combined(with: .opacity),
                                        removal: .scale.combined(with: .opacity)
                                    ))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func toggleRead(for notification: NotificationModel) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if let index = notifications.firstIndex(of: notification) {
                notifications[index].isRead.toggle()
            }
        }
    }
    
    private func deleteNotification(_ notification: NotificationModel) {
        withAnimation(.easeInOut(duration: 0.3)) {
            notifications.removeAll { $0.id == notification.id }
        }
    }
}

struct NotificationCard: View {
    let notification: NotificationModel
    let onToggleRead: () -> Void
    let onDelete: () -> Void
    
    @State private var offset: CGSize = .zero
    @State private var showingActions = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Main Card Content
            HStack(spacing: 16) {
                // Icon and Priority Indicator
                ZStack {
                    Circle()
                        .fill(notification.type.color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: notification.type.icon)
                        .font(.title3)
                        .foregroundColor(notification.type.color)
                }
                .overlay(
                    Circle()
                        .stroke(notification.priority.color, lineWidth: 2)
                        .opacity(notification.priority == .high ? 1 : 0)
                )
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(notification.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(notification.date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(notification.subtitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(notification.description)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                
                // Unread Indicator
                if !notification.isRead {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(
                        color: notification.isRead ? Color.black.opacity(0.05) : Color.blue.opacity(0.1),
                        radius: notification.isRead ? 2 : 8,
                        x: 0,
                        y: notification.isRead ? 1 : 4
                    )
            )
            .opacity(notification.isRead ? 0.8 : 1.0)
            .scaleEffect(notification.isRead ? 0.98 : 1.0)
            .offset(x: offset.width)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation
                        showingActions = abs(offset.width) > 50
                    }
                    .onEnded { value in
                        withAnimation(.spring()) {
                            if abs(value.translation.width) > 100 {
                                if value.translation.width > 0 {
                                    onToggleRead()
                                }
                            }
                            offset = .zero
                            showingActions = false
                        }
                    }
            )
            
            // Action Button (revealed on swipe)
            if showingActions {
                HStack(spacing: 8) {
                    // Mark Read/Unread
                    Button(action: onToggleRead) {
                        Image(systemName: notification.isRead ? "envelope.badge.fill" : "envelope.open.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
                .transition(.move(edge: .trailing))
                .padding(.trailing, 16)
            }
        }
    }
}

//struct ContentView: View {
//    var body: some View {
//        NotificationsView()
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
