import Foundation
import Combine

@MainActor
class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var signInSuccess = false
    @Published var showVerificationAlert = false
    @Published var navigateToOTP = false
    
    private let apiService = APIService.shared
    
    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let userData: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        Task {
            do {
                let success = try await apiService.signIn(userData: userData)
                if success {
                    signInSuccess = true
                    //print("DEBUG: Sign in successful")
                }
            } catch {
                if error.localizedDescription == "Email not verified. Please verify your email before signing in." {
                    showVerificationAlert = true
                } else {
                    errorMessage = error.localizedDescription
                }
                //print("DEBUG: Sign in error: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    }
}
