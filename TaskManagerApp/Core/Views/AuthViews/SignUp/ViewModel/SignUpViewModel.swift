import Foundation
import Combine

@MainActor
class SignUpViewModel: ObservableObject {
    @Published var fullName = ""
    @Published var email = ""
    @Published var phoneNumber = ""
    @Published var password = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var signUpSuccess = false
    
    private let apiService = APIService.shared
    
    func signUp() {
        guard !fullName.isEmpty, !phoneNumber.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            return
        }
        
        if !fullName.contains(" "){
            errorMessage = "Please enter a valid full name"
            print("1")
            return
        }
        
        if fullName.contains(" "){
            if !(fullName.split(separator: " ").count == 2) {
                print("2")
                errorMessage = "Please enter a valid full name"
                return
            } else {
                let firstName = fullName.split(separator: " ")[0]
                let lastName = fullName.split(separator: " ")[1]
                if firstName.count < 3 || lastName.count < 3{
                    print("3")
                    errorMessage = "Please enter a valid full name"
                    return
                }
            }
        }
        
        guard fullName.contains(" ") else { return }
        
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email"
            return
        }
        
        guard phoneNumber.count == 11 else {
            errorMessage = "Please enter a valid phone number"
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let firstName = fullName.split(separator: " ")[0]
        let lastName = fullName.split(separator: " ")[1]
        
        let userData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "phoneNumber": phoneNumber,
            "email": email,
            "password": password
        ]
        
        Task {
            do {
                let success = try await apiService.signUp(userData: userData)
                if success {
                    signUpSuccess = true
                     print("DEBUG: Sign up successful")
                }
            } catch {
                errorMessage = error.localizedDescription
                print("DEBUG: Sign up error: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    }
}
