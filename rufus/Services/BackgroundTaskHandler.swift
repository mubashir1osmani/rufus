//
//  BackgroundTaskHandler.swift
//  rufus
//
//  Created by AI Assistant on 2025-07-25.
//

import Foundation
import SwiftData
import BackgroundTasks
import UIKit

class BackgroundTaskHandler {
    static let shared = BackgroundTaskHandler()
    
    private init() {}
    
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.beacon.check-assignments", using: nil) { task in
            self.handleBackgroundCheck(task: task as! BGProcessingTask)
        }
    }
    
    private func handleBackgroundCheck(task: BGProcessingTask) {
        // Schedule next background task
        scheduleNextBackgroundCheck()
        
        // Perform the background check
        checkAssignments()
        
        task.setTaskCompleted(success: true)
    }
    
    func scheduleNextBackgroundCheck() {
        let request = BGProcessingTaskRequest(identifier: "com.beacon.check-assignments")
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 4 * 3600) // 4 hours from now
        
        try? BGTaskScheduler.shared.submit(request)
    }
    
    private func checkAssignments() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let context = appDelegate.getModelContext() else {
            print("Failed to get model context for background check")
            return
        }
        
        // Check for overdue assignments
        AssignmentChecker.shared.checkOverdueAssignments(in: context)
        
        print("Checking assignments in background...")
    }
}
