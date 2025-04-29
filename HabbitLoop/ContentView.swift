//
//  ContentView.swift
//  HabbitLoop
//
//  Created by Jeanette Norberg on 2025-04-29.
//

import SwiftUI
import Firebase
//import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var auth: AuthViewModel
    
    @State var userName: String = ""
    @State var email: String = ""
    @State var password: String = ""
    
    //var auth = Auth.auth()
    
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
                
                auth.login(email: email, password: password)
                
            }
            .padding(.bottom)
            Text("Don´t have an account yet?")
                .padding(.bottom)
            Button("Sign up"){
                
                auth.createUser(email: email, password: password)
                
            }
                
            
        }
        .padding()
    }
}
struct RootView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        if auth.isLoggedIn {
            HabbitView(habbitVm: HabbitViewModel())
        } else {
            ContentView()
        }
    }
}

#Preview {
    ContentView()
}
