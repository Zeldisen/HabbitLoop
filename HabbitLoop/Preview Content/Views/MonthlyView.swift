import SwiftUI

struct MonthlyView: View {
    @ObservedObject var habitVm: HabbitViewModel

    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date?

    var body: some View {
        VStack {
            // MARK: - Month Selector
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

            // MARK: - Calendar Grid
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
                                //.background(habitVm.isHabitDone(for: day, habit: habit) ? Color.green : Color.clear)
                                .clipShape(Circle())
                               // .foregroundColor(habitVm.isHabitDone(for: day, habit: habit) ? .white : .black)

                            if hasScheduledHabit(on: day) {
                                Circle()
                                    .fill(Color.mint)
                                    .frame(width: 6, height: 6)
                            } else {
                                Spacer().frame(height: 6)
                            }
                        }
                    }
                }
            }
            .padding()

            // MARK: - Selected Day Habit List
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
                        .listStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Helper Methods
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
