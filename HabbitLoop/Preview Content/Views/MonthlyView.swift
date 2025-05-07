import SwiftUI

struct MonthlyView: View {
    
    @ObservedObject var habitVm: HabitViewModel
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date?
  
    var body: some View {
        VStack {
            // Shows Month and give user possibility to switch month
            HStack {
                Button(action: {
                    currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
                }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.title)
                        .foregroundColor(.mint)
                }

                Text("\(currentMonth, formatter: monthFormatter)")
                    .font(.title)

                Button(action: {
                    currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title)
                        .foregroundColor(.mint)
                }
            }
            .padding()

            // CalenderView, if there ar a dot i a day it`s at least one habit on that day.
            // if user presses on that day a list will apear on the habits that day.
            let daysInMonth = habitVm.getDaysInMonth(for: currentMonth)
            let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(daysInMonth, id: \.self) { day in
                    Button(action: {
                        selectedDate = day
                    }) {
                        VStack {
                            Text("\(Calendar.current.component(.day, from: day))")
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                       
                            if hasScheduledHabit(on: day)  {
                                HStack{ Circle()
                                        .fill(Color.mint)
                                        .frame(width: 6, height: 6)
                                    if  habitVm.isAnyHabitDone(on: day){
                                        Text("⭐️")
                                            .frame(width: 15, height: 6)
                                    }
                                }
                                
                            } else {
                                Spacer().frame(height: 6)
                            }
                        }
                    }
                }
            }
            .padding()

           // Selected day List of Habit and gives user oppertunity to delete och press done/unDone
            if let selectedDate = selectedDate {
                let weekday = habitVm.weekdayString(from: selectedDate)
                let habitsForDay = habitVm.habits.filter { $0.scheduledDays.contains(weekday) }
             
                VStack(alignment: .leading) {
                    Text("Habits for: \(weekday):")
                        .font(.headline)
                        .padding(.top)

                    if habitsForDay.isEmpty {
                        Text("No habits for this day.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List {
                            ForEach(habitsForDay) { habit in
                                let isDone = habitVm.isHabitDone(for: selectedDate, habit: habit)
                                HStack {
                                    Text(habit.title)
                                    Spacer()
                                    if  isDone {
                                        Text(" ⭐️ : \(habit.days) days")
                                    }
                                    Button(action: {
                                        habitVm.toggleDone(for: habit, on: selectedDate)
                                    }) {
                                        Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
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
                        .listStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    
    func hasScheduledHabit(on date: Date) -> Bool {
        let weekday = habitVm.weekdayString(from: date)
        return habitVm.habits.contains { $0.scheduledDays.contains(weekday) }
    }

    var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "sv_SE")
        return formatter
    }
    
    
}
