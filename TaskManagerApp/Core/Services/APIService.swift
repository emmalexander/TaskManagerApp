import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed(description: String)
    case decodingFailed
    case unableToDecode(error: Error)
    case unknown
}

struct ErrorResponse: Decodable {
    let message: String?
    let error: String?
}

class APIService {
    static let shared = APIService()
    
    private init() {}
    
    static let baseURL =  "http://localhost:5500/api/v1/"
    
    private let signUpURL: String =  baseURL + "auth/sign-up"
    private let signInURL: String =  baseURL + "auth/sign-in"
    
    /// Signs up a user via the API
    func signUp(userData: [String: Any]) async throws -> Bool {
        guard let url = URL(string: signUpURL) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: userData, options: [])
        } catch {
            throw APIError.requestFailed(description: "Failed to encode user data")
        }
        
        return try await performRequest(request)
    }
    
    /// Signs in a user via the API
    func signIn(userData: [String: Any]) async throws -> Bool {
        guard let url = URL(string: signInURL) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: userData, options: [])
        } catch {
            throw APIError.requestFailed(description: "Failed to encode user data")
        }
        
        return try await performRequest(request)
    }
    
    private func performRequest(_ request: URLRequest) async throws -> Bool {
        print("➡️ [API Request] \(request.httpMethod ?? "UNKNOWN") \(request.url?.absoluteString ?? "No URL")")
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("📝 [API Body] \(bodyString)")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [API Error] Invalid response object")
            throw APIError.requestFailed(description: "Invalid response")
        }
        
        print("⬅️ [API Response] Status: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
             print("📄 [API Data] \(responseString)")
        }
        
        if (200...299).contains(httpResponse.statusCode) {
             return true
        } else {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                let errorMessage = errorResponse.error ?? errorResponse.message ?? "Unknown error"
                print("❌ [API Error Message] \(errorMessage)")
                 throw APIError.requestFailed(description: errorMessage)
            }
            
            let responseString = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ [API Error Raw] \(responseString)")
            throw APIError.requestFailed(description: "Server returned \(httpResponse.statusCode): \(responseString)")
        }
    }
}
