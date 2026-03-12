import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(description: String)
    case decodingFailed
    case unableToDecode(error: Error)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let description):
            return description
        case .decodingFailed:
            return "Failed to decode response"
        case .unableToDecode(let error):
            return "Unable to decode: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

struct ErrorResponse: Decodable {
    let message: String?
    let error: String?
}

class APIService {
    static let shared = APIService()
    
    private init() {}
    
    static let baseURL =  "http://192.168.1.155:5500/api/v1/" //192.168.1.155
    
    private let signUpURL: String =  baseURL + "auth/sign-up"
    private let signInURL: String =  baseURL + "auth/sign-in"
    private let getUserUrl: String =  baseURL + "users/"
    
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
        
        return try await performRequest(request, requireAuth: false)
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
        
        print("➡️ [API Request] \(request.httpMethod ?? "UNKNOWN") \(request.url?.absoluteString ?? "No URL")")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.requestFailed(description: "Invalid response")
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                // Save the token
                TokenManager.shared.saveToken(authResponse.data.token)
                return true
            } catch {
                throw APIError.unableToDecode(error: error)
            }
        } else {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                let errorMessage = errorResponse.error ?? errorResponse.message ?? "Unknown error"
                throw APIError.requestFailed(description: errorMessage)
            }
            throw APIError.requestFailed(description: "Server returned \(httpResponse.statusCode)")
        }
    }
    
    func getUser() async throws -> GetUserResponse {
        guard let url = URL(string: getUserUrl) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = TokenManager.shared.token {
            if !TokenManager.shared.checkTokenValidity() {
                throw APIError.requestFailed(description: "Session Expired. Please sign in again.")
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
//        print("➡️ [API Request] \(request.httpMethod ?? "UNKNOWN") \(request.url?.absoluteString ?? "No URL")")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.requestFailed(description: "Invalid response")
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
             print("📄 [API Data] \(responseString)")
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            do {
                let response = try JSONDecoder.apiDecoder.decode(GetUserResponse.self, from: data)
                return response
            } catch {
                if let decodingError = error as? DecodingError {
                    print("❌ [Decoding Error] \(decodingError)")
                }
                throw APIError.unableToDecode(error: error)
            }
        } else {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                let errorMessage = errorResponse.error ?? errorResponse.message ?? "Unknown error"
                throw APIError.requestFailed(description: errorMessage)
            }
            throw APIError.requestFailed(description: "Server returned \(httpResponse.statusCode)")
        }
    }
    
    /// Performs a generic request, optionally adding Auth header if token is available
    private func performRequest(_ request: URLRequest, requireAuth: Bool = true) async throws -> Bool {
        var authRequest = request
        
        if requireAuth {
            // Inject token if it exists and is valid
            if let token = TokenManager.shared.token {
                if !TokenManager.shared.checkTokenValidity() {
                    throw APIError.requestFailed(description: "Session Expired. Please sign in again.")
                }
                authRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        
        print("➡️ [API Request] \(authRequest.httpMethod ?? "UNKNOWN") \(authRequest.url?.absoluteString ?? "No URL")")
        if let body = authRequest.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("📝 [API Body] \(bodyString)")
        }
        
        let (data, response) = try await URLSession.shared.data(for: authRequest)
        
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
            if httpResponse.statusCode == 401 {
                 TokenManager.shared.clearTokenAndAlert()
            }
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
