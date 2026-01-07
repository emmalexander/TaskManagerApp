import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var taskName: String = ""
    @State private var date: Date = Date()
    @State private var startTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var endTime: Date = Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var descriptionText: String = ""

    private let categories: [String] = ["Design", "Meeting", "Coding", "BDE", "Testing", "Quick call"]
    @State private var selectedCategory: String = "Design"

    var body: some View {
        ZStack(alignment: .top) {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    header

                    VStack(alignment: .leading, spacing: 16) {
                        fieldLabel("Name")
                        TextField("Task name", text: $taskName)
                            .padding(14)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                        fieldLabel("Date")
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding(14)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                        timeCard

                        fieldLabel("Description")
                        ZStack(alignment: .topLeading) {
                            if descriptionText.isEmpty {
                                Text("Add description")
                                    .foregroundColor(.gray.opacity(0.6))
                                    .padding(18)
                            }
                            TextEditor(text: $descriptionText)
                                .frame(minHeight: 110)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }

                        fieldLabel("Category")
                        categoryChips
                    }
                    .padding(.horizontal, 20)

                    createButton
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                }
                .padding(.vertical, 16)
            }
        }
        .navigationBarHidden(true)
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
            .clipShape(RoundedCorner(radius: 26, corners: [.bottomLeft, .bottomRight]))
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

                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color.white.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
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
    private var timeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                fieldLabel("Start Time")
                Spacer()
                fieldLabel("End Time")
            }

            HStack(spacing: 16) {
                DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                DatePicker("End", selection: $endTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
    }

    // MARK: - Category Chips
    private var categoryChips: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
            ForEach(categories, id: \.self) { cat in
                let isSelected = cat == selectedCategory
                Button(action: { selectedCategory = cat }) {
                    Text(cat)
                        .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                        .foregroundColor(isSelected ? .white : .primary)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            Group {
                                if isSelected {
                                    LinearGradient(
                                        colors: [Color.purple.opacity(0.95), Color.blue.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                } else {
                                    Color.white
                                }
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(isSelected ? Color.clear : Color.gray.opacity(0.25), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: isSelected ? Color.purple.opacity(0.2) : .clear, radius: 8, x: 0, y: 4)
                }
            }
        }
    }

    // MARK: - Create Button
    private var createButton: some View {
        Button(action: {
            // Hook up to your view model here if needed
            dismiss()
        }) {
            Text("Create Task")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.95), Color.blue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.purple.opacity(0.25), radius: 12, x: 0, y: 8)
        }
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
