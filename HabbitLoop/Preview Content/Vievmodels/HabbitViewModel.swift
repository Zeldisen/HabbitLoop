//
//  HabbitViewModel.swift
//  HabbitLoop
//
//  Created by Jeanette Norberg on 2025-04-29.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import UserNotifications

class HabbitViewModel: ObservableObject {
    
    @Published var habits: [Habit] = []
    
    let db = Firestore.firestore()
    
    /**
     Function to get witch day it is for print to user in views
     */
    func habitsForToday() -> [Habit] {
        let today = self.weekdayString(from: Date()) // t.ex. "Måndag"
        return self.habits.filter { $0.scheduledDays.contains(today) }
    }
 /**
  check userId and add habit to user whit userid
  */
    func addHabbit(title: String,scheduledDays: [String], notify: Bool = false, reminderTime: String? = nil) {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        let newHabit = Habit(
            id: nil,
            title: title,
            userId: userId,
            days: 0,
            lastUpdated: nil,
            scheduledDays: scheduledDays,
            notify: notify,
            reminderTime: reminderTime
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

    // Function to get days in one month, uses in MonthlyView
    func getDaysInMonth(for date: Date) -> [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    /**
     Function to check and helps to ckeck weekdays when its done or not, else it will be done for all days/habit, works together with isHabitDone and toggleDone.
     */
    func dateForWeekdayName(_ weekday: String) -> Date {
        let calendar = Calendar.current
        let weekdays = ["Söndag", "Måndag", "Tisdag", "Onsdag", "Torsdag", "Fredag", "Lördag"]
        guard let weekdayIndex = weekdays.firstIndex(of: weekday) else { return Date() }

        let today = Date()
        let todayWeekday = calendar.component(.weekday, from: today) - 1 // 0 = Söndag
        let delta = weekdayIndex - todayWeekday
        return calendar.date(byAdding: .day, value: delta, to: today) ?? today
    }
    
    // Mark if a day have a habit
    func isHabitDone(for date: Date, habit: Habit) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let targetDate = formatter.string(from: date)
        return habit.doneDates?.contains(targetDate) ?? false
    }
    /**
     Function uses in deleteHabit(_habit:HAbit, day: String) in use of delete a habits from all weeldays
     */
    private func deleteHabitById(_ habitId: String) { //behåll
        db.collection("habits").document(habitId).delete { error in
            if let error = error {
                print("Failed to delete habit: \(error.localizedDescription)")
            } else {
                print("Habit deleted")
            }
        }
    }
    /**
     Function removes all habits from list in all weekdays, not all habits, but that specific habit.
     Gives User a choise to remove all or just from that day.
     */
    func deleteHabit(_ habit: Habit, day: String) { // behåll
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
    /**
     Function that deletets one habit from a weekday, not deletes from all weekdays, but if you have a habbit in sundays and look in monthlyView you can see that it removes from all sundays, but not in other weedays.
     */
    func deleteHabit(_ habit: Habit) {  // behåll
        guard let habitId = habit.id else { return }
        
        db.collection("habits").document(habitId).delete { error in
            if let error = error {
                print("Failed to remove habit: \(error.localizedDescription)")
            } else {
                print("Habit removed")
            }
        }
    }
    
    func fetchHabits () {
        guard let userId = Auth.auth().currentUser?.uid else {
            print(" No userId yet")
            print("User ID missed, waiting 1 second...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.fetchHabits()
            }
            return
        }
        
        db.collection("habits")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print(" No documents found")
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
            print("Habit misses ID")
            return
        }
        
        if habit.doneDates?.contains(todayString) == true {
        
            if habit.lastUpdated != todayString {
                let newDay = habit.days + 1
                
                db.collection("habits").document(habitId).updateData([
                    "days": newDay,
                    "lastUpdated": todayString,
                    "done": false
                ]) { error in
                    if let error = error {
                        print("Failed to update streak days: \(error.localizedDescription)")
                    } else {
                        print("Updated streak: \(newDay) days")
                    }
                }
            } else {
                print("already counted today")
            }
        } else {
            print("Habit is not done for today")
        }
    }
    
    func toggleDone(for habit: Habit, on date: Date) {
        guard let habitId = habit.id else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        var updatedDates = habit.doneDates ?? [] 

        if updatedDates.contains(dateString) {
            updatedDates.removeAll { $0 == dateString }
        } else {
            updatedDates.append(dateString)
        }

        db.collection("habits").document(habitId).updateData([  // update if habit is done on that day on firebase
            "doneDates": updatedDates
        ]) { error in
            if let error = error {
                print("Failed to update done-date: \(error.localizedDescription)")
            } else {
                print("Done-date uppdated for \(dateString)")
                self.fetchHabits()
            }
        }
  
            func habitsGroupedByWeekday() -> [String: [Habit]] {
                var groupedHabits: [String: [Habit]] = [:]
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                let weekdayFormatter = DateFormatter()   // get dates to weekdays
                weekdayFormatter.locale = Locale(identifier: "sv_SV") // Weekdays in swedish
                weekdayFormatter.dateFormat = "EEEE" // full weekdayprint
                
                for habit in self.habits {
                    if let lastUpdatedStr = habit.lastUpdated,
                       let date = formatter.date(from: lastUpdatedStr) {
                        
                        let weekday = weekdayFormatter.string(from: date).capitalized // Måndag, Tisdag fom dates
                        // creates a dictonary of habits
                        if groupedHabits[weekday] == nil {
                            groupedHabits[weekday] = []
                        }
                        groupedHabits[weekday]?.append(habit) // adds habit/habits
                    }
                }
                return groupedHabits
            }
      
        }
    /**
     Function for notifications. User can choose if they want a reminder or not. also choose time and day for reminder.
     */
    func scheduleNotification(title: String, time: Date, weekdays: [String]) {
        let content = UNMutableNotificationContent()
        content.title = "Remember to!"
        content.body = title
        content.sound = .default

        let weekdayMap: [String: Int] = [  // List of days reminder can repeat if user has choosen them.
            "Söndag": 1,
            "Måndag": 2,
            "Tisdag": 3,
            "Onsdag": 4,
            "Torsdag": 5,
            "Fredag": 6,
            "Lördag": 7
        ]
        
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)  // set time for reminder. hours and minutes
        
        for day in weekdays {
            guard let weekdayNum = weekdayMap[day] else { continue }

            var dateComponents = DateComponents()  // create day and time for reminder
            dateComponents.weekday = weekdayNum
            dateComponents.hour = timeComponents.hour
            dateComponents.minute = timeComponents.minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true) // create a trigger for day hour and minute, to repeat every week
            let request = UNNotificationRequest(  // request of reminder
                identifier: UUID().uuidString,  // gives reminder a id. in case user wants to delete
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in  //register notification and prints if something goas wrong.
                if let error = error {
                    print("Notify errer for \(day): \(error.localizedDescription)")
                } else {
                    print("Notify scheduled for \(day) kl. \(timeComponents.hour ?? 0):\(timeComponents.minute ?? 0)")
                }
            }
        }
    }
    
    
     
    }

    
    

    

