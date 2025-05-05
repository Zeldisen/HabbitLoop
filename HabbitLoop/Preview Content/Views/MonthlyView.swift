//
//  MonthlyView.swift
//  HabbitLoop
//
//  Created by Jeanette Norberg on 2025-04-30.
//

import SwiftUI

struct MonthlyView: View {
    @ObservedObject var habitVm: HabbitViewModel
   
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date?
    
    private var doneDates: [Date] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return habitVm.habits.compactMap { habit in
            if habit.done, let lastUpdated = habit.lastUpdated {
               
                return formatter.date(from: lastUpdated)
            }
            return nil
        }
    }

    var habitsDoneOn: [Date] = []  // Fyll i med datum där habit har blivit utfört
    
    // Function to get days in one month
    private func getDaysInMonth(for date: Date) -> [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    // Mark if a day have a habit
    private func isHabitDone(for date: Date) -> Bool {
        return doneDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
    }
    
    var body: some View {
        
        if var selectedDate = selectedDate {
            let weekday = habitVm.weekdayString(from: selectedDate)
            let habitsForDay = habitVm.habits.filter { $0.scheduledDays.contains(weekday) }
            VStack(alignment: .leading) {
                Text("Habits for: \(weekday):")
                    .font(.headline)
                    .padding(.top)

                if habitsForDay.isEmpty {
                    Text("No habits for today.")
                        .foregroundColor(.gray)
                } else {
                    List{
                        ForEach(habitsForDay) { habit in
                            HStack {
                                Text(habit.title)
                                Spacer()
                                Button(action: {
                                    habitVm.toggleDone(for: habit)
                                }) {
                                    Image(systemName: habit.done ? "checkmark.circle.fill" : "circle")
                                }
                            }
                            .padding(.vertical, 4)
                        }.onDelete(perform: habitVm.deleteHabit)
                    }
                }
            }
            .padding(.horizontal)
        }
        VStack {
           
            HStack {
                // Botton to change month to left, ex: from april to march
                Button(action: {
                    currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
                }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.title)
                        .foregroundColor(.mint)
                }
                
                Text("\(currentMonth, formatter: monthFormatter)")
                    .font(.title)
                // Botton to change month to right, ex: from april to may
                Button(action: {
                    currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title)
                        .foregroundColor(.mint)
                }
            }
            .padding()

            // Show all days in month
            let daysInMonth = getDaysInMonth(for: currentMonth)
            let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(daysInMonth, id: \.self) { day in
                    
                    Button(action: {
                        selectedDate = day
                    }) {
                        VStack{
                        
                        Text("\(Calendar.current.component(.day, from: day))")
                            .frame(width: 30, height: 30)
                            .background(isHabitDone(for: day) ? Color.green : Color.clear)
                            .clipShape(Circle())
                            .foregroundColor(isHabitDone(for: day) ? .white : .black)
                        if hasScheduledHabit(on: day) {
                            Circle()
                                .fill(Color.mint)
                                .frame(width: 6, height: 6)
                        } else {
                            Spacer().frame(height: 6) // Keep height equal
                        }}
                    }
                  
                    
                }
            }
            .padding()
            
            
            
        }
    }
    private func hasScheduledHabit(on date: Date) -> Bool {
        let weekday = habitVm.weekdayString(from: date)
       // habitVm.fetchHabits()
        return habitVm.habits.contains { $0.scheduledDays.contains(weekday) }
    }
    // Formattera date to one month/year format
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}


#Preview {
    MonthlyView(habitVm: HabbitViewModel())
}
