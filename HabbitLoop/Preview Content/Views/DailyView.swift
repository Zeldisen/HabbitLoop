import SwiftUI

struct DailyView: View {
    @ObservedObject var habbitVm: HabbitViewModel
    
    var body: some View {
        
       let todayHabits = habbitVm.habitsForToday()
        let today = habbitVm.weekdayString(from: Date())
               
        VStack {
            HStack {
                Text("Daily goals for:")
                    .font(.title)
                Text(today)
                    .font(.title)
                    .padding()
            }
            
            if todayHabits.isEmpty {
                Text("You have no habits for today")
            } else {
                List {
                    ForEach(todayHabits) { habit in
                        HabitRow(
                            habit: habit,
                            day: today,
                            habitVm: habbitVm // skickas som let
                        )
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.mint.opacity(0.5))
            }
        }
        .onAppear {
            habbitVm.fetchHabits()
        }
    }
}

struct HabitRow: View {
    var habit: Habit
    var day: String
    let habitVm: HabbitViewModel

    var body: some View {
        let isDoneToday = habitVm.isHabitDone(for: Date(), habit: habit)
        
        HStack {
            Text(habit.title)
            Spacer()
            Text("streak: \(habit.days)")
            Spacer()
            Button(action: {
                habitVm.toggleDone(for: habit)
            }) {
                Image(systemName: isDoneToday ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.mint)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                habitVm.deleteHabit(habit, day: day)
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
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 1)
        .listRowInsets(EdgeInsets())
        .padding(.vertical, 4)
        .listRowBackground(Color.clear)
    }
}
