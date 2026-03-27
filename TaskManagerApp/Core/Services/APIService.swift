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
    
    static let baseURL = EnvironmentVariable.baseUrl
    
    private let signUpURL: String =  baseURL + "auth/sign-up"
    private let signInURL: String =  baseURL + "auth/sign-in"
    private let getUserUrl: String =  baseURL + "users/"
//    private let getUserTasksByStatusUrl: String =  baseURL + "status/"
    private let addTaskToFavoriteUrl: String =  baseURL + "tasks/favorites/add/"
    private let removeTaskFromFavoriteUrl: String =  baseURL + "tasks/favorites/remove/"
    private let tasksUrl: String = baseURL + "tasks/"
    private let taskListsUrl: String = baseURL + "tasks/lists/"
    private let verifyOTPUrl: String = baseURL + "auth/verify-email"
    private let resendOTPUrl: String = baseURL + "auth/resend-verification"
    
//    private let getPendingTasksUrl: String = baseURL + "tasks/pending"
//    private let getInProgressTasksUrl: String = baseURL + "tasks/in-progress"
//    private let getCompletedTasksUrl: String = baseURL + "tasks/completed"
    
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
        
        //print("➡️ [API Request] \(request.httpMethod ?? "UNKNOWN") \(request.url?.absoluteString ?? "No URL")")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.requestFailed(description: "Invalid response")
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            do {
                let authResponse = try JSONDecoder().decode(SignInResponse.self, from: data)
                
                TokenManager.shared.saveTokens(accessToken: authResponse.data.accessToken, refreshToken: authResponse.data.refreshToken)
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
    
    /// Verifies OTP for the user
    func verifyOTP(email: String, otp: String) async throws -> Bool {
        guard let url = URL(string: verifyOTPUrl) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let body: [String: Any] = ["email": email, "otp": otp]
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            throw APIError.requestFailed(description: "Failed to encode OTP data")
        }
        
        return try await performRequest(request, requireAuth: false)
    }
    
    /// Resends OTP to user's email
    func resendOTP(email: String) async throws -> Bool {
        guard let url = URL(string: resendOTPUrl) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let body: [String: Any] = ["email": email]
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            throw APIError.requestFailed(description: "Failed to encode OTP data")
        }
        
        return try await performRequest(request, requireAuth: false)
    }
    
    // MARK: - Authed Request Handling
    private func executeRequest(_ request: URLRequest, requireAuth: Bool = true) async throws -> (Data, HTTPURLResponse) {
        var finalRequest = request
        
        if requireAuth {
            if let token = TokenManager.shared.token {
                finalRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                throw APIError.requestFailed(description: "No access token available. Please sign in.")
            }
        }
        
        var (data, response) = try await URLSession.shared.data(for: finalRequest)
        var httpResponse = response as? HTTPURLResponse
        
        if requireAuth, httpResponse?.statusCode == 401 {
            do {
                try await refreshTokens()
                
                if let newToken = TokenManager.shared.token {
                    finalRequest.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
                    let retryResult = try await URLSession.shared.data(for: finalRequest)
                    data = retryResult.0
                    response = retryResult.1
                    httpResponse = response as? HTTPURLResponse
                }
            } catch {
                TokenManager.shared.clearTokenAndAlert()
                throw error
            }
        }
        
        guard let validResponse = httpResponse else {
            throw APIError.requestFailed(description: "Invalid response")
        }
        
        return (data, validResponse)
    }

    private func refreshTokens() async throws {
        guard let refreshToken = TokenManager.shared.refreshToken else {
            throw APIError.requestFailed(description: "Session Expired. Please sign in again.")
        }
        struct RefreshRequest: Encodable { let refreshToken: String }
        let urlStr = APIService.baseURL + "auth/refresh-token"
        guard let url = URL(string: urlStr) else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["refreshToken": refreshToken])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            TokenManager.shared.saveTokens(accessToken: authResponse.data.accessToken, refreshToken: authResponse.data.refreshToken)
        } else {
            // Log the
            throw APIError.requestFailed(description: "Invalid refresh token")
        }
    }
    
    func getUser() async throws -> GetUserResponse {
        guard let url = URL(string: getUserUrl) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, httpResponse) = try await executeRequest(request, requireAuth: true)
