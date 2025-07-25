//
//  AssignmentChecker.swift
//  rufus
//
//  Created by AI Assistant on 2025-07-25.
//

import Foundation
import SwiftData
import UserNotifications

class AssignmentChecker {
    static let shared = AssignmentChecker()
    
    private init() {}
    
    func checkOverdueAssignments(in context: ModelContext) {
        // Using a manual filter instead of Predicate due to compilation issues
        do {
            let assignments = try context.fetch(FetchDescriptor<Assignment>())
            let overdueAssignments = assignments.filter { !$0.isCompleted && $0.dueDate < Date() }
            
            for assignment in overdueAssignments {
                // For each overdue assignment, we'll send an annoying notification
                sendOverdueNotification(for: assignment)
            }
        } catch {
            print("Error fetching assignments: \(error)")
        }
    }
    
    private func sendOverdueNotification(for assignment: Assignment) {
        // Generate a notification item
        let notification = NotificationService.shared.generateNotificationForAssignment(assignment)
        
        // In a real app, we would save this to the database
        // For now, we'll just print it
        print("Overdue notification: \(notification.title) - \(notification.message)")
        
        // Schedule an immediate notification
        let content = UNMutableNotificationContent()
        content.title = "🚨 OVERDUE ASSIGNMENT! 🚨"
        content.body = "YOU MISSED THE DEADLINE FOR \(assignment.title.uppercased())! FIX THIS NOW!"
        content.sound = .defaultCritical
        content.badge = 1
        
        let request = UNNotificationRequest(
            identifier: "overdue_\(assignment.id)",
            content: content,
            trigger: nil // Immediate
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling overdue notification: \(error)")
            }
        }
    }
    
    func schedulePeriodicCheck() {
        // This would be called periodically to check for overdue assignments
        // In a real app, this would be triggered by background tasks
        print("Scheduling periodic assignment check...")
    }
}
