import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject var mainTabViewModel: MainTabViewModel
    
    @State private var taskName: String = ""
    @State private var dueDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
//    @State private var startTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
//    @State private var endTime: Date = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var descriptionText: String = ""
    @State private var selectedTaskListId: String = ""
    
    private var isFormValid: Bool {
        !taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !selectedTaskListId.isEmpty
    }

//    private let categories: [String] = ["Design", "Meeting", "Coding", "BDE", "Testing", "Quick call"]
//    @State private var selectedCategory: String = "Design"

    var body: some View {
        ZStack(alignment: .top) {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading,spacing: 20) {
                    header

                    VStack(alignment: .leading, spacing: 16) {
                        fieldLabel("Title")
                        TextField("Task name", text: $taskName)
                            .padding(14)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        
                        fieldLabel("Description")
                        
                        ZStack(alignment: .topLeading) {
                            if descriptionText.isEmpty {
                                Text("Add description")
                                    .foregroundColor(.gray.opacity(0.6))
                                    .padding(18)
                            }
                            TextEditor(text: $descriptionText)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 110)
                                .padding(10)
                                .background(Color(uiColor: .secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }

                        fieldLabel("Due date")
                        
                        DatePicker("", selection: $dueDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding(14)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                        //timeCard

                        fieldLabel("Task List")
                        Menu {
                            Picker("", selection: $selectedTaskListId) {
                                ForEach(mainTabViewModel.taskLists, id: \.id) { list in
                                    Text(list.name).tag(list.id)
                                }
                            }
                        } label: {
                            HStack {
                                Text(mainTabViewModel.taskLists.first(where: { $0.id == selectedTaskListId })?.name ?? "Select Task List")
                                    .foregroundColor(selectedTaskListId.isEmpty ? .gray.opacity(0.6) : .primary)
                                Spacer()
                                Image(systemName: "chevron.up.chevron.down")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                            }
                            .padding(14)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }

                    }
                    .padding(.horizontal, 20)

                    createButton
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                }
                .padding(.bottom, 16)
            }
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .onAppear {
            if selectedTaskListId.isEmpty {
                if let defaultList = mainTabViewModel.taskLists.first(where: { $0.isDefault }) {
                    selectedTaskListId = defaultList.id
                } else if let myTasksList = mainTabViewModel.taskLists.first(where: { $0.name == "My Tasks" }) {
                    selectedTaskListId = myTasksList.id
                } else if let firstList = mainTabViewModel.taskLists.first {
                    selectedTaskListId = firstList.id
                }
            }
        }
        .alert("Error", isPresented: Binding(
            get: { mainTabViewModel.errorMessage != nil },
            set: { _ in mainTabViewModel.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage = mainTabViewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.95), Color.blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 180)
            //.clipShape(RoundedCorner(radius: 26, corners: [.bottomLeft, .bottomRight]))
            .overlay(
                ZStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color.white.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }

                        Spacer()

//                        Button(action: {}) {
//                            Image(systemName: "magnifyingglass")
//                                .font(.system(size: 20, weight: .medium))
//                                .foregroundColor(.white)
//                                .frame(width: 36, height: 36)
//                                .background(Color.white.opacity(0.15))
//                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
//                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .frame(maxHeight: .infinity, alignment: .top)

                    Text("Create a Task")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxHeight: .infinity)
                        .padding(.top, 64)
                }
            )
        }
    }

    // MARK: - Time Card
//    private var timeCard: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            HStack {
//                fieldLabel("Start Time")
//                Spacer()
//                fieldLabel("End Time")
//            }
//
//            HStack(spacing: 16) {
//                DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
//                    .datePickerStyle(.compact)
//                    .labelsHidden()
//                    .padding(12)
//                    .frame(maxWidth: .infinity)
//                    .background(Color(uiColor: .secondarySystemBackground))
//                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
//
//                DatePicker("End", selection: $endTime, displayedComponents: .hourAndMinute)
//                    .datePickerStyle(.compact)
//                    .labelsHidden()
//                    .padding(12)
//                    .frame(maxWidth: .infinity)
//                    .background(Color(uiColor: .secondarySystemBackground))
//                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
//            }
//        }
//        .padding(16)
//        .background(Color(uiColor: .secondarySystemGroupedBackground))
//        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
//    }

    // MARK: - Category Chips
//    private var categoryChips: some View {
//        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
//        return LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
//            ForEach(categories, id: \.self) { cat in
//                let isSelected = cat == selectedCategory
//                Button(action: { selectedCategory = cat }) {
//                    Text(cat)
//                        .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
//                        .foregroundColor(isSelected ? .white : .primary)
//                        .padding(.vertical, 10)
//                        .frame(maxWidth: .infinity)
//                        .background(
//                            Group {
//                                if isSelected {
//                                    LinearGradient(
//                                        colors: [Color.purple.opacity(0.95), Color.blue.opacity(0.8)],
//                                        startPoint: .topLeading,
//                                        endPoint: .bottomTrailing
//                                    )
//                                } else {
//                                    Color(uiColor: .secondarySystemGroupedBackground)
//                                }
//                            }
//                        )
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 24)
//                                .stroke(isSelected ? Color.clear : Color.gray.opacity(0.25), lineWidth: 1)
//                        )
//                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
//                        .shadow(color: isSelected ? Color.purple.opacity(0.2) : .clear, radius: 8, x: 0, y: 4)
//                }
//            }
//        }
//    }

    // MARK: - Create Button
    private var createButton: some View {
        
        LoadingButton(title: "Create Task", isLoading: $mainTabViewModel.isLoading, action: {
            mainTabViewModel.createTask(title: taskName, description: descriptionText.isEmpty ? nil : descriptionText, dueDate: dueDate, taskListId: selectedTaskListId) { success in
                if success {
                    dismiss()
                }
            }
        })
        .disabled(!isFormValid)
        .opacity(isFormValid ? 1.0 : 0.5)
//        Button(action: {
//            // Hook up to your view model here if needed
//            dismiss()
//        }) {
//            Text("Create Task")
//                .font(.system(size: 18, weight: .semibold))
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity)
//                .padding(.vertical, 16)
//                .background(
//                    LinearGradient(
//                        colors: [Color.purple.opacity(0.95), Color.blue.opacity(0.8)],
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                )
//                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//                .shadow(color: Color.purple.opacity(0.25), radius: 12, x: 0, y: 8)
//        }
    }

    // MARK: - Helpers
    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.secondary)
    }
}

// Rounded corner helper for specific corners
fileprivate struct RoundedCorner: Shape {
    var radius: CGFloat = 12
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    NavigationStack {
        AddTaskView()
    }
}
