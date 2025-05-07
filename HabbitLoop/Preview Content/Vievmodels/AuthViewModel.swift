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
   
    func signOut() {
        do {
            try Auth.auth().signOut()
            print("User is signed out")
            self.isLoggedIn = false
            
        } catch {
            print("failed to sign out: \(error.localizedDescription)")
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
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void){
        guard let user = Auth.auth().currentUser else {
               completion(.failure(NSError(domain: "Ingen användare inloggad", code: 0)))
               return
           }
        
        let db = Firestore.firestore()
        let uid = user.uid
        
        // Remove users data
        let userCollections = ["habits", "trophies", "users"]
        
        let group = DispatchGroup()
        var deletionError: Error? = nil
        
        for collection in userCollections {
            group.enter()
            db.collection(collection).whereField("userId", isEqualTo: uid).getDocuments { snapshot, error in
                if let error = error {
                    deletionError = error
                    group.leave()
                    return
                }
                
                snapshot?.documents.forEach { document in
                    db.collection(collection).document(document.documentID).delete()
                }
                group.leave()
            }
            group.notify(queue: .main) {
                if let error = deletionError {
                    completion(.failure(error))
                } else {
                    user.delete { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                }
            }
        }
    }
}
