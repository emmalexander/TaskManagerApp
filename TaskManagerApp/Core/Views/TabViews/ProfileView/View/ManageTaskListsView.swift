//
//  ManageTaskListsView.swift
//  TaskManagerApp
//

import SwiftUI

struct ManageTaskListsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var mainTabViewModel: MainTabViewModel
    
    @State private var selectedList: TaskList?
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var listToDelete: TaskList?
    
    var body: some View {
        List {
            ForEach(mainTabViewModel.taskLists) { list in
                TaskListRow(list: list, onEdit: {
                    selectedList = list
                    showingEditSheet = true
                }, onDelete: {
                    listToDelete = list
                    showingDeleteAlert = true
                })
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Manage Lists")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .padding(.bottom, 100)
        .sheet(isPresented: $showingEditSheet) {
            if let list = selectedList {
                EditTaskListView(list: list) { updatedName, updatedDescription in
                    mainTabViewModel.updateTaskList(listId: list.id, name: updatedName, description: updatedDescription)
                }
            }
        }
        .alert("Delete Task List", isPresented: $showingDeleteAlert, presenting: listToDelete) { list in
            Button("Delete", role: .destructive) {
                mainTabViewModel.deleteTaskList(listId: list.id)
            }
            Button("Cancel", role: .cancel) {}
        } message: { list in
            Text("Are you sure you want to delete '\(list.name)'? This action cannot be undone.")
        }
    }
}

struct TaskListRow: View {
    let list: TaskList
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(list.isDefault ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: "list.bullet")
                    .foregroundStyle(list.isDefault ? .blue : .primary)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(list.name)
                    .font(.headline)
                
                if let description = list.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Text("\(list.tasks.count) tasks")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Menu {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }
                
                if !list.isDefault {
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .padding(8)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(uiColor: .secondarySystemBackground)))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(list.isDefault ? Color.blue.opacity(0.2) : Color.clear, lineWidth: 1)
        )
    }
}

struct EditTaskListView: View {
    @Environment(\.dismiss) var dismiss
    let list: TaskList
    let onSave: (String, String?) -> Void
    
    @State private var name: String
    @State private var description: String
    
    init(list: TaskList, onSave: @escaping (String, String?) -> Void) {
        self.list = list
        self.onSave = onSave
        _name = State(initialValue: list.name)
        _description = State(initialValue: list.description ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("List Details") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...10)
                }
            }
            .navigationTitle("Edit List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(name, description.isEmpty ? nil : description)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ManageTaskListsView()
        .environmentObject(MainTabViewModel())
}
