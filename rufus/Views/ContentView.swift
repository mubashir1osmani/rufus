//
//  ContentView.swift
//  rufus
//
//  Created by Mubashir Osmani on 2025-07-23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Assignment.self, inMemory: true)
}
