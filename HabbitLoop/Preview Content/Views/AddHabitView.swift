//
//  AddHabitView.swift
//  HabbitLoop
//
//  Created by Jeanette Norberg on 2025-04-30.
//

import SwiftUI



struct AddHabitView: View {
    @ObservedObject var habbitVm: HabbitViewModel
    @ObservedObject var authVm: AuthViewModel
    
    @State var habbit: String = ""
    @State var selectedDays: [String] = []
    
    let allDays = ["Måndag", "Tisdag", "Onsdag", "Torsdag", "Fredag", "Lördag", "Söndag"]
    
    
    var body: some View {
        VStack{
            Image("HabbitLoop-loggo")
                .resizable()
                .frame(width: 200, height: 100)
            Text("Welcome \(authVm.userName)!" )
                .font(.title)
                .padding(.bottom)
        }
        VStack {
            Text("Choose days for your habit:")
                .bold()
            Spacer()
            List{
                ForEach(allDays, id: \.self) { day in
                    Button(action: {
                        if selectedDays.contains(day) {
                            selectedDays.removeAll { $0 == day }
                        } else {
                            selectedDays.append(day)
                        }
                    }) {
                        HStack {
                            
                            Image(systemName: selectedDays.contains(day) ? "checkmark.square" : "square")
                                .padding()
                            Text("\(day)")
                            Spacer()
                        }
                    }
                    .foregroundColor(.black)
                }
            }
        }
        VStack{
            Text("Please add Category of your Habbit!")
                .padding()
            TextField("Your Habbit", text: $habbit)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button("Save"){
                habbitVm.addHabbit(title: habbit, scheduledDays: selectedDays)
                habbit = ""
                selectedDays = []
            }
            .foregroundColor(.mint)
            .bold()
            .padding()
            
        }
    }
}

/*#Preview {
    AddHabitView()
}*/
