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
        ZStack{
            Image("HabbitLoop-loggo")
                .resizable()
                .frame(width: 200, height: 100)
        }
        Spacer()
            
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
                .foregroundColor(.white)
                .bold()
                .padding(.bottom)
                
                Text("Don´t have an account yet?")
                    .padding(.bottom)
                Button("Sign up"){
                    
                    auth.createUser(userName: userName, email: email, password: password)
                    
                }
                .foregroundColor(.white)
                .bold()
                .padding()
                
                
            }.onAppear {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error = error {
                        print("Notis-tillstånd misslyckades: \(error.localizedDescription)")
                    } else {
                        print("Notis-tillstånd beviljat: \(granted)")
                    }
                }
            }
            .padding()
            .background(Color.mint.opacity(0.5))
            Spacer()
    }
}
struct RootView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject var habbitVm = HabbitViewModel()

    var body: some View {
        if auth.isLoggedIn {
            HabbitView(habbitVm: HabbitViewModel(), authVm: auth)
            
        } else {
            ContentView()
        }
    }
}

#Preview {
    ContentView()
}
