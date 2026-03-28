//
//  NotificationView.swift
//  TaskManagerApp
//

import SwiftUI

struct SearchTaskView: View {
    @EnvironmentObject var mainTabViewModel: MainTabViewModel
    @EnvironmentObject var viewModel: SearchViewModel
    
//    var filteredTasks: [TaskModel] {
//        // Collect unique tasks from all lists just to be safe
//        let allTasks = viewModel.taskLists.flatMap { $0.tasks }
//        var uniqueTasks: [TaskModel] = []
//        var seenIds = Set<String>()
//        for task in allTasks {
//            if !seenIds.contains(task.id) {
//                seenIds.insert(task.id)
//                uniqueTasks.append(task)
//            }
//        }
//        
//        if searchText.isEmpty {
//            return uniqueTasks
//        } else {
//            return uniqueTasks.filter { task in
//                task.title.localizedCaseInsensitiveContains(searchText) ||
//                (task.description?.localizedCaseInsensitiveContains(searchText) ?? false)
//            }
//        }
//    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        header
                        searchField
                        tasksSection
                    }
                    .padding(.bottom, 100)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationBarHidden(true)
        }
    }
    
    var header: some View {
        HStack {
            Text("Search")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search tasks...", text: $viewModel.searchText)
                .font(.body)
                .disableAutocorrection(true)
                .onChange(of: viewModel.searchText) { oldValue, newValue in
                    if viewModel.searchText.count > 2 {
                        viewModel.searchTasks()
                    }
                }
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    var tasksSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if viewModel.searchResults.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary.opacity(0.3))
                    Text(viewModel.searchText.isEmpty ? "Search for your tasks" : "No tasks found")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                ForEach(viewModel.searchResults) { task in
//                    TaskRowView(
//                        task: task,
//                        onDelete: { viewModel.deleteTask(taskId: task.id) },
//                        onComplete: { viewModel.completeTask(task: task) },
//                        onToggleFavorite: { viewModel.toggleFavorite(task: task) },
//                        onEdit: { }
//                    )
//                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.top, 20)
    }
}

#Preview {
    SearchTaskView()
        .environmentObject(MainTabViewModel())
}
