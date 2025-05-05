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
  
    // var habitsDoneOn: [Date] = []  // Fyll i med datum där habit har blivit utfört
  
    var body: some View {
        
        if let selectedDate = selectedDate {
            let weekday = habitVm.weekdayString(from: selectedDate)
            let habitsForDay = habitVm.habits.filter { $0.scheduledDays.contains(weekday) }
            
            VStack(alignment: .leading) {
                Text("Habits for: \(weekday):")
                    .font(.headline)
                    .padding()

                if habitsForDay.isEmpty {
                    Text("No habits for today.")
                        .foregroundColor(.gray)
                        .padding()
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
                                        .foregroundColor(.mint)
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    habitVm.deleteHabit(habit, day: weekday)
                                } label: {
                                    Label("Only This Day", systemImage: "calendar.badge.minus")
                                }
                                .tint(.orange)
                                
                                Button(role: .destructive) {
                                    habitVm.deleteHabit(habit)
                                } label: {
                                    Label("Delete All", systemImage: "trash")
                                }
                            }
                            .padding(.vertical, 4)
                        }
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
                let daysInMonth = habitVm.getDaysInMonth(for: currentMonth)
                let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)
                
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(daysInMonth, id: \.self) { day in
                        
                        Button(action: {
                            selectedDate = day
                        }) {
                            VStack{
                                
                                Text("\(Calendar.current.component(.day, from: day))")
                                    .frame(width: 30, height: 30)
                                   // .background(habitVm.isHabitDone(for: day) ? Color.green : Color.clear)
                                    .clipShape(Circle())
                                   // .foregroundColor(habitVm.isHabitDone(for: day) ? .white : .black)
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
    func hasScheduledHabit(on date: Date) -> Bool {
        let weekday = habitVm.weekdayString(from: date)
       // habitVm.fetchHabits()
        return habitVm.habits.contains { $0.scheduledDays.contains(weekday) }
    }
    // Formattera date to one month/year format
    var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}


/*#Preview {
    MonthlyView(habitVm: HabbitViewModel())
}*/
