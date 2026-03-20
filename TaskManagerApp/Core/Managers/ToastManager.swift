import Foundation
import SwiftUI
import Combine

// MARK: - Toast Model
struct ToastMessage: Equatable {
    let id: UUID = UUID()
    let message: String
    let type: ToastType
    
    enum ToastType {
        case success, error, info
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error:   return "xmark.circle.fill"
            case .info:    return "info.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .success: return Color(hex: 0x34C759)
            case .error:   return Color(hex: 0xFF453A)
            case .info:    return Color(hex: 0x7B61FF)
            }
        }
    }
    
    static func == (lhs: ToastMessage, rhs: ToastMessage) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Toast Manager
class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published var currentToast: ToastMessage? = nil
    private var dismissTask: Task<Void, Never>?
    
    private init() {}
    
    func show(_ message: String, type: ToastMessage.ToastType = .success, duration: Double = 3.0) {
        dismissTask?.cancel()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            currentToast = ToastMessage(message: message, type: type)
        }
        dismissTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.3)) {
                currentToast = nil
            }
        }
    }
    
    func dismiss() {
        dismissTask?.cancel()
        withAnimation(.easeOut(duration: 0.3)) {
            currentToast = nil
        }
    }
}
