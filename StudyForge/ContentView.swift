//
//  ContentView.swift
//  StudyForge
//
//  Created by Yash  Khanande on 15/07/25.
//

import SwiftUI

struct ContentView: View {
    @Binding var path : NavigationPath
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Today")
                }

            LeaderboardView()
                .tabItem {
                    Image(systemName: "list.number")
                    Text("Leaderboard")
                }
            SettingsView(path : $path)
                .tabItem{
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

#Preview {
    ContentView(path : .constant(NavigationPath()))
}
