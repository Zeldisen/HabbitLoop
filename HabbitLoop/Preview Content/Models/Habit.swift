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
       var userId: String
       var days: Int
       var lastUpdated: String?
       var scheduledDays: [String]
       var doneDates: [String]?
       var notify: Bool?      
       var reminderTime: String?
    
   /* init(title: String, scheduledDays: String, notify: Bool, reminderTime: String?) {
           self.title = title
          // self.userId = userId
           //self.days = days
          // self.lastUpdated = lastUpdated
           self.scheduledDays = [scheduledDays]
         //  self.doneDates = [doneDates]
         //  self.notify = notify
         // self.reminderTime = reminderTime
       }*/

}


