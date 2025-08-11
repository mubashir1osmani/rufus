//
//  CoursesListView.swift
//  rufus
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI
import SwiftData

struct CoursesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var courses: [Course]
    
    @State private var showingAddCourse = false
    
    var body: some View {
        NavigationStack {
            List {
                if courses.isEmpty {
                    ContentUnavailableView(
                        "No Courses",
                        systemImage: "book.closed",
                        description: Text("Add your first course to get started with organizing your assignments.")
                    )
                } else {
                    ForEach(courses.sorted(by: { $0.name < $1.name })) { course in
                        CourseRowView(course: course)
                    }
                    .onDelete(perform: deleteCourses)
                }
            }
            .navigationTitle("Courses")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Course") {
                        showingAddCourse = true
                    }
                }
                
                if !courses.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $showingAddCourse) {
                AddCourseView()
            }
        }
    }
    
    private func deleteCourses(offsets: IndexSet) {
        withAnimation {
            let sortedCourses = courses.sorted(by: { $0.name < $1.name })
            for index in offsets {
                modelContext.delete(sortedCourses[index])
            }
        }
    }
}

struct CourseRowView: View {
    let course: Course
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: course.color))
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(course.displayName)
                    .font(.headline)
                
                if !course.professor.isEmpty {
                    Text(course.professor)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text("\(course.assignments.count) assignment\(course.assignments.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CoursesListView()
}
