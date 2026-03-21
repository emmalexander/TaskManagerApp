//
//  MainTabViewModel.swift
//  TaskManagerApp
//
//  Created by Ohiocheoya Emmanuel on 14/03/2026.
//

import Foundation
import Combine

class MainTabViewModel: ObservableObject {
    
    @Published var selectedTab: Int = 0
    @Published var selectedSegment: Int = 0 // 0: My Tasks, 1: In-progress, 2: Completed
    
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    //@Published var signInSuccess = false
    
    @Published var user: User?
    @Published var taskLists: [TaskList] = []
    @Published var selectedTaskListId: String? = nil // Default to nil until loaded
    @Published var userTasksInProgress: [TaskModel] = []
    @Published var userTasksCompleted: [TaskModel] = []
    
    private let apiService = APIService.shared
    
    func getUser() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let responseData = try await apiService.getUser()
                DispatchQueue.main.async {
                    self.user = responseData.data.user
                    self.taskLists = responseData.data.taskLists
                    
                    // If no selectedTaskListId is set yet, pick the default list or "My Tasks"
                    if self.selectedTaskListId == nil {
                        if let defaultList = self.taskLists.first(where: { $0.isDefault }) {
                            self.selectedTaskListId = defaultList.id
                        } else if let myTasksList = self.taskLists.first(where: { $0.name == "My Tasks" }) {
                            self.selectedTaskListId = myTasksList.id
                        } else {
                            self.selectedTaskListId = self.taskLists.first?.id ?? "starred"
                        }
                    } else if self.selectedTaskListId != "starred" && !self.taskLists.contains(where: { $0.id == self.selectedTaskListId }) {
                        // If selected list was deleted, fallback to default or starred
                        self.selectedTaskListId = self.taskLists.first(where: { $0.isDefault })?.id ?? "starred"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                print("DEBUG: Get User error: \(error.localizedDescription)")
            }
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    func createTask(title: String, description: String?, dueDate: Date, taskListId: String, completion: ((Bool) -> Void)? = nil) {
        Task {
            @MainActor in
            isLoading = true
            do {
                let dueDateInString: String = {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    return formatter.string(from: dueDate)
                }()
                
                let success = try await apiService.createTask(taskListId: taskListId, title: title, description: description, dueDate: dueDateInString)
                if success {
                    ToastManager.shared.show("Task created successfully", type: .success)
                    getUser()
                    completion?(true)
                } else {
                    ToastManager.shared.show("Failed to create task", type: .error)
                    completion?(false)
                }
            } catch {
                self.errorMessage = error.localizedDescription
                ToastManager.shared.show("Failed to create task", type: .error)
                completion?(false)
            }
            isLoading = false
        }
    }
    
    var filteredTasks: [TaskModel] {
        if selectedTaskListId == "starred" {
            return taskLists.flatMap { $0.tasks }.filter { $0.isStarred ?? false }
        } else {
            return taskLists.first(where: { $0.id == selectedTaskListId })?.tasks ?? []
        }
    }
    
    var pendingTasks: [TaskModel] {
        filteredTasks.filter { $0.status.lowercased() == "pending" }
    }
    
    var inProgressTasks: [TaskModel] {
        filteredTasks.filter { $0.status.lowercased() == "in-progress" }
    }
    
    var completedTasks: [TaskModel] {
        filteredTasks.filter { $0.status.lowercased() == "completed" || $0.status.lowercased() == "done" }
    }
    
    // Max 5 tasks for the summary view
    var pendingTasksLimited: [TaskModel] { Array(pendingTasks.prefix(5)) }
    var inProgressTasksLimited: [TaskModel] { Array(inProgressTasks.prefix(5)) }
    var completedTasksLimited: [TaskModel] { Array(completedTasks.prefix(5)) }
    
    func deleteTask(taskId: String) {
        Task {
            do {
                let success = try await apiService.deleteTask(taskId: taskId)
                if success {
                    await MainActor.run {
                        ToastManager.shared.show("Task deleted successfully", type: .success)
                        getUser() // Refresh data
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    ToastManager.shared.show("Failed to delete task", type: .error)
                }
            }
        }
    }
    
    func completeTask(task: TaskModel) {
        Task {
            do {
                let success = try await apiService.updateTaskStatus(taskId: task.id, status: "completed")
                if success {
                    await MainActor.run {
                        getUser() // Refresh data
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func toggleFavorite(task: TaskModel) {
        let isCurrentlyFavorite = task.isStarred ?? false
        Task {
            do {
                let success = try await apiService.toggleFavorite(taskId: task.id, isFavorite: !isCurrentlyFavorite)
                if success {
                    await MainActor.run {
                        getUser() // Refresh data
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func updateTask(task: TaskModel) {
        Task {
            do {
                let success = try await apiService.updateTask(task: task)
                if success {
                    await MainActor.run {
                        getUser() // Refresh data
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Task List Management
    
    func deleteTaskList(listId: String) {
        Task {
            @MainActor in
            isLoading = true
            do {
                let success = try await apiService.deleteTaskList(listId: listId)
                if success {
                    ToastManager.shared.show("List deleted successfully", type: .success)
                    getUser() // Refresh data
                } else {
                    ToastManager.shared.show("Failed to delete list", type: .error)
                }
            } catch {
                errorMessage = error.localizedDescription
                ToastManager.shared.show("Failed to delete list", type: .error)
            }
            isLoading = false
        }
    }
    
    func updateTaskList(listId: String, name: String, description: String?) {
        Task {
            @MainActor in
            isLoading = true
            do {
                let success = try await apiService.updateTaskList(listId: listId, name: name, description: description)
                if success {
                    ToastManager.shared.show("List updated successfully", type: .success)
                    getUser() // Refresh data
                } else {
                    ToastManager.shared.show("Failed to update list", type: .error)
                }
            } catch {
                errorMessage = error.localizedDescription
                ToastManager.shared.show("Failed to update list", type: .error)
            }
            isLoading = false
        }
    }
    
    func createTaskList(name: String, description: String? = nil) {
        Task {
            @MainActor in
            isLoading = true
            do {
                let success = try await apiService.createTaskList(name: name, description: description)
                if success {
                    ToastManager.shared.show("List created successfully", type: .success)
                    getUser() // Refresh data
                } else {
                    ToastManager.shared.show("Failed to create list", type: .error)
                }
            } catch {
                errorMessage = error.localizedDescription
                ToastManager.shared.show("Failed to create list", type: .error)
            }
            isLoading = false
        }
    }
    
    func updateUser(firstName: String, lastName: String, phoneNumber: String?) {
        Task {
            @MainActor in
            isLoading = true
            do {
                let success = try await apiService.updateUser(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber)
                if success {
                    ToastManager.shared.show("Profile updated successfully", type: .success)
                    getUser() // Refresh user data
                } else {
                    ToastManager.shared.show("Failed to update profile", type: .error)
                }
            } catch {
                errorMessage = error.localizedDescription
                ToastManager.shared.show("Failed to update profile", type: .error)
            }
            isLoading = false
        }
    }
}
