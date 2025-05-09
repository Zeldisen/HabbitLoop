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
   
    @Published var isLoggedIn = false     // to check witch view shall show, and if user is deleting account.
    @Published var userName: String = ""  // just to print username for welcome user, There for it i not in a model.
    
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
    func StayLoggedIn() {
        if Auth.auth().currentUser != nil {
            self.isLoggedIn = true
            self.fetchUserData()
        } else {
            self.isLoggedIn = false
        }
    }
   // used when user delete account to sign out and user have no longer access, unless user creates a new account, can also be in use if a sign out button adds to a view.
    func signOut() {
        do {
            try Auth.auth().signOut()
            print("User is signed out")
            self.isLoggedIn = false
            
        } catch {
            print("failed to sign out: \(error.localizedDescription)")
        }
    }
    
    // get userData
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
    // user don´t have any account yet, user needs to be created at auth and firestore, in order to have access of habit loops functions.
    func createUser(userName: String, email: String, password: String ){
        Auth.auth().createUser(withEmail: email, password: password){ result, error in
            if let result = result {
                let uid = result.user.uid
                let db = Firestore.firestore()
                
                // Save user name and email in Firestore
                db.collection("users").document(uid).setData([
                    "userName": userName,
                    "email": email
                ]) { error in
                    if let error = error {
                        print("Error saving user data: \(error)")
                    } else {
                        DispatchQueue.main.async {
                            self.isLoggedIn = true  // when user is loggedin dailyview shows
                        }
                    }
                }
            } else {
                print("Auth error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    func updateUserName(to newUserName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user is inlogged", code: 0)))
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(uid).updateData([
            "userName": newUserName
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                DispatchQueue.main.async {
                    self.userName = newUserName
                }
                completion(.success(()))
            }
        }
    }
    /**
     When function calls it starts to remove data, when it´s done, then completion calls thanks of escapimg to finish work, escaping is used to call completion beacause deleteAccount has already returned and is no longer in scope.
     Funtion removes users data, like habits and more, then it delete user account, and send sucess or error if something goes wrong.
     */
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void){
        guard let user = Auth.auth().currentUser else {
               completion(.failure(NSError(domain: "No user is inlogged", code: 0)))
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
