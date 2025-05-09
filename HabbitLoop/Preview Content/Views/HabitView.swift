//
//  HabbitView.swift
//  HabbitLoop
//
//  Created by Jeanette Norberg on 2025-04-29.
//

import SwiftUI


struct HabitView: View {
    
    @ObservedObject var habbitVm: HabitViewModel
    @ObservedObject var authVm: AuthViewModel
    
    @State var habbit: String = ""
    @State var selectedDays: [String] = []
    
    enum ViewMode {
        case daily, weekly, monthly
    }
    
    @State private var currentView: ViewMode = .daily
    @State private var showAddHabit = false
    @State private var showTrophies = false
    @State private var showSettings = false
    
    @State private var showDeleteAlert = false
    @State private var deleteErrorMessage: String? = nil
    
    var body: some View {
        
        VStack {
            
                Image("Habit-Loop")
                    .resizable()
                    .frame(width: 200, height: 100)
                    .padding()
               
            
                Text("Welcome \(authVm.userName)!")
                    .font(.title)
                    .padding(.bottom)
              
                  
            
            HStack{
                Button {
                    showSettings = true
                } label: { Label("", systemImage: "gearshape")
                }
                    .font(.title)
                    .foregroundColor(.mint)
                    .padding(.horizontal)
                  
                Button {
                    showTrophies = true
                } label: {
                    Label("", systemImage: "trophy")
                }
                .font(.title)
                .foregroundColor(.mint)
                .padding(.horizontal)
                
                Button {
                    showAddHabit = true
                } label: {
                    Label("", systemImage: "plus.circle")
                }
                .font(.title)
                .foregroundColor(.mint)
                .padding(.horizontal)
            }
            }
             
              .sheet(isPresented: $showAddHabit) {
                  AddHabitView(habbitVm: habbitVm, authVm: authVm)
              }
              .sheet(isPresented: $showTrophies){
                  TrophyView(habbitVm: habbitVm)
              }
              .sheet(isPresented: $showSettings){
                  SettingsView(authVm: authVm)
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


/*#Preview {
    HabbitView()
}*/
