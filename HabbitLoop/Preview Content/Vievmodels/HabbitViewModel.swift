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
    

     var doneDates: [Date] {
         let formatter = DateFormatter()
         formatter.dateFormat = "yyyy-MM-dd"
         
         return habits.compactMap { habit in
             if habit.done, let lastUpdated = habit.lastUpdated {
                
                 return formatter.date(from: lastUpdated)
             }
             return nil
         }
     }
    

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

 /**
  Function that deletets one habit from a weekday, not deletes from all weekdays, but if you have a habbit in sundays and look in monthlyView you can see that it removes from all sundays, but not in other weedays.
  */
    func deleteHabit(_ habit: Habit) {
        guard let habitId = habit.id else { return }

        db.collection("habits").document(habitId).delete { error in
            if let error = error {
                print("Failed to remove habit: \(error.localizedDescription)")
            } else {
                print("Habit removed")
            }
        }
    }
    /**
     Function removes all habits from list in all weekdays, not all habits, but that specific habit.
     Gives User a choise to remove all or just from that day.
     */
    func deleteHabit(_ habit: Habit, day: String) {
        guard let habitId = habit.id else { return }

        // If habit is Scheduled one day, remove habit
        if habit.scheduledDays.count == 1 {
            deleteHabitById(habitId)
            return
        }

        // Else just remove for that day
        let updatedDays = habit.scheduledDays.filter { $0 != day }

        db.collection("habits").document(habitId).updateData([
            "scheduledDays": updatedDays
        ]) { error in
            if let error = error {
                print("Failed to delete day from habit: \(error.localizedDescription)")
            } else {
                print("deleted habit on \(day) from habit:\(habit.title)")
            }
        }
    }
    
    private func deleteHabitById(_ habitId: String) {
        db.collection("habits").document(habitId).delete { error in
            if let error = error {
                print("Failed to delete habit: \(error.localizedDescription)")
            } else {
                print("Habit deleted")
            }
        }
    }
    
    func getDaysInMonth(for date: Date) -> [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    // Mark if a day have a habit
    func isHabitDone(for date: Date, habit: Habit) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let targetDate = formatter.string(from: date)
        return habit.doneDates?.contains(targetDate) ?? false
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
      
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())

        var updatedDates = habit.doneDates ?? []

        if updatedDates.contains(today) {
            updatedDates.removeAll { $0 == today }
        } else {
            updatedDates.append(today)
        }

        db.collection("habits").document(habitId).updateData([
            "doneDates": updatedDates
        ]) { error in
            if let error = error {
                print("Kunde inte uppdatera done-datum: \(error.localizedDescription)")
            } else {
                print("Done-datum uppdaterat")
                self.fetchHabits()
                self.countStreakdays(for: habit)

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
        
    
    
    

    

