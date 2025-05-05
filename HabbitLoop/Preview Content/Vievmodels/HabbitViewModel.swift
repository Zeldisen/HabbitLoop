//
//  HabbitViewModel.swift
//  HabbitLoop
//
//  Created by Jeanette Norberg on 2025-04-29.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class HabbitViewModel: ObservableObject {
    
    @Published var habits: [Habit] = []
    
    let db = Firestore.firestore()
    
    func addHabbit(title: String,scheduledDays: [String]) {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        let newHabit = Habit(
               id: nil,
               title: title,
               done: false,
               userId: userId,
               days: 0,
               lastUpdated: nil,
               scheduledDays: scheduledDays
           )
           do {
               try db.collection("habits").addDocument(from: newHabit)
           } catch {
               print("Error saving to Firestore: \(error)")
           }
        }
    
    func weekdayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "sv_SE")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date).capitalized // Ex: "Måndag"
    }
    
    func deleteHabit(at offsets: IndexSet) {
        
      
        for index in offsets {
                let habit = habits[index]
                guard let habitId = habit.id else { continue }
                
            db.collection("habits").document(habitId).delete { error in
                if let error = error {
                    print(" Kunde inte ta bort habit: \(error.localizedDescription)")
                } else {
                    print(" Habit borttagen")
                }
            }
            }
        
        
    }
    func fetchHabits () {
        guard let userId = Auth.auth().currentUser?.uid else {
            print(" Ingen userId ännu")
            print("User ID saknas, väntar 1 sekund...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.fetchHabits()
            }
            return
        }
        
        db.collection("habits")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print(" Inga dokument hittade")
                    return }
                self.habits = documents.compactMap { try? $0.data(as: Habit.self) }
                
            }
    }
    
    func countStreakdays(for habit: Habit){
        _ = Calendar.current
           let now = Date()
           let formatter = DateFormatter()
           formatter.dateFormat = "yyyy-MM-dd"
           let todayString = formatter.string(from: now)

           guard let habitId = habit.id else {
               print("Habit saknar ID")
               return
           }
        if habit.done {
            if habit.lastUpdated != todayString {
                       let newDay = habit.days + 1
                
                db.collection("habits").document(habitId).updateData([
                               "days": newDay,
                               "lastUpdated": todayString,
                               "done": false
                           ]) { error in
                               if let error = error {
                                   print("Misslyckades med att uppdatera dagar: \(error.localizedDescription)")
                               } else {
                                   print("Uppdaterade streak: \(newDay) dagar")
                               }
                           }
                       } else {
                           print("Redan räknat idag")
                       }
                   } else {
                       print("Habit är inte gjord ännu idag")
                   }
        }
    
    func toggleDone(for habit: Habit) {
        guard let habitId = habit.id else { return }
        let newDoneStatus = !habit.done
        db.collection("habits").document(habitId).updateData([
            "done": !habit.done
        
        ]) { error in
            if let error = error {
                print("Kunde inte uppdatera done-status: \(error.localizedDescription)")
            } else {
                print("Done-status uppdaterad")
                
                if newDoneStatus == true {
                               self.countStreakdays(for: habit)
                           }
            }
        }
    }
    /**
     Fucntion to get witch day it is for print to user in views
     */
    func habitsForToday() -> [Habit] {
        let today = weekdayString(from: Date()) // t.ex. "Måndag"
        return habits.filter { $0.scheduledDays.contains(today) }
    }
    
    func habitsGroupedByWeekday() -> [String: [Habit]] {
        var groupedHabits: [String: [Habit]] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = Locale(identifier: "en_EN") // Weekdays in swedish
        weekdayFormatter.dateFormat = "EEEE" // full weekdayprint
        
        for habit in habits {
            if let lastUpdatedStr = habit.lastUpdated,
               let date = formatter.date(from: lastUpdatedStr) {
                
                let weekday = weekdayFormatter.string(from: date).capitalized // Måndag, Tisdag ...
                
                if groupedHabits[weekday] == nil {
                    groupedHabits[weekday] = []
                }
                groupedHabits[weekday]?.append(habit)
            }
        }
        return groupedHabits
    }
    
    
    
    }

    
   /*func countdays( for habit: Habit){
        _ = Calendar.current
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: now)
        
        if habit.lastUpdated == todayString {
            print("alreday updated today")
            return
        }
        
        let newDayCount = habit.days + 1
        
        guard let habitId = habit.id else {return}
        
        db.collection("habits").document(habitId).updateData([
            "days" : newDayCount,
            "lastUpdated" : todayString
        ]) {error in
            if error != nil {
                print("Failed to update days")
            }else {
                print("updated days")
            }
        }
    }
        */
        
    
    
    

    

