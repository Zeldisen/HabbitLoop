//
//  Habit.swift
//  HabbitLoop
//
//  Created by Jeanette Norberg on 2025-04-29.
//

import Foundation
import FirebaseFirestore

struct Habit: Identifiable , Codable {
    
    @DocumentID var id: String?
       var title: String
       var done: Bool
       var userId: String
       var days: Int
       var lastUpdated: String?
       var scheduledDays: [String]
       var doneDates: [String]? 

    
}
