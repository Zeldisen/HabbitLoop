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
    
    @State private var showDeleteAlert = false
    @State private var deleteErrorMessage: String? = nil
    
    var body: some View {
        
        VStack {
              Image("Habit-Loop")
                  .resizable()
                  .frame(width: 200, height: 100)
              Text("Welcome \(authVm.userName)!")
                  .font(.title)
                  .padding(.bottom)
            HStack{
                Button {
                    showDeleteAlert = true
                } label: { Label("", systemImage: "trash")
                }
                    .font(.title)
                    .foregroundColor(.mint)
                    .padding(.horizontal)
                    .alert("Are you sure you want to delete your account?", isPresented: $showDeleteAlert) {
                        Button("Delete", role: .destructive) {
                            authVm.deleteAccount { result in
                                switch result {
                                case .success:
                                    authVm.signOut()
                                    print("Account deleted")
                                    // user logs out
                                case .failure(let error):
                                    deleteErrorMessage = error.localizedDescription
                                }
                            }
                        }
                        Button("Abort", role: .cancel) { }
                    } message: {
                        Text("Can´t regret this. Al data will be lost.")
                    }
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
