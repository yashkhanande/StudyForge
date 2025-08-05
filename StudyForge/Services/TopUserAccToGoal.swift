//
//  TopUserAccToGoal.swift
//  StudyForge
//
//  Created by Yash  Khanande on 30/07/25.
//

import Foundation
import Firebase
import FirebaseFirestore


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

                return LeaderboardUser(
                    id: doc.documentID,
                    name: name,
                    streak: streak,
                    isCurrentUser: doc.documentID == currentUserId,
                    rank: index + 1 // ← assuming 'rank' is a required property in your struct
                )
            }


            
            completion(users)
        }
}
