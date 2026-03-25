import SwiftUI

struct OTPView: View {
    @StateObject private var viewModel: OTPViewModel
    
    init(email: String) {
        _viewModel = StateObject(wrappedValue: OTPViewModel(email: email))
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
                    Text("Verify Email")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("Enter the 6-digit code sent to\n\(viewModel.email)")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    // Form Card
                    VStack(spacing: 20) {
                        
                        TextField("000000", text: $viewModel.otp)
                            .keyboardType(.numberPad)
                            .textContentType(.oneTimeCode)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .onChange(of: viewModel.otp) { newValue in
                                if newValue.count > 6 {
                                    viewModel.otp = String(newValue.prefix(6))
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        
                        LoadingButton(
                            title: "Verify",
                            backgroundColor: .green,
                            isLoading: $viewModel.isLoading
                        ) {
                            viewModel.verifyOTP()
                        }
                        
                        Button {
                            viewModel.resendCode()
                        } label: {
                            Text(viewModel.timeRemaining > 0 ? "Resend code in \(viewModel.timerDisplay)" : "Resend Code")
                                .font(.footnote)
                                .foregroundColor(viewModel.timeRemaining > 0 ? .secondary : .green)
                        }
                        .disabled(viewModel.timeRemaining > 0 || viewModel.isLoading)
                        .padding(.top, 4)
                    }
                    .padding(30)
                    .background(.regularMaterial)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 10)
                    
                    Spacer()
                }
                .padding(.top, 40)
                .padding(.horizontal)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $viewModel.isVerified) {
            SignInView()
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
    OTPView(email: "test@example.com")
}
