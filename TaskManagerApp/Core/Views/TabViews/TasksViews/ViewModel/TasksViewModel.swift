//
//  TasksViewModel.swift
//  TaskManagerApp
//
//  Created by Ohiocheoya Emmanuel on 07/01/2026.
//

import Foundation
import Combine

class TasksViewModel: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var selectedSegment: Int = 0 // 0: My Tasks, 1: In-progress, 2: Completed
    
    @Published var user: User?
    
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    //@Published var signInSuccess = false
    
    private let apiService = APIService.shared
    
    func getUser() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let responseData = try await apiService.getUser()
                user = responseData.data.user;
            } catch {
                // Since APIError conforms to LocalizedError, this will capture the specific API error message
                errorMessage = error.localizedDescription
                print("DEBUG: Get User error: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    }
}
