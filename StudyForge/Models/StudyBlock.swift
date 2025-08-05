//
//  StudyBlock.swift
//  StudyForge
//
//  Created by Yash  Khanande on 15/07/25.
//

import SwiftUI
import Foundation

struct StudyBlock : Identifiable , Codable {
    let id : UUID
    let subject : String
    let startTime : String
    let endTime : String
    let playlistLink : String?
    let date : Date
}
