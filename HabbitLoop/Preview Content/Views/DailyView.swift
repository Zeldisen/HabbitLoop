import SwiftUI

struct DailyView: View {
    @ObservedObject var habbitVm: HabbitViewModel
    
    var body: some View {
        
       let todayHabits = habbitVm.habitsForToday()
       let today = Date()
       let weekdayName = habbitVm.weekdayString(from: today)
               
        VStack {
            HStack {
                Text("Daily goals for:")
                    .font(.title)
                Text(weekdayName)
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
                            habitVm: habbitVm
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
    let habitVm: HabbitViewModel
    
    var body: some View {
    
        let today = Date()
        let isDone = habitVm.isHabitDone(for: today, habit: habit)

        HStack {
            Text(habit.title)
            Spacer()
            if isDone {
                Text(" ⭐️ : \(habit.days) days")
               
            }
          
            Button(action: {
                habitVm.toggleDone(for: habit, on: today)
            }) {
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.mint)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                let todayString = habitVm.weekdayString(from: Date())
                habitVm.deleteHabit(habit, day: todayString)
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
