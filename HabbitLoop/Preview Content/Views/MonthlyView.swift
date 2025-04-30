//
//  MonthlyView.swift
//  HabbitLoop
//
//  Created by Jeanette Norberg on 2025-04-30.
//

import SwiftUI

struct MonthlyView: View {
    // Skapa en referens till dagens datum och dagens månad
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date?
    
    // För att hålla reda på de dagar där habits är gjorda (exempelvis med ett array av datum)
    var habitsDoneOn: [Date] = []  // Fyll i med datum där habit har blivit utfört
    
    // Funktion för att få dagar i en månad
    private func getDaysInMonth(for date: Date) -> [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    // Markera om en dag har ett habit
    private func isHabitDone(for date: Date) -> Bool {
        return habitsDoneOn.contains { Calendar.current.isDate($0, inSameDayAs: date) }
    }
    
    var body: some View {
        VStack {
            // Välj månad
            HStack {
                Button(action: {
                    currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
                }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.title)
                }
                
                Text("\(currentMonth, formatter: monthFormatter)")
                    .font(.title)
                
                Button(action: {
                    currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title)
                }
            }
            .padding()

            // Visa alla dagar i månaden
            let daysInMonth = getDaysInMonth(for: currentMonth)
            let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 7)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(daysInMonth, id: \.self) { day in
                    Button(action: {
                        selectedDate = day
                    }) {
                        Text("\(Calendar.current.component(.day, from: day))")
                            .frame(width: 30, height: 30)
                            .background(isHabitDone(for: day) ? Color.green : Color.clear)
                            .clipShape(Circle())
                            .foregroundColor(isHabitDone(for: day) ? .white : .black)
                    }
                }
            }
            .padding()
        }
    }
    
    // Formattera datumet till en månad/år format
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}


#Preview {
    MonthlyView()
}
