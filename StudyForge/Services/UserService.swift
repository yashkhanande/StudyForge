
//
//  UserService.swift
//  StudyForge
//
//  Created by Yash Khanande on 17/07/25.
//
import FirebaseAuth
import Foundation
import Combine
import Firebase

class UserService: ObservableObject {
    
    static let shared = UserService()
    
    @Published var didUpdateStreak = false
    @Published var currentUser: UserModel
    
    private let userDefaultsKey = "currentUserData"
    private let streakDateKey = "lastStreakDate"

    private init() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let savedUser = try? JSONDecoder().decode(UserModel.self, from: data) {
            self.currentUser = savedUser
        } else {
            self.currentUser = UserModel(id: UUID(), name: "student", studyGoal: .upsc, streak: 0, totalStudyTime: 0 , country: "India")
            saveUser()
        }
    }
   

    func saveUser() {
        if let data = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }

    func updateStreakIfNeeded(totalToday: TimeInterval) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        let lastStreakDate = UserDefaults.standard.string(forKey: streakDateKey)

        if totalToday >= 14 && lastStreakDate != today {
            currentUser.streak += 1
            UserDefaults.standard.set(today, forKey: streakDateKey)
            saveUser()
            didUpdateStreak = true
            
            // 🔐 Use Firebase UID as document ID
            guard let uid = Auth.auth().currentUser?.uid else {
                print("❌ No logged-in Firebase user. Skipping Firestore update.")
                return
            }

            let db = Firestore.firestore()
            db.collection("users").document(uid).setData([
                "streak": currentUser.streak
            ], merge: true) { error in
                if let error = error {
                    print("❌ Failed to update streak in Firestore: \(error.localizedDescription)")
                } else {
                    print("✅ Streak updated in Firestore for UID: \(uid)")
                }
            }
        }
    }

    func updateStudyTime(by seconds: TimeInterval) {
        currentUser.totalStudyTime += seconds
        saveUser()
    }

    func setName(_ newName: String) {
        currentUser.name = newName
        saveUser()
    }

    func changeGoal(_ newGoal: StudyGoal) {
        currentUser.studyGoal = newGoal
        saveUser()
    }

    func updateStreak(by days: Int) {
        currentUser.streak += days
        saveUser()
    }

    func resetStreak() {
        currentUser.streak = 0
        saveUser()
    }

    func resetUser() {
        currentUser = UserModel(id: UUID(), name: "newName", studyGoal: .upsc, streak: 0, totalStudyTime: 0,country : "India")
        saveUser()
    }
    
    func refreshUserFromFirestore(completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ No Firebase user found.")
            completion(false)
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)

        userRef.getDocument { snapshot, error in
            if let error = error {
                print("⚠️ Firestore fetch failed: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let data = snapshot?.data() else {
                print("⚠️ No data found for user.")
                completion(false)
                return
            }

            // Decode Firestore data into currentUser
            let name = data["name"] as? String ?? "student"
            let streak = data["streak"] as? Int ?? 0
            let goalRaw = data["goal"] as? String ?? "upsc"
            let country = data["country"] as? String ?? "India"
            let studyGoal = StudyGoal(rawValue: goalRaw) ?? .upsc

            // Update local model
            self.currentUser = UserModel(
                id: UUID(), // UUID isn't stored in Firestore, can be regenerated or stored separately
                name: name,
                studyGoal: studyGoal,
                streak: streak,
                totalStudyTime: data["totalStudyTime"] as? TimeInterval ?? 0,
                country: country
            )

            self.saveUser()
            completion(true)
        }
    }

}
