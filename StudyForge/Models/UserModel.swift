//
//  UserModel.swift
//  StudyForge
//
//  Created by Yash  Khanande on 17/07/25.
//

import Foundation

enum StudyGoal : String , CaseIterable ,Codable{
    case upsc = "UPSC"
    case ssc = "SSC"
    case jee = "JEE"
    case neet = "NEET"
    case cet = "CET"
    case other = "OTHER"
}

struct UserModel: Codable {
    var id: UUID
    var name: String
    
    var studyGoal: StudyGoal
    var streak: Int
    var totalStudyTime: TimeInterval
    var country: String
}

