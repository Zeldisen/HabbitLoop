//
//  WeeklyView.swift
//  HabbitLoop
//
//  Created by Jeanette Norberg on 2025-04-30.
//

import SwiftUI

struct WeeklyView: View {
    
    @ObservedObject var habbitVm: HabbitViewModel
    let daysOrder = ["Måndag", "Tisdag", "Onsdag", "Torsdag", "Fredag", "Lördag", "Söndag"]
    
    var body: some View {
        let groupedHabits = habbitVm.habitsGroupedByWeekday()
        VStack{
            Text("Your weekly goals!")
           
            
            List {
                ForEach(daysOrder, id: \.self) { day in
                    Text(day)
                        .font(.headline)
                        .padding(.top)

                    ForEach(habbitVm.habits.filter { $0.scheduledDays.contains(day) }) { habit in
                        Text("• \(habit.title)")
                            .padding(.leading)
                    }
                }
            }
        }.onAppear {
            habbitVm.fetchHabits()
        }
    }
}

#Preview {
    WeeklyView(habbitVm: HabbitViewModel())
}
