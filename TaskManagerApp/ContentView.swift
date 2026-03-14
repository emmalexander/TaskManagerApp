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
    @State private var resetID = UUID()
    
    var body: some View {
        SplashScreen()
            .environmentObject(mainTabViewModel)
            .id(resetID)
            .alert("Session Expired", isPresented: $tokenManager.sessionExpiredAlert) {
                Button("OK", role: .cancel) {
                    resetID = UUID()
                }
            } message: {
                Text("Your session has expired. Please sign in again.")
            }
    }
}

#Preview {
    ContentView()
}
