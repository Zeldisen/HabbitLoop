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
    @State var selectedDays: [String] = []
    
   // let allDays = ["Måndag", "Tisdag", "Onsdag", "Torsdag", "Fredag", "Lördag", "Söndag"]
    
    enum ViewMode {
        case daily, weekly, monthly
    }
    
    @State private var currentView: ViewMode = .daily
    @State private var showAddHabit = false
    
    var body: some View {
        
        VStack {
              Image("HabbitLoop-loggo")
                  .resizable()
                  .frame(width: 200, height: 100)
              Text("Welcome \(authVm.userName)!")
                  .font(.title)
                  .padding(.bottom)
              
              Button("Add Habit") {
                  showAddHabit = true
              }
              .bold()
              .foregroundColor(.mint)
              Spacer()
              .sheet(isPresented: $showAddHabit) {
                  AddHabitView(habbitVm: habbitVm, authVm: authVm)
              }

          
            switch currentView {
            case .daily:
                DailyView(habbitVm: habbitVm)
            case .weekly:
                WeeklyView(habbitVm: habbitVm)
            case .monthly:
                MonthlyView(habitVm: habbitVm)
            }
            Spacer()
                .toolbar{
                    ToolbarItem(placement: .bottomBar){
                        HStack{
                            Button("Daily"){
                                currentView = .daily
                            }
                            .foregroundColor(.mint)
                            .bold()
                            .padding()
                            Spacer()
                            Button("Weekly"){
                                currentView = .weekly
                            }
                            .foregroundColor(.mint)
                            .bold()
                            .padding()
                            Spacer()
                            Button("Month"){
                                currentView = .monthly
                            }
                            .foregroundColor(.mint)
                            .bold()
                            .padding()
                        }
                        
                    }
                    
                }
            
        }
    }
}

/*#Preview {
    HabbitView()
}*/
