//
//  DailyView.swift
//  HabbitLoop
//
//  Created by Jeanette Norberg on 2025-04-30.
//

import SwiftUI

struct DailyView: View {
    @ObservedObject var habbitVm: HabbitViewModel
    
    var body: some View {
        
        let todayHabits = habbitVm.habitsForToday() // findes habits user choosed for the day
        let today = habbitVm.weekdayString(from: Date()) // finds today so I can print it for user
               
        VStack{
            HStack{
                Text("Daily goals for:")
                    .font(.title)
                Text(today)
                    .font(.title)
                    .padding()
            }
            if todayHabits .isEmpty{
                Text("You hav no habits for today")
            }else{
               
                List {
                
                    ForEach (todayHabits)  { habit in
                        HStack{
                            Text(habit.title)
                            Spacer()
                            Text("streak: \(habit.days)")
                            
                            Spacer()
                            Button(action: {
                                habbitVm.toggleDone(for: habit)
                            }) {
                                Image(systemName: habit.done ? "checkmark.circle.fill" : "circle")
                            }
                        }
                        .padding() // givs space i the row
                        .background(Color.white) // color inside "item"
                        .cornerRadius(10)
                        .shadow(radius: 1)
                        .listRowInsets(EdgeInsets()) // takes away default settings
                        .padding(.vertical, 4) // gets space between rows
                        .listRowBackground(Color.clear)
                        
                    }.onDelete(perform: habbitVm.deleteHabit)
                }
                .scrollContentBackground(.hidden) // hides default color
                .background(Color.mint.opacity(0.5))
            }
            
        }.onAppear {
            habbitVm.fetchHabits()
        }
        }
    }


/*#Preview {
    DailyView()
}*/
