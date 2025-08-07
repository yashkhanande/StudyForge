//
//  CheckUserGoalStatusView.swift
//  StudyForge
//
//  Created by Yash  Khanande on 20/07/25.
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CheckUserGoalStatusView: View {
    @Binding var path: NavigationPath
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("userId") private var userId: String = ""

    var body: some View {
        Text("Checking goal...")
            .task {
                await checkGoalStatus()
            }
    }

    func checkGoalStatus() async {
        guard let user = Auth.auth().currentUser else {
            print("User not logged in")
            resetAppState()
            return
        }

        let db = Firestore.firestore()
        do {
            let doc = try await db.collection("users").document(user.uid).getDocument()

            guard let data = doc.data() else {
                print("No user data found.")
                resetAppState()
                return
            }

            let goal = data["goal"] as? String ?? ""
          
            if goal.isEmpty {
                path.append(Route.goalSelection(userId: user.uid))
            } else {
                path.append(Route.home)
            }
        } catch {
            print("Firestore error: \(error.localizedDescription)")
            resetAppState()
        }
    }

    func resetAppState() {
        isLoggedIn = false
        userId = ""
        path.removeLast(path.count)
    }
}

#Preview {
    CheckUserGoalStatusView(path: .constant(NavigationPath()))
}
