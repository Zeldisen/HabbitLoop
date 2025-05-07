import SwiftUI

struct WeeklyView: View {
    @ObservedObject var habbitVm: HabbitViewModel
    let daysOrder = ["Måndag", "Tisdag", "Onsdag", "Torsdag", "Fredag", "Lördag", "Söndag"]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(daysOrder, id: \.self) { day in
                    Section(header: Text(day).font(.headline)) {
                        let habitsForDay = habbitVm.habits.filter { $0.scheduledDays.contains(day) }
                        if habitsForDay.isEmpty {
                            Text("Inga vanor planerade.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(habitsForDay) { habit in
                                WeeklyHabitRow(habit: habit, day: day, habbitVm: habbitVm)
                            }
                        }
                    }
                }
            }
            //.navigationTitle("weekly overview")
           // .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                habbitVm.fetchHabits()
            }
        }
    }
}


struct WeeklyHabitRow: View {
    var habit: Habit
    
    var day: String
    
    @ObservedObject var habbitVm: HabbitViewModel
    
    var body: some View {
        
        let dateForThisDay = habbitVm.dateForWeekdayName(day)
        let isDone = habbitVm.isHabitDone(for: dateForThisDay, habit: habit)
        
        HStack {
            Text("• \(habit.title)")
            Spacer()
            if isDone {
                Text(" ⭐️ : \(habit.days) days")
            }
            Button(action: {
                habbitVm.toggleDone(for: habit, on: dateForThisDay)
            }) {
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.mint)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                habbitVm.deleteHabit(habit, day: day)
            } label: {
                Label("Only This Day", systemImage: "calendar.badge.minus")
            }
            .tint(.orange)
            
            Button(role: .destructive) {
                habbitVm.deleteHabit(habit)
            } label: {
                Label("Delete All", systemImage: "trash")
            }
        }
    }
    
    
    
}