//
//        if let dataString = String(data: data, encoding: .utf8) {
//            await MainActor.run {
//                print("Received data as String: \(dataString)")
//            }
//        }
        
        if (200...299).contains(httpResponse.statusCode) {
            do {
                let response = try JSONDecoder.apiDecoder.decode(GetUserResponse.self, from: data)
                return response
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
    
    func updateUser(firstName: String, lastName: String, phoneNumber: String?) async throws -> Bool {
        guard let url = URL(string: getUserUrl) else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any?] = [
            "firstName": firstName,
            "lastName": lastName,
            "phoneNumber": phoneNumber
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body.compactMapValues { $0 })
        return try await performRequest(request)
    }
    
    /// Performs a generic request, optionally adding Auth header if token is available
    private func performRequest(_ request: URLRequest, requireAuth: Bool = true) async throws -> Bool {
        let (data, httpResponse) = try await executeRequest(request, requireAuth: requireAuth)
        
        if (200...299).contains(httpResponse.statusCode) {
             return true
        } else {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                let errorMessage = errorResponse.error ?? errorResponse.message ?? "Unknown error"
                throw APIError.requestFailed(description: errorMessage)
            }
            throw APIError.requestFailed(description: "Server returned \(httpResponse.statusCode)")
        }
    }
    
    func getUserTasksByStatus(status: String, page: Int = 1, limit: Int = 10) async throws -> GetTasksByStatusResponse {
        guard var urlComponents = URLComponents(string: "\(tasksUrl)\(status)") else {
            throw APIError.invalidURL
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        guard let url = urlComponents.url else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, httpResponse) = try await executeRequest(request, requireAuth: true)
        
        if (200...299).contains(httpResponse.statusCode) {
            do {
                let response = try JSONDecoder.apiDecoder.decode(GetTasksByStatusResponse.self, from: data)
                return response
            } catch {
                throw APIError.unableToDecode(error: error)
            }
        } else {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.requestFailed(description: errorResponse.error ?? errorResponse.message ?? "Unknown error")
            }
            throw APIError.requestFailed(description: "Server returned \(httpResponse.statusCode)")
        }
    }
    
    func createTask(taskListId: String?, title: String, description: String?, dueDate: String) async throws -> Bool {
        guard let url = URL(string: "\(tasksUrl)") else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any?] = [
            "title": title,
            "description": description,
            "taskListId": taskListId,
            "dueDate": "\(dueDate)T00:00:00.000Z",
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body.compactMapValues { $0 })
        return try await performRequest(request)
    }
    
    func deleteTask(taskId: String) async throws -> Bool {
        guard let url = URL(string: "\(tasksUrl)\(taskId)") else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        return try await performRequest(request)
    }
    
    func updateTaskStatus(taskId: String, status: String) async throws -> Bool {
        guard let url = URL(string: "\(tasksUrl)\(taskId)") else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["status": status]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return try await performRequest(request)
    }
    
    func updateTask(task: TaskModel) async throws -> Bool {
        guard let url = URL(string: "\(tasksUrl)\(task.id)") else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any?] = [
            "title": task.title,
            "description": task.description,
            "status": task.status,
            "isStarred": task.isStarred
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body.compactMapValues { $0 })
        return try await performRequest(request)
    }
    
    func toggleFavorite(taskId: String, isFavorite: Bool) async throws -> Bool {
        let path = isFavorite ? addTaskToFavoriteUrl : removeTaskFromFavoriteUrl
        guard let url = URL(string: "\(path)\(taskId)") else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return try await performRequest(request)
    }
    
    // MARK: - Task List Management
    
    func deleteTaskList(listId: String) async throws -> Bool {
        guard let url = URL(string: "\(taskListsUrl)\(listId)") else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        return try await performRequest(request)
    }
    
    func updateTaskList(listId: String, name: String, description: String?) async throws -> Bool {
        guard let url = URL(string: "\(taskListsUrl)\(listId)") else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any?] = [
            "name": name,
            "description": description
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body.compactMapValues { $0 })
        return try await performRequest(request)
    }
    
    func createTaskList(name: String, description: String?) async throws -> Bool {
        guard let url = URL(string: taskListsUrl) else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any?] = [
            "name": name,
            "description": description
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body.compactMapValues { $0 })
        return try await performRequest(request)
    }
    
    func getPendingTasks() async throws -> GetUserResponse {
        guard let url = URL(string: getUserUrl) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, httpResponse) = try await executeRequest(request, requireAuth: true)
        
        if (200...299).contains(httpResponse.statusCode) {
            do {
                let response = try JSONDecoder.apiDecoder.decode(GetUserResponse.self, from: data)
                return response
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
    
}
