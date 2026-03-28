//
//  ProfileViewModel.swift
//  TaskManagerApp
//

import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var showingPersonalInfo = false
    
    @Published var completedTasksNumber: Int = 0
    @Published var pendingTasksNumber: Int = 0
    
    @Published var logUserOut: Bool = false
    
    private let apiService = APIService.shared
    
    init() {
        getUser()
        getTasksCount()
    }
    
    func getUser() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let responseData = try await apiService.getUser()
                user = responseData.data.user
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func getTasksCount() {
        Task {
            do {
                let pendingTasksResponseData = try await apiService.getUserTasksByStatus(status: "pending")
                let completedTasksResponseData = try await apiService.getUserTasksByStatus(status: "completed")
                
                completedTasksNumber = completedTasksResponseData.data.totalTasks;
                pendingTasksNumber = pendingTasksResponseData.data.totalTasks;
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func logout() {
        TokenManager.shared.clearTokenAndAlert()
        logUserOut = true
    }
}
