import SwiftUI

// MARK: - Constants
private let kDeleteButtonWidth: CGFloat = 72
private let kSwipeThreshold: CGFloat = kDeleteButtonWidth * 0.6
private let kMaxSwipe: CGFloat = kDeleteButtonWidth

struct TaskRowView: View {
    let task: TaskModel
    var onDelete: () -> Void          // Called AFTER API resolves successfully (caller handles API)
    var onComplete: () -> Void
    var onToggleFavorite: () -> Void
    var onEdit: () -> Void

    // Swipe state
    @State private var swipeOffset: CGFloat = 0
    @State private var isDragging = false

    // Alert state
    @State private var showingDeleteAlert = false
    @State private var showingCompleteAlert = false

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
        ZStack(alignment: .trailing) {
            // MARK: Delete button (revealed behind the card)
            deleteBackdrop

            // MARK: The main card
            cardContent
                .offset(x: swipeOffset)
                .gesture(swipeGesture)
        }
        .clipped()
        // Delete confirmation dialog
        .alert("Delete Task?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                // Snap card back first, then call delete (which fires the API + toast)
                snapBack()
                onDelete()
            }
            Button("Cancel", role: .cancel) {
                snapBack()
            }
        } message: {
            Text("Are you sure you want to delete \"\(task.title)\"? This action cannot be undone.")
        }
        // Complete confirmation dialog
        .alert("Mark as Completed?", isPresented: $showingCompleteAlert) {
            Button("Complete", role: .none) { onComplete() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to mark \"\(task.title)\" as completed? This action cannot be undone.")
        }
    }

    // MARK: - Delete Backdrop
    private var deleteBackdrop: some View {
        HStack {
            Spacer()
            Button(action: { showingDeleteAlert = true }) {
                VStack(spacing: 4) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Delete")
                        .font(.caption2.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(width: kDeleteButtonWidth)
                .frame(maxHeight: .infinity)
                .background(
                    LinearGradient(
                        colors: [Color(hex: 0xFF453A), Color(hex: 0xFF6B6B)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
            // Only show/expand as user swipes
            .opacity(revealProgress)
            .scaleEffect(x: revealProgress, anchor: .trailing)
        }
    }

    // MARK: - Card Content
    private var cardContent: some View {
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
    }

    // MARK: - Swipe Gesture (left only → delete)
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { value in
                guard value.translation.width < 0 else { return } // left only
                isDragging = true
                let raw = value.translation.width
                // Add rubber-band resistance beyond max
                if abs(raw) <= kMaxSwipe {
                    swipeOffset = raw
                } else {
                    let excess = abs(raw) - kMaxSwipe
                    swipeOffset = -(kMaxSwipe + excess * 0.2)
                }
            }
            .onEnded { value in
                isDragging = false
                let velocity = value.predictedEndTranslation.width
                // If dragged past threshold OR flung with enough velocity → snap open
                if swipeOffset < -kSwipeThreshold || velocity < -200 {
                    snapOpen()
                } else {
                    snapBack()
                }
            }
    }

    // MARK: - Helpers
    private var revealProgress: CGFloat {
        min(abs(swipeOffset) / kMaxSwipe, 1.0)
    }

    private func snapOpen() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            swipeOffset = -kMaxSwipe
        }
    }

    private func snapBack() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            swipeOffset = 0
        }
    }
}
