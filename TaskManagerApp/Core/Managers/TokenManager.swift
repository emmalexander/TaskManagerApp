import Foundation
import SwiftUI
import Combine

class TokenManager: ObservableObject {
    static let shared = TokenManager()
    
    @Published var token: String? {
        didSet {
            if let token = token {
                UserDefaults.standard.set(token, forKey: "auth_token")
            } else {
                UserDefaults.standard.removeObject(forKey: "auth_token")
            }
            UserDefaults.standard.synchronize()
        }
    }
    
    @Published var sessionExpiredAlert = false
    
    private init() {
        self.token = UserDefaults.standard.string(forKey: "auth_token")
    }
    
    func saveToken(_ newToken: String) {
        self.token = newToken
    }
    
    func checkTokenValidity() -> Bool {
        guard let token = token else { return false }
        
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else {
            clearTokenAndAlert()
            return false
        }
        
        let base64Token = parts[1]
        var base64 = base64Token.replacingOccurrences(of: "-", with: "+")
                              .replacingOccurrences(of: "_", with: "/")
        
        let length = Double(base64.count)
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = String(repeating: "=", count: Int(paddingLength))
            base64 += padding
        }
        
        guard let payloadData = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
              let exp = json["exp"] as? Double else {
            clearTokenAndAlert()
            return false
        }
        
        let expirationDate = Date(timeIntervalSince1970: exp)
        if Date() >= expirationDate {
            clearTokenAndAlert()
            return false
        }
        
        return true
    }
    
    func clearTokenAndAlert() {
        DispatchQueue.main.async {
            self.token = nil
            self.sessionExpiredAlert = true
        }
    }
    
    func logOut() {
        DispatchQueue.main.async {
            self.token = nil
        }
    }
}
