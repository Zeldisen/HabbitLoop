//
//  TrophyView.swift
//  HabbitLoop
//
//  Created by Jeanette Norberg on 2025-05-07.
//

import SwiftUI

struct TrophyBadge: View {
let emoji: String
let count: Int

var body: some View {
    VStack {
        Text(emoji)
            .font(.largeTitle)
        Text("\(count)")
            .font(.title2)
    }
    .frame(width: 60, height: 80)
    .background(Color.mint.opacity(0.1))
    .cornerRadius(12)
}
}


struct TrophyView: View {
    @ObservedObject var habbitVm: HabitViewModel
    
    var body: some View {
        NavigationView {
           
            ScrollView{
                
                VStack{
                    Image("Habit-Loop")
                        .resizable()
                        .frame(width: 200, height: 100)
                    
                    Text("Your trophys collection!")
                        .font(.title2)
                        .foregroundColor(.mint)
                    
                    HStack(spacing: 20) {
                                           TrophyBadge(emoji: "🥉", count: habbitVm.trophys.bronze)
                                           TrophyBadge(emoji: "🥈", count: habbitVm.trophys.silver)
                                           TrophyBadge(emoji: "🥇", count: habbitVm.trophys.gold)
                                           TrophyBadge(emoji: "🏆", count: habbitVm.trophys.cup)
                                       }
                                       .padding(.bottom)
                }
                    ForEach(habbitVm.habits) { habit in
                                          let streak = habit.days
                        let trophy: String = {
                            switch streak {
                            case 100...:
                                return "🏆"
                            case 30...90:
                                return "🥇"
                            case 7..<26:
                                return "🥈"
                            case 1..<5:
                                return "🥉"
                            default:
                                return ""
                            }
                        }()
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(habit.title)
                                    .font(.headline)
                                    .padding(.horizontal)
                                if (habit.days >= 1){
                                    Text("💪 Keep up your good work!")
                                }
                                if  (habit.days <= 0 ){
                                    Text("Don´t give up! you can still get a trohpy!")
                                }
                            }
                                                    HStack {
                                                        Text("Streak: \(streak) dagar")
                                                        Spacer()
                                                        Text(trophy)
                                                            .font(.title)
                                                    }
                                                    .padding(.horizontal)
                                                }
                                                .padding()
                                                .background(Color.mint.opacity(0.1))
                                                .cornerRadius(10)
                                            }
                                        }
                                        .padding()
                                    }
                                 
    }
        
            }
        
    


/*#Preview {
    TrophyView()
}*/
