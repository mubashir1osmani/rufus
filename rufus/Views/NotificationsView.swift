//
//  NotificationsView.swift
//  rufus
//
//  Created by AI Assistant on 2025-07-25.
//

import SwiftUI
import SwiftData

struct NotificationsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var notifications: [NotificationItem]
    
    var body: some View {
        List {
            ForEach(notifications.sorted(by: { $0.timestamp > $1.timestamp })) { notification in
                NotificationRowView(notification: notification)
            }
        }
        .navigationTitle("Notifications")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Mark All Read") {
                    markAllAsRead()
                }
                .disabled(!notifications.contains(where: { !$0.isRead }))
            }
        }
    }
    
    private func markAllAsRead() {
        for notification in notifications where !notification.isRead {
            notification.isRead = true
        }
    }
}

struct NotificationRowView: View {
    @Bindable var notification: NotificationItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(notification.title)
                    .font(.headline)
                    .foregroundColor(notification.isRead ? .secondary : .primary)
                
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundColor(notification.isRead ? .secondary : .primary)
                
                Text(notification.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !notification.isRead {
                Circle()
                    .fill(.red)
                    .frame(width: 8, height: 8)
            }
        }
        .onTapGesture {
            notification.isRead = true
        }
    }
}

#Preview {
    NavigationView {
        NotificationsView()
    }
    .modelContainer(for: NotificationItem.self, inMemory: true)
}
