//
//  AuthViewModel.swift
//  HabbitLoop
//
//  Created by Jeanette Norberg on 2025-04-29.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class AuthViewModel: ObservableObject {
    
    @Published var isLoggedIn = false
    @Published var userName: String = ""
    
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password ){
            result, error in
            if let _ = result {
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                    self.fetchUserData()
                }
            }
        }
    }
    
    func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data(), let name = data["userName"] as? String {
                DispatchQueue.main.async {
                    self.userName = name
                }
            }
        }
    }
    
    func createUser(userName: String, email: String, password: String ){
        Auth.auth().createUser(withEmail: email, password: password){ result, error in
            if let result = result {
                let uid = result.user.uid
                let db = Firestore.firestore()
                
                // Spara användarens namn i Firestore
                db.collection("users").document(uid).setData([
                    "userName": userName,
                    "email": email
                ]) { error in
                    if let error = error {
                        print("Error saving user data: \(error)")
                    } else {
                        DispatchQueue.main.async {
                            self.isLoggedIn = true
                        }
                    }
                }
            } else {
                print("Auth error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
