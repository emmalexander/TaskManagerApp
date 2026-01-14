import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    //@Environment(\.dismiss) var dismiss
    @State private var showSignIn = false
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [Color.green.opacity(0.8), Color.blue.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    Text("Create Account")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    // Form Card
                    VStack(spacing: 20) {
                        
                        CustomTextFieldView(hintText: "Full Name", text: $viewModel.fullName, textCapitalization: .words)
                        
                        CustomTextFieldView(hintText: "Phone number", text: $viewModel.phoneNumber, keyboardType: .phonePad, maxLength: 11)
                        
                        CustomTextFieldView(hintText: "Email", text: $viewModel.email, keyboardType: .emailAddress, contentType: .emailAddress)
                        
                        SecureField("Password", text: $viewModel.password)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                        
                        LoadingButton(
                            title: "Sign Up",
                            backgroundColor: .green,
                            isLoading: $viewModel.isLoading
                        ) {
                            viewModel.signUp()
                        }
                        
                        Button {
                            showSignIn.toggle()
                        } label: {
                            Text("Already have an account? Sign In")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
                    }
                    .padding(30)
                    .background(.regularMaterial)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 10)
                    
                    //Spacer()
                }
            }
            .padding(.top, 20)
            .padding(.horizontal)
            .navigationDestination(isPresented: $showSignIn) {
                SignInView()
            }
            .alert("Success", isPresented: $viewModel.signUpSuccess) {
                Button("OK") {
                    showSignIn = true
                }
            } message: {
                Text("Account created successfully!")
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.errorMessage = nil }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
}

#Preview {
    SignUpView()
}
