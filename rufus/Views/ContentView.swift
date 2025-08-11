//
//  ContentView.swift
//  rufus
//
//  Created by Mubashir Osmani on 2025-07-23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var authService = AuthService.shared

    var body: some View {
        if authService.isAuthenticated {
            DashboardView()
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Assignment.self, inMemory: true)
}
