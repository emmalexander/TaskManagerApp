import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    
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
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    
                    Button {
                        // Action
                    } label: {
                        Text("Sign In")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.accentColor)
                            .cornerRadius(12)
                    }
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
    }
}

#Preview {
    SignInView()
}
