import SwiftUI

struct SplashScreen: View {
    @Binding var appState: ContentView.AppState
    
    @State private var animateIn = false
    @State private var logoScale = 0.6
    @State private var logoOpacity = 0.0

    var body: some View {
        ZStack {
            // Premium Gradient Background matching the new icon
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "001A6E"), Color(hex: "00B4DB")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // New App Logo Animation
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                
                Text("Task Manager")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .opacity(animateIn ? 1.0 : 0.0)
                    .offset(y: animateIn ? 0 : 20)
            }
        }
        .onAppear {
            // Smooth Entry Animation
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                animateIn = true
            }

            // Move to appropriate app state after ~2.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    if TokenManager.shared.checkTokenValidity() {
                        appState = .main
                    } else {
                        appState = .onboarding
                    }
                }
            }
        }
    }
}

// Helper for hex colors if not already available
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    SplashScreen(appState: .constant(.splash))
}
