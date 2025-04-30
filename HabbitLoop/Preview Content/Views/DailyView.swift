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
        VStack{
            Text("Your daily goals!")
            List {
                ForEach (habbitVm.habits)  { habit in
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
            
        }.onAppear {
            habbitVm.fetchHabits()
        }
        }
    }


/*#Preview {
    DailyView()
}*/
