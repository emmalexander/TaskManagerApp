//
//  BottomTabBar.swift
//  TaskManagerApp
//
//  Created by Ohiocheoya Emmanuel on 07/01/2026.
//

import SwiftUI

struct BottomTabBar: View {
    @EnvironmentObject var viewModel: MainTabViewModel
    
    var body: some View {
        HStack(spacing: 40) {
            bottomItem(system: "house.fill", index: 0)
            bottomItem(system: "calendar", index: 1)
            bottomItem(system: "magnifyingglass", index: 2)
            bottomItem(system: "person.fill", index: 3)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)
        )
        //.padding(.horizontal, 24)
        .padding(.bottom, 12)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    func bottomItem(system: String, index: Int) -> some View {
        Button(action: { withAnimation(.spring) { viewModel.selectedTab = index } }) {
            Image(systemName: system)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(viewModel.selectedTab == index ? Color(hex: 0x7B61FF) : .secondary)
                .padding(10)
                .background(
                    Group {
                        if viewModel.selectedTab == index {
                            Circle().fill(Color(hex: 0x7B61FF).opacity(0.12))
                        } else {
                            Circle().fill(Color.clear)
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    BottomTabBar()
        .environmentObject(MainTabViewModel())
}
