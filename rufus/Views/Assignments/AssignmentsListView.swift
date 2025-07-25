//
//  AssignmentsListView.swift
//  rufus
//
//  Created by AI Assistant on 2025-07-25.
//

import SwiftUI
import SwiftData

struct AssignmentsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var assignments: [Assignment]
    
    @State private var showingAddAssignment = false
    
    var body: some View {
        List {
            ForEach(assignments) { assignment in
                AssignmentRowView(assignment: assignment)
            }
            .onDelete(perform: deleteAssignments)
        }
        .navigationTitle("Assignments")
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
    
    private func deleteAssignments(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(assignments[index])
            }
        }
    }
}

#Preview {
    NavigationView {
        AssignmentsListView()
    }
    .modelContainer(for: Assignment.self, inMemory: true)
}
