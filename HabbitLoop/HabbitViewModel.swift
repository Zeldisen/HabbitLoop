//
//  HabbitViewModel.swift
//  HabbitLoop
//
//  Created by Jeanette Norberg on 2025-04-29.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class HabbitViewModel: ObservableObject {
    
    @Published var habits: [Habit] = []
    
    let db = Firestore.firestore()
    
    func addHabbit(title: String) {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        let newHabit = Habit(title: title, done: false, userId: userId)

           do {
               try db.collection("habits").addDocument(from: newHabit)
           } catch {
               print("Error saving to Firestore: \(error)")
           }
        }
    
    func fetchHabits () {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        
        db.collection("habits")
              .whereField("userId", isEqualTo: userId)
              .addSnapshotListener { snapshot, error in
                  guard let documents = snapshot?.documents else { return }
                  self.habits = documents.compactMap { try? $0.data(as: Habit.self) }
              }
    }
    
    
}
    

