//
//  WeeklyView.swift
//  HabbitLoop
//
//  Created by Jeanette Norberg on 2025-04-30.
//

import SwiftUI

struct WeeklyView: View {
    @ObservedObject var habbitVm: HabbitViewModel
    let daysOrder = ["Måndag", "Tisdag", "Onsdag", "Torsdag", "Fredag", "Lördag", "Söndag"]

    var body: some View {
        NavigationView {
            List {
                ForEach(daysOrder, id: \.self) { day in
                    Section(header: Text(day).font(.headline)) {
                        let habitsForDay = habbitVm.habits.filter { $0.scheduledDays.contains(day) }
                        if habitsForDay.isEmpty {
                            Text("Inga vanor planerade.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(habitsForDay) { habit in
                                HStack {
                                    Text("• \(habit.title)")
                                    Spacer()
                                    Button(action: {
                                        habbitVm.toggleDone(for: habit)
                                    }) {
                                        Image(systemName: habit.done ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(.mint)
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button {
                                        habbitVm.deleteHabit(habit, day: day)
                                    } label: {
                                        Label("Endast denna dag", systemImage: "calendar.badge.minus")
                                    }
                                    .tint(.orange)

                                    Button(role: .destructive) {
                                        habbitVm.deleteHabit(habit)
                                    } label: {
                                        Label("Ta bort helt", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Veckoöversikt")
        }
        .onAppear {
            habbitVm.fetchHabits()
        }
    }
}
