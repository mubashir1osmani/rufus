//
//  NotificationItem.swift
//  rufus
//
//  Created by AI Assistant on 2025-07-25.
//

import Foundation
import SwiftData

@Model
final class NotificationItem {
    var id: UUID
    var title: String
    var message: String
    var timestamp: Date
    var isRead: Bool
    var assignmentId: UUID?
    
    init(
        title: String,
        message: String,
        timestamp: Date = Date(),
        assignmentId: UUID? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.message = message
        self.timestamp = timestamp
        self.isRead = false
        self.assignmentId = assignmentId
    }
}
