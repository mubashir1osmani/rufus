//
//  AddAssignmentView.swift
//  beacon
//
//  Created by AI Assistant on 2025-07-25.
//

import SwiftUI
import SwiftData

struct AddAssignmentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var courses: [Course]
    
    @State private var title = ""
    @State private var assignmentDescription = ""
    @State private var subject = ""
    @State private var selectedCourse: Course?
    @State private var dueDate = Date().addingTimeInterval(86400) // Tomorrow
    @State private var reminderDate = Date().addingTimeInterval(43200) // 12 hours from now
    @State private var priority: Assignment.Priority = .medium
    @State private var showingAddCourse = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Assignment Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $assignmentDescription, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Subject", text: $subject)
                }
                
                Section("Course") {
                    if courses.isEmpty {
                        HStack {
                            Text("No courses available")
                                .foregroundColor(.secondary)
                            Spacer()
                            Button("Add Course") {
                                showingAddCourse = true
                            }
                            .font(.caption)
                        }
                    } else {
                        Picker("Select Course", selection: $selectedCourse) {
                            Text("No Course").tag(nil as Course?)
                            ForEach(courses.sorted(by: { $0.name < $1.name })) { course in
                                HStack {
                                    Circle()
                                        .fill(Color(hex: course.color))
                                        .frame(width: 12, height: 12)
                                    Text(course.displayName)
                                }
                                .tag(course as Course?)
                            }
                        }
                        
                        Button("Add New Course") {
                            showingAddCourse = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
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
            .sheet(isPresented: $showingAddCourse) {
                AddCourseView()
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
            priority: priority,
            course: selectedCourse
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
