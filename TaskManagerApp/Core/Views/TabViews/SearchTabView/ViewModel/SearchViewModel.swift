//
//  NotificationViewModel.swift
//  TaskManagerApp
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchResults: [TaskModel] = []
    
    private let apiService = APIService.shared
    

    func searchTasks() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let responseData = try await apiService.searchTask(query: searchText)
                //user = responseData.data.user
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

}
