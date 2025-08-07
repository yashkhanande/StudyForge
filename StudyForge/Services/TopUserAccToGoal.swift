//
//  TopUserAccToGoal.swift
//  StudyForge
//
//  Created by Yash Khanande on 30/07/25.
//

import Foundation
import Firebase
import FirebaseFirestore

struct LeaderboardUser: Identifiable {
    var id: String
    var name: String
    var streak: Int
    var totalHours: Int?
    var goal: StudyGoal?
    var country: String?
    var bio: String?
    var isCurrentUser: Bool = false
    var rank: Int?
}

func fetchTopUser(goal: StudyGoal, country: String, currentUserId: String, completion: @escaping ([LeaderboardUser]) -> Void) {
    let db = Firestore.firestore()
    
    db.collection("users")
        .whereField("goal", isEqualTo: goal.rawValue.lowercased())
        .whereField("country", isEqualTo: country)
        .order(by: "streak", descending: true)
        .limit(to: 100)
        .getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching leaderboard: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }
            
            let users: [LeaderboardUser] = documents.enumerated().compactMap { index, doc in
                let data = doc.data()
                guard
                    let name = data["name"] as? String,
                    let streak = data["streak"] as? Int
                else {
                    return nil
                }

                let bio = data["bio"] as? String

                return LeaderboardUser(
                    id: doc.documentID,
                    name: name,
                    streak: streak,
                    bio: bio,
                    isCurrentUser: doc.documentID == currentUserId,
                    rank: index + 1
                )
            }

            completion(users)
        }
}

func fetchTopUsers(goal: StudyGoal, country: String, completion: @escaping ([LeaderboardUser]) -> Void) {
    let db = Firestore.firestore()
    
    db.collection("users")
        .whereField("goal", isEqualTo: goal.rawValue)
        .whereField("country", isEqualTo: country)
        .order(by: "totalHours", descending: true)
        .limit(to: 10)
        .getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching top users: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let documents = snapshot?.documents else {
                print("⚠️ No users found")
                completion([])
                return
            }

            let users = documents.compactMap { document -> LeaderboardUser? in
                let data = document.data()

                guard
                    let name = data["name"] as? String,
                    let totalHours = data["totalHours"] as? Int,
                    let goalString = data["goal"] as? String,
                    let goal = StudyGoal(rawValue: goalString),
                    let country = data["country"] as? String,
                    let streak = data["streak"] as? Int
                else {
                    print("⚠️ Invalid data for user: \(document.documentID)")
                    return nil
                }

                let bio = data["bio"] as? String

                return LeaderboardUser(
                    id: document.documentID,
                    name: name,
                    streak: streak,
                    totalHours: totalHours,
                    goal: goal,
                    country: country,
                    bio: bio
                    
                )
            }

            completion(users)
        }
}
