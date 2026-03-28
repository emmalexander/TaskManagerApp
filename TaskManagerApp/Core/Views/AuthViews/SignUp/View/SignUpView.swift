import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @State private var showSignIn = false
    @State private var showOTPView = false
    @State private var isPasswordVisible = false
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case fullName, phoneNumber, email, password
    }
    
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
                        
                        TextField("Full Name", text: $viewModel.fullName)
                            .textInputAutocapitalization(.words)
                            .focused($focusedField, equals: .fullName)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .phoneNumber }
                            .customTextFieldStyle()
                        
                        TextField("Phone number", text: $viewModel.phoneNumber)
                            .keyboardType(.phonePad)
                            .focused($focusedField, equals: .phoneNumber)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .email }
                            .onChange(of: viewModel.phoneNumber) { oldValue, newValue in
                                if newValue.count > 11 {
                                    viewModel.phoneNumber = String(newValue.prefix(11))
                                }
                            }
                            .customTextFieldStyle()
                        
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .password }
                            .customTextFieldStyle()
                        
                        HStack {
                            if isPasswordVisible {
                                TextField("Password", text: $viewModel.password)
                                    .focused($focusedField, equals: .password)
                            } else {
                                SecureField("Password", text: $viewModel.password)
                                    .focused($focusedField, equals: .password)
                            }
                            
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .customTextFieldStyle()
                        .submitLabel(.done)
                        .onSubmit {
                            viewModel.signUp()
                        }
                        
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
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showSignIn) {
                SignInView()
            }
            .navigationDestination(isPresented: $showOTPView) {
                OTPView(email: viewModel.email)
            }
            .alert("Success", isPresented: $viewModel.signUpSuccess) {
                Button("OK") {
                    showOTPView = true
                }
            } message: {
                Text("Please verify your email.")
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
