//
//  DashboardView.swift
//  beacon
//
//  Created by AI Assistant on 2025-07-25.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var assignments: [Assignment]
    @StateObject private var authService = AuthService.shared
    
    @State private var showingAddAssignment = false
    @State private var showingDropdown = false
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hello \(getUserName()) 👋")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text("What's on your mind?")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Menu button
                            Button(action: {
                                showingDropdown.toggle()
                            }) {
                                Image(systemName: "line.3.horizontal")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Calendar Widget
                    CalendarWidgetView(selectedDate: $selectedDate, assignments: assignments)
                        .padding(.horizontal)
                    
                    // Tasks Section
                    VStack(spacing: 16) {
                        HStack {
                            Text("Today's Tasks")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Button("See All") {
                                // Handle see all action
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        
                        TaskListWidget(
                            title: "Active Tasks", 
                            assignments: incompleteAssignments, 
                            showingAddAssignment: $showingAddAssignment
                        )
                        .padding(.horizontal)
                    }
                    
                    // Quick Add Section
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            
                            Text("Add new task")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .onTapGesture {
                            showingAddAssignment = true
                        }
                    }
                    .padding(.horizontal)
                    
                    // Add some bottom padding for better scrolling
                    Color.clear
                        .frame(height: 20)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddAssignment) {
            AddAssignmentView()
        }
        .overlay(alignment: .topTrailing) {
            if showingDropdown {
                DropdownMenu(isPresented: $showingDropdown)
                    .padding(.top, 100)
                    .padding(.trailing, 16)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
    
    private func getUserName() -> String {
        if let user = authService.user, let email = user.email {
            return email.components(separatedBy: "@").first?.capitalized ?? "User"
        }
        return "Mubashir"
    }
    
    private var incompleteAssignments: [Assignment] {
        assignments.filter { !$0.isCompleted }.prefix(5).map { $0 }
    }
}

struct CalendarWidget: View {
    @Binding var selectedDate: Date
    let assignments: [Assignment]
    
    @State private var currentMonth = Date()
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Calendar")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: { changeMonth(-1) }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                    
                    Text(monthYearString)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Button(action: { changeMonth(1) }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Compact calendar - show only current week
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(getWeekDays(), id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                        hasAssignment: hasAssignmentOnDate(date),
                        hasEvent: hasEventOnDate(date),
                        onTap: { selectedDate = date }
                    )
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private func changeMonth(_ direction: Int) {
        currentMonth = Calendar.current.date(byAdding: .month, value: direction, to: currentMonth) ?? currentMonth
    }
    
    private func getWeekDays() -> [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
    
    private func hasAssignmentOnDate(_ date: Date) -> Bool {
        assignments.contains { assignment in
            Calendar.current.isDate(assignment.dueDate, inSameDayAs: date)
        }
    }
    
    private func hasEventOnDate(_ date: Date) -> Bool {
        // Placeholder for calendar events - you can integrate with CalendarService later
        // For now, return false as we don't have events in the dashboard context
        return false
    }
    
    private func getDaysInMonth() -> [Date] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let range = calendar.range(of: .day, in: .month, for: currentMonth) ?? 1..<31
        
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
}

struct TaskListWidget: View {
    let title: String
    let assignments: [Assignment]
    @Binding var showingAddAssignment: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    showingAddAssignment = true
                }) {
                    Image(systemName: "plus")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
            
            if assignments.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                    
                    Text("All caught up!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("No tasks for today")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(assignments.prefix(3), id: \.id) { assignment in
                        TaskRowView(assignment: assignment)
                    }
                    
                    if assignments.count > 3 {
                        HStack {
                            Text("+\(assignments.count - 3) more tasks")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        .padding(.top, 4)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct TaskRowView: View {
    let assignment: Assignment
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                assignment.isCompleted.toggle()
                try? modelContext.save()
            }) {
                Image(systemName: assignment.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(assignment.isCompleted ? .green : .gray)
                    .font(.system(size: 20))
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(assignment.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .strikethrough(assignment.isCompleted)
                    .opacity(assignment.isCompleted ? 0.6 : 1.0)
                
                Text(formatDate(assignment.dueDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Priority indicator
            if assignment.priority.rawValue == "High" {
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
            } else if assignment.priority.rawValue == "Medium" {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct DropdownMenu: View {
    @Binding var isPresented: Bool
    @StateObject private var authService = AuthService.shared
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            VStack(spacing: 0) {
                MenuItem(title: "Profile", icon: "person.circle") {
                    isPresented = false
                    // Handle profile action
                }
                
                Divider()
                
                MenuItem(title: "Settings", icon: "gearshape") {
                    isPresented = false
                    // Handle settings action
                }
                
                Divider()
                
                MenuItem(title: "Sign Out", icon: "rectangle.portrait.and.arrow.right", isDestructive: true) {
                    Task {
                        try? await authService.signOut()
                    }
                    isPresented = false
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .frame(width: 160)
        .onTapGesture {
            // Prevent menu from closing when tapped
        }
        .background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    isPresented = false
                }
        )
    }
}

struct MenuItem: View {
    let title: String
    let icon: String
    let isDestructive: Bool
    let action: () -> Void
    
    init(title: String, icon: String, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isDestructive = isDestructive
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isDestructive ? .red : .blue)
                    .frame(width: 20)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(isDestructive ? .red : .primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
    .modelContainer(for: Assignment.self, inMemory: true)
}
