//
//  DashboardView.swift
//  rufus
//
//  Created by AI Assistant on 2025-07-25.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var assignments: [Assignment]
    
    @State private var showingAddAssignment = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Summary cards
                SummaryCardsView(assignments: assignments)
                
                // Upcoming assignments
                UpcomingAssignmentsView(assignments: assignments)
                
                // Priority assignments
                PriorityAssignmentsView(assignments: assignments)
            }
            .padding()
        }
        .navigationTitle("Dashboard")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddAssignment = true
                }) {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddAssignment) {
            AddAssignmentView()
        }
    }
}

struct SummaryCardsView: View {
    let assignments: [Assignment]
    
    var body: some View {
        HStack(spacing: 10) {
            SummaryCard(
                title: "Total",
                count: assignments.count,
                color: .blue
            )
            
            SummaryCard(
                title: "Pending",
                count: assignments.filter { !$0.isCompleted }.count,
                color: .orange
            )
            
            SummaryCard(
                title: "Overdue",
                count: assignments.filter { $0.isOverdue }.count,
                color: .red
            )
        }
    }
}

struct SummaryCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct UpcomingAssignmentsView: View {
    let assignments: [Assignment]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Upcoming Assignments")
                .font(.headline)
            
            if upcomingAssignments.isEmpty {
                Text("No upcoming assignments")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            } else {
                ForEach(upcomingAssignments.prefix(3)) { assignment in
                    UpcomingAssignmentRow(assignment: assignment)
                }
            }
        }
    }
    
    private var upcomingAssignments: [Assignment] {
        return assignments
            .filter { !$0.isCompleted && !$0.isOverdue }
            .sorted { $0.dueDate < $1.dueDate }
    }
}

struct UpcomingAssignmentRow: View {
    let assignment: Assignment
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(assignment.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(assignment.subject)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(assignment.dueDate, style: .relative)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct PriorityAssignmentsView: View {
    let assignments: [Assignment]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("High Priority")
                .font(.headline)
            
            if highPriorityAssignments.isEmpty {
                Text("No high priority assignments")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            } else {
                ForEach(highPriorityAssignments.prefix(3)) { assignment in
                    PriorityAssignmentRow(assignment: assignment)
                }
            }
        }
    }
    
    private var highPriorityAssignments: [Assignment] {
        return assignments
            .filter { !$0.isCompleted && ($0.priority == .high || $0.priority == .urgent) }
            .sorted { $0.dueDate < $1.dueDate }
    }
}

struct PriorityAssignmentRow: View {
    let assignment: Assignment
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(assignment.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(assignment.subject)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack {
                Circle()
                    .fill(assignment.priority == .urgent ? Color.red : Color.orange)
                    .frame(width: 8, height: 8)
                
                Text(assignment.priority.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        DashboardView()
    }
    .modelContainer(for: Assignment.self, inMemory: true)
}
