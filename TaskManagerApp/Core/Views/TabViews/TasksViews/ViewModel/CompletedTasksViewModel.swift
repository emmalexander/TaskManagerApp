import Foundation
import Combine

class CompletedTasksViewModel: ObservableObject {
    @Published var tasks: [TaskModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var canLoadMore = true
    
    private var currentPage = 1
    private let apiService = APIService.shared
    
    init() {
        fetchTasks()
    }
    
    func fetchTasks() {
        guard !isLoading && canLoadMore else { return }
        
        isLoading = true
        Task {
            do {
                let response = try await apiService.getUserTasksByStatus(status: "completed", page: currentPage)
                await MainActor.run {
                    if response.data.isEmpty {
                        canLoadMore = false
                    } else {
                        self.tasks.append(contentsOf: response.data)
                        self.currentPage += 1
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func refresh() {
        tasks = []
        currentPage = 1
        canLoadMore = true
        fetchTasks()
    }
    
    func deleteTask(taskId: String) {
        Task {
            do {
                let success = try await apiService.deleteTask(taskId: taskId)
                if success {
                    await MainActor.run {
                        self.tasks.removeAll { $0.id == taskId }
                        ToastManager.shared.show("Task deleted successfully", type: .success)
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
    
    func toggleFavorite(task: TaskModel) {
        let isCurrentlyFavorite = task.isStarred ?? false
        Task {
            do {
                let success = try await apiService.toggleFavorite(taskId: task.id, isFavorite: !isCurrentlyFavorite)
                if success {
                    await MainActor.run {
                        if let index = self.tasks.firstIndex(where: { $0.id == task.id }) {
                            self.tasks[index].isStarred = !isCurrentlyFavorite
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
