import SwiftUI

struct TaskRowView: View {
    let task: TaskModel
    var onDelete: () -> Void
    var onComplete: () -> Void
    var onToggleFavorite: () -> Void
    var onEdit: () -> Void

    @State private var showingCompleteAlert = false
    @State private var showingDeleteAlert = false
    @State private var offset: CGFloat = 0

    // Dynamic icon and color per status
    private var statusIcon: String {
        switch task.status.lowercased() {
        case "completed": return "checkmark.circle.fill"
        case "in-progress": return "arrow.triangle.2.circlepath"
        default: return "clock.fill"
        }
    }

    private var statusColor: Color {
        switch task.status.lowercased() {
        case "completed": return .green
        case "in-progress": return Color(hex: 0x5B8BFF)
        default: return Color(hex: 0xFF6AA2)
        }
    }

    private var statusBgColor: Color {
        switch task.status.lowercased() {
        case "completed": return Color.green.opacity(0.12)
        case "in-progress": return Color(hex: 0x5B8BFF).opacity(0.12)
        default: return Color(hex: 0xFFF0F5)
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Status icon bubble
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(statusBgColor)
                    .frame(width: 44, height: 44)
                Image(systemName: statusIcon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(statusColor)
            }

            // Title + description
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .strikethrough(task.status.lowercased() == "completed", color: .secondary)
                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                // Due date badge if available
                if let dueDate = task.dueDate {
                    Label(dueDate.formatted(.dateTime.month(.abbreviated).day()), systemImage: "calendar")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            // Popup context menu (3-dot)
            Menu {
                Button(action: onToggleFavorite) {
                    Label(
                        task.isStarred ?? false ? "Remove from Favorites" : "Add to Favorites",
                        systemImage: task.isStarred ?? false ? "star.slash.fill" : "star.fill"
                    )
                }
                Divider()
                Button(action: onEdit) {
                    Label("Edit Task", systemImage: "pencil")
                }
                Divider()
                Button(role: .destructive, action: { showingDeleteAlert = true }) {
                    Label("Delete Task", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .font(.system(size: 22))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color(uiColor: .quaternaryLabel).opacity(0.3))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        // Swipe LEFT → Delete
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive, action: { showingDeleteAlert = true }) {
                Label("Delete", systemImage: "trash.fill")
            }
        }
        // Swipe RIGHT → Complete (only if not already completed)
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            if task.status.lowercased() != "completed" {
                Button(action: { showingCompleteAlert = true }) {
                    Label("Complete", systemImage: "checkmark.circle.fill")
                }
                .tint(.green)
            }
        }
        // ✅ Complete confirmation ALERT (dialog)
        .alert("Mark as Completed?", isPresented: $showingCompleteAlert) {
            Button("Complete", role: .none) {
                onComplete()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to mark \"\(task.title)\" as completed? This action cannot be undone.")
        }
        // 🗑 Delete confirmation ALERT (dialog)
        .alert("Delete Task?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete \"\(task.title)\"? This action cannot be undone.")
        }
    }
}
