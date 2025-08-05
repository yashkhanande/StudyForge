//
//  AppStartView.swift
//  StudyForge
//
//  Created by Yash  Khanande on 20/07/25.
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

enum Route: Hashable {
    case goalSelection(userId: String)
    case home
    case login
}

struct AppStartView: View {
    @State private var path = NavigationPath()
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("userId") private var userId: String = ""

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if isLoggedIn && !userId.isEmpty {
                    // ✅ Directly go to home if logged in
                    ContentView(path: $path)
                } else {
                    LoginView(path: $path)
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .goalSelection(let userId):
                    GoalSelectionView(userId: userId, path: $path)
                case .home:
                    ContentView(path : $path)
                case .login:
                    LoginView(path: $path)
                }
            }
        }
        .environmentObject(subjectManager.shared)
    }
}

#Preview {
    AppStartView()
        .environmentObject(subjectManager.preview) // ✅ For Previews
}
