//
//  StudyForgeApp.swift
//  StudyForge
//
//  Created by Yash Khanande on 15/07/25.
//

import SwiftUI
import Firebase

@main
struct StudyForgeApp: App {
   
    init() {
        // Initialize Firebase only once
        if FirebaseApp.app() == nil {
            if let filePath = Bundle.main.path(forResource: "GoogleService-StudyForge", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: filePath) {
                FirebaseApp.configure(options: options)
            } else {
                fatalError("Could not find GoogleService-StudyForge.plist")
            }
        }
    }

    @StateObject private var SubjectManager = subjectManager()
    @StateObject private var authViewModel = AuthViewModel()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            AppStartView() 

                .environmentObject(SubjectManager)
                .environmentObject(authViewModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

