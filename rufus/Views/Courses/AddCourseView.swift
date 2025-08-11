//
//  AddCourseView.swift
//  rufus
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI
import SwiftData

struct AddCourseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var code = ""
    @State private var professor = ""
    @State private var selectedColor = Course.defaultColors[0]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Course Information") {
                    TextField("Course Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Course Code (Optional)", text: $code)
                        .textInputAutocapitalization(.characters)
                    
                    TextField("Professor (Optional)", text: $professor)
                        .textInputAutocapitalization(.words)
                }
                
                Section("Course Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(Course.defaultColors, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("New Course")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCourse()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveCourse() {
        let newCourse = Course(
            name: name,
            code: code,
            color: selectedColor,
            professor: professor
        )
        
        modelContext.insert(newCourse)
        dismiss()
    }
}

#Preview {
    AddCourseView()
}
