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
    @State private var notify = false    // for reminder
    @State private var reminderTime = Date() // for reminder
    
    
    var timeFormatter: DateFormatter {  // for reminder
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    let allDays = ["Måndag", "Tisdag", "Onsdag", "Torsdag", "Fredag", "Lördag", "Söndag"]
 
    var body: some View {
        VStack{
            Image("HabbitLoop-loggo")
                .resizable()
                .frame(width: 200, height: 100)
            Text("Welcome \(authVm.userName)!" )
                .font(.title)
                .padding(.bottom)
            
            Form {
                TextField("Habit-titel", text: $habbit)
                
                Toggle("Reminde me ", isOn: $notify)
                
                if notify {
                    DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                }
            }

        }
        VStack {
       
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
           
            TextField("Your Habbit", text: $habbit)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button("Save"){
                let formattedTime = timeFormatter.string(from: reminderTime)
                   habbitVm.addHabbit(
                       title: habbit,
                       scheduledDays: selectedDays,
                       notify: notify,
                       reminderTime: notify ? formattedTime : nil
                   )
                if notify {
                    habbitVm.scheduleNotification(title: habbit, time: reminderTime, weekdays: selectedDays)
                   }
              
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
