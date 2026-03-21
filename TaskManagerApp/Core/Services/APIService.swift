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
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.requestFailed(description: "Invalid response")
        }
        
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
        var authRequest = request
        
        if requireAuth {
            if let token = TokenManager.shared.token {
                if !TokenManager.shared.checkTokenValidity() {
                    throw APIError.requestFailed(description: "Session Expired. Please sign in again.")
                }
                authRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        
        let (data, response) = try await URLSession.shared.data(for: authRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.requestFailed(description: "Invalid response")
        }
        
        if (200...299).contains(httpResponse.statusCode) {
             return true
        } else {
            if httpResponse.statusCode == 401 {
                 TokenManager.shared.clearTokenAndAlert()
            }
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
        
        if let token = TokenManager.shared.token {
            if !TokenManager.shared.checkTokenValidity() {
                throw APIError.requestFailed(description: "Session Expired. Please sign in again.")
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.requestFailed(description: "Invalid response")
        }
        
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
        
        if let token = TokenManager.shared.token {
            if !TokenManager.shared.checkTokenValidity() {
                throw APIError.requestFailed(description: "Session Expired. Please sign in again.")
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.requestFailed(description: "Invalid response")
        }
        
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
