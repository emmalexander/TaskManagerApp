import SwiftUI

struct OnboardingView: View {
    
    @State private var currentPage = 0
    @State private var showSignIn = false
    @State private var showSignUp = false
    
    init(currentPage: Int = 0){
        _currentPage = .init(initialValue: currentPage)
    }
    
    let pages = [
        OnboardingPage(
            title: "Organize Your Life",
            description: "Keep all your tasks in one place. Categorize, prioritize, and never miss a deadline again.",
            iconName: "checklist",
            color: Color.blue
        ),
        OnboardingPage(
            title: "Collaborate Seamlessly",
            description: "Share tasks with your team, assign responsibilities, and track progress together in real time.",
            iconName: "person.3.fill",
            color: Color.purple
        ),
        OnboardingPage(
            title: "Track Your Success",
            description: "Visualize your productivity with beautiful charts and insights into your daily achievements.",
            iconName: "chart.bar.fill",
            color: Color.orange
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack {
                // Carousel
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingCardView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .animation(.easeInOut, value: currentPage)
                
                // Navigation Buttons
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        // Final Step Options
                        Button {
                           showSignUp = true
                        } label: {
                            Text("Get Started")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        
                        Button {
                            showSignIn = true
                        } label: {
                            Text("I already have an account")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom)
                        
                    } else {
                        // Next Button
                        Button {
                            withAnimation {
                                currentPage += 1
                            }
                        } label: {
                            Text("Next")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.primary.opacity(0.1))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        Button("Skip") {
                            withAnimation {
                                currentPage = pages.count - 1
                            }
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom, 20)
                .frame(height: 150) // Fixed height for buttons area to prevent jumping
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showSignIn) {
            SignInView()
        }
        .navigationDestination(isPresented: $showSignUp) {
            SignUpView()
        }
    }
}

// MARK: - Models & Subviews

struct OnboardingPage {
    let title: String
    let description: String
    let iconName: String
    let color: Color
}

struct OnboardingCardView: View {
    let page: OnboardingPage
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Animated Image Container
            ZStack {
                // Pulse Circles
                Circle()
                    .stroke(page.color.opacity(0.3), lineWidth: 40)
                    .frame(width: 200, height: 200)
                    .scaleEffect(isAnimating ? 1.5 : 1.0)
                    .opacity(isAnimating ? 0.0 : 1.0)
                
                Circle()
                    .fill(page.color.opacity(0.1))
                    .frame(width: 250, height: 250)
                    .scaleEffect(isAnimating ? 1.2 : 0.9)
                
                // Icon
                Image(systemName: page.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(page.color)
                    .rotationEffect(.degrees(isAnimating ? 10 : -10))
            }
            .frame(height: 350)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.5)
                    .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
            
            // Text Content
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingView()
    }
}
