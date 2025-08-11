//
//  Assignment.swift
//  rufus
//
//  Created by AI Assistant on 2025-07-25.
//

import Foundation
import SwiftData

@Model
final class Assignment {
    var id: UUID
    var title: String
    var assignmentDescription: String
    var dueDate: Date
    var isCompleted: Bool
    var reminderDate: Date
    var subject: String
    var priority: Priority
    
    // Relationship to course
    var course: Course?
    
    enum Priority: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case urgent = "Urgent"
    }
    
    init(
        title: String,
        assignmentDescription: String = "",
        dueDate: Date,
        reminderDate: Date,
        subject: String = "",
        priority: Priority = .medium,
        course: Course? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.assignmentDescription = assignmentDescription
        self.dueDate = dueDate
        self.isCompleted = false
        self.reminderDate = reminderDate
        self.subject = subject
        self.priority = priority
        self.course = course
    }
}
