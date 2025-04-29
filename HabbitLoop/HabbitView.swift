//
//  HabbitView.swift
//  HabbitLoop
//
//  Created by Jeanette Norberg on 2025-04-29.
//

import SwiftUI

struct HabbitView: View {
    
    @ObservedObject var habbitVm: HabbitViewModel
    
    @State var habbit: String = ""
    
    var body: some View {
        VStack{
            Text("Please add Category of your Habbit!")
            TextField("Your Habbit", text: $habbit)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                               .padding(.horizontal)
            Button("Save"){
                habbitVm.addHabbit(title: habbit)
            }
            List {
                ForEach (habbitVm.habits)  { habit in
                    HStack{
                        Text(habit.title)
                        Spacer()
                        Image(systemName: habit.done ? "checkmark.circle.fill" : "circle")
                    }
                    
                }
            }
        } .onAppear {
            habbitVm.fetchHabits()
        }
    }
}

/*#Preview {
    HabbitView()
}*/
