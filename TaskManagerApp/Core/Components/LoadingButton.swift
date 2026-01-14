import SwiftUI

struct LoadingButton: View {
    let title: String
    let icon: String?
    var backgroundColor: Color = .accentColor
    var foregroundColor: Color = .white
    @Binding var isLoading: Bool
    let action: () -> Void
    
    init(title: String, icon: String? = nil, backgroundColor: Color = .accentColor, foregroundColor: Color = .white, isLoading: Binding<Bool>, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self._isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                        .scaleEffect(0.8)
                }
                
                if !isLoading {
                    Text(title)
                        .font(.headline)
                        
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.headline)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isLoading ? backgroundColor.opacity(0.6) : backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
            .opacity(isLoading ? 0.8 : 1.0)
        }
        .disabled(isLoading)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

#Preview {
    LoadingButton(title: "Sign In", isLoading: .constant(false)) {}
        .padding()
    
    LoadingButton(title: "Loading...", isLoading: .constant(true)) {}
        .padding()
}
