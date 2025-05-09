//
//  SettingsView.swift
//  HabbitLoop
//
//  Created by Jeanette Norberg on 2025-05-09.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var authVm: AuthViewModel
    @State private var showDeleteAlert = false
    @State private var deleteErrorMessage: String? = nil
    @State var newUserName: String = ""
    @State private var message = ""
    
    var body: some View {

        VStack{
            Image("Habit-Loop")
                .resizable()
                .frame(width: 200, height: 100)
                .padding()
            Text("\(authVm.userName)s settings")
                .font(.title)
                Spacer()
            
      
            TextField("Change User name", text: $newUserName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxWidth: 300)
            Button {
                 authVm.updateUserName(to: newUserName) { result in
                    switch result {
                    case .success:
                        message = "User name updated!"
                    case .failure(let error):
                        message = "Failed to update user name: \(error.localizedDescription)"
                    }
                     newUserName = ""
                }
            } label: { Label("Save", systemImage: "square.and.arrow.down")
            }
            .font(.title)
            .foregroundColor(.mint)
            .padding()
            Button {
                authVm.signOut()
            } label: { Label("Sign out", systemImage: "door.left.hand.open")
            }
            .font(.title)
            .foregroundColor(.mint)
            .padding()
            Button {
                showDeleteAlert = true
            } label: { Label("Delete account", systemImage: "trash")
            }
                .font(.title)
                .foregroundColor(.mint)
                .padding()
                .alert("Are you sure you want to delete your account?", isPresented: $showDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        authVm.deleteAccount { result in
                            switch result {
                            case .success:
                                authVm.signOut()
                                print("Account deleted")
                                // user logs out
                            case .failure(let error):
                                deleteErrorMessage = error.localizedDescription
                            }
                        }
                    }
                    Button("Abort", role: .cancel) { }
                } message: {
                    Text("Can´t regret this. Al data will be lost.")
                }
            Spacer()
        }
    }
}

#Preview {
    SettingsView(authVm: AuthViewModel())
}
