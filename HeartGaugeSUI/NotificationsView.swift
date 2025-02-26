//
//  NotificationsView.swift
//  HeartGaugeSUI
//
//  Created by Kenny Mayancela Aylla on 2/7/25.
//

import SwiftUI

struct NotificationItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let message: String
    let date: Date
}

struct NotificationsView: View {
    @State private var notifications: [NotificationItem] = [
      
        NotificationItem(
            icon: "V",
            title: "Vista rewards club....",
            message: "Earn Points without making a purchase\nComplete your first mission today!",
            date: Date.from(year: 2023, month: 12, day: 16)
        ),
        NotificationItem(
            icon: "V",
            title: "The Vista rewards cl...",
            message: "Keep paying with Vista to boost your points and unlock rewards. It's as simple as that.",
            date: Date.from(year: 2023, month: 12, day: 12)
        ),
        NotificationItem(
            icon: "V",
            title: "The Vista rewards cl...",
            message: "Now you're a member of Vista rewards club, start picking up points with every purchase.",
            date: Date.from(year: 2023, month: 12, day: 8)
        )
    ]

    var body: some View {
        
        NavigationView {
            
            List {
                Section(header: Text("Previously")) {
                    ForEach(notifications) { notification in
                        NotificationRow(notification: notification)
                    }
                    
                }
                
                Section {
                    VStack {
                        Text("Missing notifications?")
                        Link("Go to historical notifications", destination: URL(string: "notifications://history")!)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .scrollContentBackground(.hidden)
            .background(Color(red: 0.4, green: 0.4, blue: 0.9))
            .navigationTitle("Notifications")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        
    }
    
}

struct NotificationRow: View {
    let notification: NotificationItem
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.pink.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Text(notification.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.pink)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.system(size: 16, weight: .semibold))
                    
                    Spacer()
                    
                    Text(formatDate(notification.date))
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
                
                Text(notification.message)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }
}

#Preview {
    NotificationsView()
}
