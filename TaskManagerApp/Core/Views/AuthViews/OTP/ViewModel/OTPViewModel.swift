import Foundation
import Combine

@MainActor
class OTPViewModel: ObservableObject {
    @Published var otp = ""
    @Published var errorMessage: String? = nil
    @Published var isVerified = false
    @Published var isLoading = false
    @Published var timeRemaining = 300 // 5 minutes representing 300 seconds
    
    private var timer: Timer?
    let email: String
    private let apiService = APIService.shared
    
    init(email: String) {
        self.email = email
        startTimer()
    }
    
    func startTimer() {
        timeRemaining = 300
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.timer?.invalidate()
                }
            }
        }
    }
    
    func verifyOTP() {
        guard otp.count == 6 else {
            errorMessage = "Please enter a 6-digit code."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let success = try await apiService.verifyOTP(email: email, otp: otp)
                if success {
                    isVerified = true
                }
            } catch {
                errorMessage = error.localizedDescription
                print("DEBUG: OTP Verification error: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
    
    func resendCode() {
        guard timeRemaining == 0 else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let success = try await apiService.resendOTP(email: email)
                if success {
                    startTimer()
                }
            } catch {
                errorMessage = error.localizedDescription
                print("DEBUG: Resend OTP error: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
    
    var timerDisplay: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
