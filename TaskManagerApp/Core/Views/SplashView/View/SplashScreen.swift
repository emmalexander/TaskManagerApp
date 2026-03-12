import SwiftUI

struct SplashScreen: View {
    @State private var animateIn = false
    @State private var navigateToOnboarding = false
    @State private var navigateToMain = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Use the app's accent color as background to match current app colors
                Color.accentColor
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("Task Manager")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .scaleEffect(animateIn ? 1.0 : 0.85)
                        .opacity(animateIn ? 1.0 : 0.0)
                        .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1), value: animateIn)

                    // Optional subtitle for a nicer splash; keep subtle and within brand
                    // Text("Organize. Focus. Achieve.")
                    //     .font(.headline)
                    //     .foregroundStyle(.white.opacity(0.9))
                    //     .opacity(animateIn ? 1.0 : 0.0)
                    //     .offset(y: animateIn ? 0 : 10)
                    //     .animation(.easeOut(duration: 0.6).delay(0.25), value: animateIn)
                }
            }
            .onAppear {
                // Kick off the entrance animation immediately
                animateIn = true

                // Navigate after ~3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    if TokenManager.shared.checkTokenValidity() {
                        navigateToMain = true
                    } else {
                        navigateToOnboarding = true
                    }
                }
            }
            // Programmatic navigation to onboarding
            .navigationDestination(isPresented: $navigateToOnboarding) {
                OnboardingView()
            }
            .navigationDestination(isPresented: $navigateToMain) {
                MainTabView()
                    .navigationBarBackButtonHidden(true)
            }
            // Hide back button if user swipes back from onboarding inadvertently
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    SplashScreen()
}
