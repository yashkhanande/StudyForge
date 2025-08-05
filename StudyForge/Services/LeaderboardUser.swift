//
//  LeaderboardUser.swift
//  StudyForge
//
//  Created by Yash  Khanande on 30/07/25.
//

import FirebaseFirestore



struct LeaderboardUser: Identifiable {
    let id: String
    let name: String
    var streak: Int
    let isCurrentUser: Bool
    var rank : Int
    
    init(id: String, name: String, streak: Int, isCurrentUser: Bool = false , rank : Int) {
        self.id = id
        self.name = name
        self.streak = streak
        self.isCurrentUser = isCurrentUser
        self.rank = rank
    }

    init?(document: DocumentSnapshot, currentUserId: String) {
        let data = document.data() ?? [:]
        guard let name = data["name"] as? String,
              let streak = data["streak"] as? Int,
        let rank = data["rank"] as? Int else {
            return nil
        }
        self.id = document.documentID
        self.name = name
        self.streak = streak
        self.isCurrentUser = (document.documentID == currentUserId)
        self.rank = rank
    }
}
