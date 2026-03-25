//
//  ContentView.swift
//  TaskManagerApp
//
//  Created by Ohiocheoya Emmanuel on 07/01/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var tokenManager = TokenManager.shared
    @StateObject private var mainTabViewModel = MainTabViewModel()
    @StateObject private var profileTabViewModel = ProfileViewModel()
    @StateObject private var toastManager = ToastManager.shared
    
    @State private var appState: AppState = .splash
    @State private var resetID = UUID()

    enum AppState {
        case splash
        case onboarding
        case auth
        case main
    }

    var body: some View {
        Group {
            switch appState {
            case .splash:
                SplashScreen(appState: $appState)
            case .onboarding:
                OnboardingView()
            case .auth:
                SignInView()
            case .main:
                MainTabView()
            }
        }
        .environmentObject(mainTabViewModel)
        .environmentObject(profileTabViewModel)
        .environmentObject(toastManager)
        .id(resetID)
        .onChange(of: tokenManager.token) { newToken in
            if newToken != nil && appState == .auth {
                withAnimation { appState = .main }
            } else if newToken == nil && appState == .main {
                withAnimation { appState = .auth }
            }
        }
        .alert("Session Expired", isPresented: $tokenManager.sessionExpiredAlert) {
            Button("OK", role: .cancel) {
                appState = .auth
                resetID = UUID()
            }
        } message: {
            Text("Your session has expired. Please sign in again.")
        }
        .toastOverlay(manager: toastManager)
    }
}

#Preview {
    ContentView()
}
