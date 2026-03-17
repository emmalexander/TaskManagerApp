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
    
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header
                        .padding(.horizontal, 20)
                    greeting
                        .padding(.horizontal, 20)
                    segmentControl
                        .padding(.horizontal, 20)
                    projectCarousel
                    progressSection
                        .padding(.horizontal, 20)
                }
                //
                .padding(.top, 12)
                .padding(.bottom, 100) // space for bottom bar
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        
    }
}

// MARK: - Header
private extension TaskTabView {
    var header: some View {
        HStack {
            Text("Task Manager")
                .font(.title)
                .foregroundStyle(.secondary)
            Spacer()
            Button(action: {
                showingAddTask = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(
                        Circle()
                            .fill(LinearGradient(colors: [Color(hex: 0x7B61FF), Color(hex: 0x5B8BFF)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 8)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showingAddTask) {
            NavigationStack { AddTaskView() }
        }
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
            .padding(.horizontal, 4)
        }
        .alert("New Task List", isPresented: $showingAddTaskList) {
            TextField("List Name", text: $newTaskListName)
            Button("Cancel", role: .cancel) { newTaskListName = "" }
            Button("Create") {
                // Here you would call a viewModel method to create the list
                // For now, let's just print or assume it's handled
                print("Creating list: \(newTaskListName)")
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

// MARK: - Project Carousel
private extension TaskTabView {
    var projectCarousel: some View {
        EmptyView() // Temporarily hide or remove if it conflicts with the new task list focus
    }
}

struct ProjectCardView: View {
    let title: String
    let subtitle: String
    let date: String
    let gradient: [Color]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(8)
                        .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    Text(subtitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                }
                Spacer()
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(8)
                        .background(.white.opacity(0.15), in: Circle())
                }
                .buttonStyle(.plain)
            }

            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text(date)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(16)
        .frame(width: 240, alignment: .leading)
        .background(
            LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.white.opacity(0.08))
        )
        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 10)
    }
}

// MARK: - Progress Section
private extension TaskTabView {
    var progressSection: some View {
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
                // In Progress Section
                if !viewModel.inProgressTasks.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("In Progress")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        VStack(spacing: 12) {
                            ForEach(viewModel.inProgressTasks) { task in
                                ProgressRowView(task: task)
                            }
                        }
                    }
                }

                // Completed Section
                if !viewModel.completedTasks.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Completed")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        VStack(spacing: 12) {
                            ForEach(viewModel.completedTasks) { task in
                                ProgressRowView(task: task)
                                    .opacity(0.7)
                            }
                        }
                    }
                }
                
                if viewModel.inProgressTasks.isEmpty && viewModel.completedTasks.isEmpty {
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
    }
}

struct ProgressRowView: View {
    let task: TaskModel

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(task.status.lowercased() == "completed" ? Color.green.opacity(0.1) : Color(hex: 0xFFF0F5))
                    .frame(width: 44, height: 44)
                Image(systemName: task.status.lowercased() == "completed" ? "checkmark.circle.fill" : "paintbrush.fill")
                    .foregroundStyle(task.status.lowercased() == "completed" ? Color.green : Color(hex: 0xFF6AA2))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                if let description = task.description {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "ellipsis")
                .rotationEffect(.degrees(90))
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color(uiColor: .quaternaryLabel).opacity(0.2))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
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

