//
//  MainTabView.swift
//  rufus
//
//  Created by AI Assistant on 2025-07-25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Dashboard")
                }
            
            AssignmentsListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Assignments")
                }
            
            NotificationsView()
                .tabItem {
                    Image(systemName: "bell")
                    Text("Notifications")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

#Preview {
    MainTabView()
}
