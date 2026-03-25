import Foundation
import SwiftUI
import Combine

class TokenManager: ObservableObject {
    static let shared = TokenManager()
    
    private let accessService = "com.taskmanagerapp.access"
    private let refreshService = "com.taskmanagerapp.refresh"
    private let account = "userAuth"
    
    @Published var token: String? {
        didSet {
            if let token = token, let data = token.data(using: .utf8) {
                KeychainHelper.standard.save(data, service: accessService, account: account)
            } else {
                KeychainHelper.standard.delete(service: accessService, account: account)
            }
        }
    }
    
    @Published var refreshToken: String? {
        didSet {
            if let token = refreshToken, let data = token.data(using: .utf8) {
                KeychainHelper.standard.save(data, service: refreshService, account: account)
            } else {
                KeychainHelper.standard.delete(service: refreshService, account: account)
            }
        }
    }
    
    @Published var sessionExpiredAlert = false
    
    private init() {
        if let data = KeychainHelper.standard.read(service: accessService, account: account),
           let savedToken = String(data: data, encoding: .utf8) {
            self.token = savedToken
        }
        
        if let data = KeychainHelper.standard.read(service: refreshService, account: account),
           let savedToken = String(data: data, encoding: .utf8) {
            self.refreshToken = savedToken
        }
        
        // Clean up legacy UserDefaults
        UserDefaults.standard.removeObject(forKey: "auth_token")
    }
    
    func saveTokens(accessToken: String, refreshToken: String?) {
        self.token = accessToken
        if let rt = refreshToken {
            self.refreshToken = rt
        }
    }
    
    func checkTokenValidity() -> Bool {
        guard let token = token else { return false }
        
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else {
            return false // Let API logic handle refresh instead of clearing outright here
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
            return false
        }
        
        let expirationDate = Date(timeIntervalSince1970: exp)
        if Date() >= expirationDate {
            return false // Return false so API layer can handle refreshing
        }
        
        return true
    }
    
    func clearTokenAndAlert() {
        DispatchQueue.main.async {
            self.token = nil
            self.refreshToken = nil
            self.sessionExpiredAlert = true
        }
    }
    
    func logOut() {
        DispatchQueue.main.async {
            self.token = nil
            self.refreshToken = nil
        }
    }
}
