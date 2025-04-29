//
//  HabbitView.swift
//  HabbitLoop
//
//  Created by Jeanette Norberg on 2025-04-29.
//

import SwiftUI

struct HabbitView: View {
    
    @ObservedObject var habbitVm: HabbitViewModel
    @ObservedObject var authVm: AuthViewModel
    
    @State var habbit: String = ""
    
    var body: some View {
        Image("HabbitLoop-loggo")
            .resizable()
            .frame(width: 200, height: 100)
        Text("Welcome \(authVm.userName)!" )
            .font(.title)
            .padding(.bottom)
        VStack{
            Text("Please add Category of your Habbit!")
            TextField("Your Habbit", text: $habbit)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                               .padding(.horizontal)
           
            Button("Save"){
                habbitVm.addHabbit(title: habbit)
                habbit = ""
            }
            .foregroundColor(.mint)
            .bold()
            .padding()
         
            List {
                ForEach (habbitVm.habits)  { habit in
                    HStack{
                        Text(habit.title)
                        Spacer()
                        Image(systemName: habit.done ? "checkmark.circle.fill" : "circle")
                    }
                    .padding() // givs space i the row
                          .background(Color.white) // color inside "item"
                          .cornerRadius(10)
                          .shadow(radius: 1)
                          .listRowInsets(EdgeInsets()) // takes away default settings
                          .padding(.vertical, 4) // gets space between rows
                          .listRowBackground(Color.clear)
                   
                }
            }
            .scrollContentBackground(.hidden) // hides default color
            .background(Color.mint.opacity(0.5))
            
        }
        .onAppear {
            habbitVm.fetchHabits()
        }
    }
}

/*#Preview {
    HabbitView()
}*/
