//
//  ContentView.swift
//  HabbitLoop
//
//  Created by Jeanette Norberg on 2025-04-29.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct ContentView: View {
    
    @State var userName: String = ""
    @State var email: String = ""
    @State var password: String = ""
    
    var auth = Auth.auth()
    
    var body: some View {
        VStack {
            TextField("User name", text: $userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: 300)
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: 300)
            TextField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: 300)
                                .padding(.bottom)
            Button("Sign in "){
                auth.signIn(withEmail: email, password: password){ reuslt, error in
                    if let error = error {
                        print("failed to sign in \(error.localizedDescription)")
                    }
                    
                }
                
            }
            .padding(.bottom)
            Text("Don´t have an account yet?")
                .padding(.bottom)
            Button("Sign up"){
                auth.createUser(withEmail: email, password: password) { result , error in
                    if let error = error {
                        print("failed to create user: \(error.localizedDescription)")
                    }
                }
            }
                
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
