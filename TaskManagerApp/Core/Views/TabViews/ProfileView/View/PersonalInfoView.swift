//
//  PersonalInfoView.swift
//  TaskManagerApp
//

import SwiftUI

struct PersonalInfoView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var mainTabViewModel: MainTabViewModel
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = "" // Non-editable by default in many apps, but shown
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    HStack {
                        Text("First Name")
                            .foregroundStyle(.secondary)
                        Spacer()
                        TextField("First Name", text: $firstName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Last Name")
                            .foregroundStyle(.secondary)
                        Spacer()
                        TextField("Last Name", text: $lastName)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Contact Information") {
                    HStack {
                        Text("Email")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(email)
                            .foregroundStyle(.tertiary)
                    }
                    
                    HStack {
                        Text("Phone")
                            .foregroundStyle(.secondary)
                        Spacer()
                        TextField("Optional", text: $phoneNumber)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.phonePad)
                    }
                }
            }
            .navigationTitle("Personal Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        mainTabViewModel.updateUser(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber)
                        dismiss()
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty)
                }
            }
            .onAppear {
                if let user = mainTabViewModel.user {
                    firstName = user.firstName
                    lastName = user.lastName
                    email = user.email
                    phoneNumber = user.phoneNumber ?? ""
                }
            }
        }
    }
}

#Preview {
    PersonalInfoView()
        .environmentObject(MainTabViewModel())
}
