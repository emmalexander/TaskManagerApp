import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()
    
    @State private var showSignUp = false
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [Color.accentColor.opacity(0.8), Color.accentColor.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                Text("Welcome Back")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                // Form Card
                VStack(spacing: 20) {
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    
                    LoadingButton(
                        title: "Sign In",
                        backgroundColor: .accentColor,
                        isLoading: $viewModel.isLoading
                    ) {
                        viewModel.signIn()
                    }
                    
                    Button {
                        showSignUp.toggle()
                    } label: {
                        Text("Don't have an account? Sign Up")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
                .padding(30)
                .background(.regularMaterial)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 10)
                
                Spacer()
            }
            .padding(.top, 60)
            .padding(.horizontal)
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showSignUp){
            SignUpView()
        }
        .navigationDestination(isPresented: $viewModel.signInSuccess) {
            MainTabView()
                .navigationBarBackButtonHidden(true)
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

#Preview {
    SignInView()
}
