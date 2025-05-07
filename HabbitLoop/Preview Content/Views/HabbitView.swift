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
    
    enum ViewMode {
        case daily, weekly, monthly
    }
    
    @State private var currentView: ViewMode = .daily
    @State private var showAddHabit = false
    @State private var showTrophies = false
    
    var body: some View {
        
        VStack {
              Image("HabbitLoop-loggo")
                  .resizable()
                  .frame(width: 200, height: 100)
              Text("Welcome \(authVm.userName)!")
                  .font(.title)
                  .padding(.bottom)
            HStack{
                Button("🏆"){
                    showTrophies = true
                }
                .padding(.horizontal)
                Button("Add Habit") {
                    showAddHabit = true
                }
                .bold()
                .foregroundColor(.mint)
            }
             
              .sheet(isPresented: $showAddHabit) {
                  AddHabitView(habbitVm: habbitVm, authVm: authVm)
              }
              .sheet(isPresented: $showTrophies){
                  TrophyView(habbitVm: habbitVm)
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
