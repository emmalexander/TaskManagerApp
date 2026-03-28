import SwiftUI

struct InProgressTasksView: View {
    @StateObject private var viewModel = InProgressTasksViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()

            if viewModel.tasks.isEmpty && !viewModel.isLoading {
                emptyState
            } else {
                taskList
            }
        }
        .navigationTitle("In Progress")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if !viewModel.tasks.isEmpty {
                    Text("\(viewModel.tasks.count) tasks")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color(hex: 0x5B8BFF)))
                }
            }
        }
    }

    // MARK: - Task List
    private var taskList: some View {
        List {
            ForEach(viewModel.tasks) { task in
                TaskRowView(
                    task: task,
                    onDelete: { viewModel.deleteTask(taskId: task.id) },
                    onComplete: { viewModel.completeTask(task: task) },
                    onToggleFavorite: { viewModel.toggleFavorite(task: task) },
                    onEdit: { }
                )
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                // Infinite scroll: load more when last item appears
                .onAppear {
                    if task.id == viewModel.tasks.last?.id {
                        viewModel.fetchTasks()
                    }
                }
            }

            // Loading spinner at the bottom
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        ProgressView()
                        Text("Loading more...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 16)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            // End of list indicator
            if !viewModel.isLoading && !viewModel.tasks.isEmpty && !viewModel.canLoadMore {
                HStack {
                    Spacer()
                    Text("All tasks loaded")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Spacer()
                }
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .refreshable {
            viewModel.refresh()
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 60))
                .foregroundStyle(Color(hex: 0x5B8BFF).opacity(0.4))
            Text("Nothing In Progress")
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
            Text("Tasks you start working on will\nappear here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Back Button
    private var backButton: some View {
        Button(action: { dismiss() }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                Text("Back")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(Color(hex: 0x7B61FF))
        }
    }
}
