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

class HabitViewModel: ObservableObject {
    
    
    @Published var habits: [Habit] = []
    @Published var trophys = Trophys()
    
    let db = Firestore.firestore()
    
    init() {
        fetchHabits()
        loadTrophiesFromFirestore()
    }
    
    /**
     Function to get witch day it is for print to user in dailyView
     */
    func habitsForToday() -> [Habit] {
        let today = self.weekdayString(from: Date()) // t.ex. "Måndag"
        return self.habits.filter { $0.scheduledDays.contains(today) }
    }
 /**
  check userId and add habit to user whit userid in addHabitView
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
    // uses in dailyView and MonthlyView
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
    /**
     Counting streak days and adds one day to a habit if its done in todays date. also if user did not do donecheck on a day it will be resett to zero, user looses streak.
     this function also checks and adds trophys for trophys collection. but this will be the same even if a streak resetts, user can not lose trophys. This beause incurrage user to continue to be better at habits.
     */
    func countStreakdays(for habit: Habit){
        
        let calendar = Calendar.current
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: now)
        
        guard let habitId = habit.id else {
            print("Habit misses ID")
            return
        }
        
        if habit.lastUpdated == todayString {
            print(" Already updated streak today, skipping.")
            return
        }
        
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let yesterdayString = formatter.string(from: yesterday)
        
        let doneDates = habit.doneDates ?? []
        
        let isDoneToday = doneDates.contains(todayString)
        let wasDoneYesterday = doneDates.contains(yesterdayString)
        
        if isDoneToday && habit.lastUpdated != todayString {
                let newDay = wasDoneYesterday ? habit.days + 1 : 1
            
            if newDay == 1 || newDay == 3 || newDay == 5{  // Day 1, 3, 5 user get a streak user get a bronze price
                    trophys.bronze += 1
                trophyNotification(trophy: "🥉", message: "You got a new bronze trophy!")
            }else if [7, 10, 14, 18, 22, 26].contains(newDay) { // From day 7 -> 26 streak user get a silver price
                trophys.silver += 1
                trophyNotification(trophy: "🥈", message: "You got a new silver trophy!")
            } else if [30, 35, 40, 45, 50, 60, 70, 80, 90].contains(newDay) {  // From day 30 -> 90 user get a gold price
                trophys.gold += 1
                trophyNotification(trophy: "🥇", message: "You got a new golden trophy!")
            } else if newDay % 100 == 0 {  // Evry 100day user get a cup price / extra ordinary
                trophys.cup += 1
                trophyNotification(trophy: "🏆", message: "You got a rare golden cup trophy!")
            }
            saveTrophiesToFirestore()
            
            db.collection("habits").document(habitId).updateData([
                      "days": newDay,
                      "lastUpdated": todayString
                  ]) { error in
                      if let error = error {
                          print("Kunde inte uppdatera streak: \(error.localizedDescription)")
                      } else {
                          print("Uppdaterade streak: \(newDay) dagar")
                      }
                  }

              } else if !wasDoneYesterday && habit.days > 0 {
                  //  Missed donecheck -> reset streak, means that user streak reset to zero for that habit. Keeps trophys
                  db.collection("habits").document(habitId).updateData([
                      "days": 0,
                      "lastUpdated": todayString
                  ]) { error in
                      if let error = error {
                          print("Kunde inte nollställa streak: \(error.localizedDescription)")
                      } else {
                          print("Streak nollställd!")
                      }
                  }
              }
    }
    /**
     Check if done and updates doneDates and calls on countStreakDays
     */
    func toggleDone(for habit: Habit, on date: Date) {
        guard let habitId = habit.id else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)

        var updatedDates = habit.doneDates ?? []

        let isMarkingDone = !updatedDates.contains(dateString)

        if isMarkingDone {
            updatedDates.append(dateString)
        } else {
            updatedDates.removeAll { $0 == dateString }
        }

        // UpdateFirestore with new doneDates
        db.collection("habits").document(habitId).updateData([
            "doneDates": updatedDates
        ]) { error in
            if let error = error {
                print("Failed to update done-date: \(error.localizedDescription)")
            } else {
                print("Done-date updated for \(dateString)")

                // Update local model directly , UI mirror directly
                if let index = self.habits.firstIndex(where: { $0.id == habitId }) {
                    self.habits[index].doneDates = updatedDates
                }
                // count streak only if done mark is on todays date.
                let todayString = formatter.string(from: Date())
                if isMarkingDone && dateString == todayString {
                    var updatedHabit = habit
                    updatedHabit.doneDates = updatedDates

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.countStreakdays(for: updatedHabit)
                    }
                
                    
                }
            }
        }
        }
    /**
      checks if any habit is done on that day an put a star in calenderview to show user that there is one or more habits don on that day
     */
    func isAnyHabitDone(on date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        return habits.contains { habit in
            habit.doneDates?.contains(dateString) ?? false
        }
    }
    // saves thropies to firestore
    func saveTrophiesToFirestore() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        do {
            try db.collection("trophies").document(userId).setData(from: trophys)
            print("user trophys saved")
        } catch {
            print("Failed to save trophies: \(error)")
        }
    }
    // Loading trophies from firestore
    func loadTrophiesFromFirestore() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("trophies").document(userId).getDocument { snapshot, error in
            if let data = snapshot, let stats = try? data.data(as: Trophys.self) {
                self.trophys = stats
            }
        }
    }
    // Notification on trophies, if user got one while app is not running but running in background, not sure if it really work
    // have not hade the chance to test it yet, and user get a trophy right away when done check is done.
    func trophyNotification(trophy: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = "New trophy!: \(trophy)"
        content.body = message
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notisfail: \(error.localizedDescription)")
            }
        }
    }
    /**
     Function for notifications. User can choose if they want a reminder or not. also choose time and day for reminder. Works if app running in background.
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

    
    

    

