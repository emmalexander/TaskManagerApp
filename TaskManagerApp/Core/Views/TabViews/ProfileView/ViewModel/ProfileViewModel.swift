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
    
    private let apiService = APIService.shared
    
    init() {
        getUser()
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
    
    func logout() {
        TokenManager.shared.clearTokenAndAlert()
    }
}
