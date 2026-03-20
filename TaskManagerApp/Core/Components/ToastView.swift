import SwiftUI
import Combine

// MARK: - Toast View
struct ToastView: View {
    let toast: ToastMessage
    var onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.type.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(toast.type.color)

            Text(toast.message)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(2)

            Spacer(minLength: 0)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.secondary)
                    .padding(6)
                    .background(Color(uiColor: .tertiarySystemFill), in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(toast.type.color.opacity(0.25), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - Toast Overlay Modifier
struct ToastOverlayModifier: ViewModifier {
    @ObservedObject var manager: ToastManager

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            if let toast = manager.currentToast {
                ToastView(toast: toast) {
                    manager.dismiss()
                }
                .zIndex(999)
                .padding(.top, 56)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: manager.currentToast)
    }
}

extension View {
    func toastOverlay(manager: ToastManager = .shared) -> some View {
        modifier(ToastOverlayModifier(manager: manager))
    }
}
