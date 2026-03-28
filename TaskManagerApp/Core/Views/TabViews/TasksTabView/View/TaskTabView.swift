//
//  TaskTabView.swift
//  TaskManagerApp
//
//  Created by Ohiocheoya Emmanuel on 07/01/2026.
//

import SwiftUI

struct TaskTabView: View {
    @EnvironmentObject var viewModel: MainTabViewModel
    @State private var showingAddTask: Bool = false
    @State private var showingAddTaskList: Bool = false
    @State private var newTaskListName: String = ""

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        header
                        greeting
                        segmentControl
                        tasksSection
                    }
                    .refreshable {
                        viewModel.getUser()
                    }
                }
                
                // Floating Action Button
                Button(action: {
                    showingAddTask = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(LinearGradient(colors: [Color(hex: 0x7B61FF), Color(hex: 0x5B8BFF)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                        .shadow(color: Color(hex: 0x7B61FF).opacity(0.4), radius: 10, x: 0, y: 8)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 20)
                .padding(.bottom, 100) // Clear the bottom tab bar
                .sheet(isPresented: $showingAddTask) {
                    NavigationStack { AddTaskView() }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Header
private extension TaskTabView {
    var header: some View {
        HStack {
            Text("Tasks")
                .font(.title.weight(.bold))
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }

    var greeting: some View {
            VStack(alignment: .leading, spacing: 6) {
                
                if viewModel.isLoading {
                    SkeletonView(.rect(cornerRadius: 5))
                        .frame(width: 150, height: 30)
                } else {
                    Text("Hello \(viewModel.user?.firstName ?? "")!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.primary)
                }
                Text("Have a nice day.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
        
        
    }
}

// MARK: - Segment Control (Tabs)
private extension TaskTabView {
    var segmentControl: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Starred Tab
                tabButton(title: "Starred", id: "starred", icon: "star.fill")
                
                // Task List Tabs
                ForEach(viewModel.taskLists) { list in
                    tabButton(title: list.name, id: list.id)
                }
                
                // Add Task List Button
                Button(action: {
                    showingAddTaskList = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
        }
        .alert("New Task List", isPresented: $showingAddTaskList) {
            TextField("List Name", text: $newTaskListName)
            Button("Cancel", role: .cancel) { newTaskListName = "" }
            Button("Create") {
                viewModel.createTaskList(name: newTaskListName)
                newTaskListName = ""
            }
        } message: {
            Text("Enter a name for your new task list.")
        }
    }

    func tabButton(title: String, id: String, icon: String? = nil) -> some View {
        Button(action: { 
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { 
                viewModel.selectedTaskListId = id 
            } 
        }) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                }
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(viewModel.selectedTaskListId == id ? .white : .secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Group {
                    if viewModel.selectedTaskListId == id {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(LinearGradient(colors: [Color(hex: 0x7B61FF), Color(hex: 0x5B8BFF)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    } else {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(uiColor: .secondarySystemBackground))
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Progress Section
private extension TaskTabView {
    var tasksSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            if viewModel.isLoading {
                VStack(alignment: .leading, spacing: 12) {
                    SkeletonView(.rect(cornerRadius: 10))
                        .frame(width: 100, height: 20)
                    ForEach(0..<3) { _ in
                        SkeletonView(.rect(cornerRadius: 18))
                            .frame(height: 72)
                    }
                }
            } else {
                // Pending Section
                statusSection(title: "Pending", tasks: viewModel.pendingTasksLimited, totalCount: viewModel.pendingTasks.count, status: "pending")

                // In Progress Section
                statusSection(title: "In Progress", tasks: viewModel.inProgressTasksLimited, totalCount: viewModel.inProgressTasks.count, status: "in-progress")

                // Completed Section
                statusSection(title: "Completed", tasks: viewModel.completedTasksLimited, totalCount: viewModel.completedTasks.count, status: "completed")
                
                if viewModel.pendingTasks.isEmpty && viewModel.inProgressTasks.isEmpty && viewModel.completedTasks.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary.opacity(0.3))
                        Text("No tasks found")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("Switch tabs or add a task to get started")
                            .font(.subheadline)
                            .foregroundStyle(.secondary.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                }
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 80)
    }

    @ViewBuilder
    func statusSection(title: String, tasks: [TaskModel], totalCount: Int, status: String) -> some View {
        if !tasks.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.primary)
                        // Count badge
                        Text("\(totalCount)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(statusBadgeColor(for: status))
                            )
                    }
                    Spacer()
                    // Only show "See All" if at 5 tasks (there may be more paginated)
                    if totalCount >= 5 {
                        NavigationLink {
                            statusDestination(for: status)
                        } label: {
                            HStack(spacing: 3) {
                                Text("See all")
                                    .font(.subheadline.weight(.semibold))
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.bold))
                            }
                            .foregroundStyle(Color(hex: 0x7B61FF))
                        }
                    }
                }
                .padding(.horizontal, 16)

                VStack(spacing: 10) {
                    ForEach(tasks) { task in
                        TaskRowView(
                            task: task,
                            onDelete: { viewModel.deleteTask(taskId: task.id) },
                            onComplete: { viewModel.completeTask(task: task) },
                            onToggleFavorite: { viewModel.toggleFavorite(task: task) },
                            onEdit: { }
                        )
                        .opacity(status == "completed" ? 0.75 : 1.0)
                    }
                }
            }
        }
    }

    private func statusBadgeColor(for status: String) -> Color {
        switch status.lowercased() {
        case "completed": return .green
        case "in-progress": return Color(hex: 0x5B8BFF)
        default: return Color(hex: 0xFF6AA2)
        }
    }

    @ViewBuilder
    private func statusDestination(for status: String) -> some View {
        switch status.lowercased() {
        case "pending":
            PendingTasksView()
        case "in-progress":
            InProgressTasksView()
        case "completed":
            CompletedTasksView()
        default:
            EmptyView()
        }
    }
}





#Preview {
    NavigationStack {
        TaskTabView()
            .environmentObject(MainTabViewModel())
            .navigationTitle("")
            .navigationBarHidden(true)
    }
}

