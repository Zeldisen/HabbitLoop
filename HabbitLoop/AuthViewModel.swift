//
//  AuthViewModel.swift
//  HabbitLoop
//
//  Created by Jeanette Norberg on 2025-04-29.
//

import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    
    @Published var isLoggedIn = false
    
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password ){
            result, error in
            if let _ = result {
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                }
            }
        }
    }
    
    func createUser(email: String, password: String ){
        Auth.auth().createUser(withEmail: email, password: password){
            result, error in
            if let _ = result {
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                }
            }
        }
    }
}
