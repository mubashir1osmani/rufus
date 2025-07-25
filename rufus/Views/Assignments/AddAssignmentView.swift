//
//  AddAssignmentView.swift
//  rufus
//
//  Created by AI Assistant on 2025-07-25.
//

import SwiftUI
import SwiftData

struct AddAssignmentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var assignmentDescription = ""
    @State private var subject = ""
    @State private var dueDate = Date().addingTimeInterval(86400) // Tomorrow
    @State private var reminderDate = Date().addingTimeInterval(43200) // 12 hours from now
    @State private var priority: Assignment.Priority = .medium
    
    var body: some View {
        NavigationView {
            Form {
                Section("Assignment Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $assignmentDescription, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Subject", text: $subject)
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(Assignment.Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Dates") {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("Reminder Date", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("New Assignment")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAssignment()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveAssignment() {
        let newAssignment = Assignment(
            title: title,
            assignmentDescription: assignmentDescription,
            dueDate: dueDate,
            reminderDate: reminderDate,
            subject: subject,
            priority: priority
        )
        
        modelContext.insert(newAssignment)
        
        // Schedule annoying notifications
        NotificationService.shared.scheduleAssignmentReminder(for: newAssignment)
        
        dismiss()
    }
}

#Preview {
    AddAssignmentView()
}
