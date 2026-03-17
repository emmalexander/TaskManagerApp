//
//  MainTabView.swift
//  TaskManagerApp
//
//  Created by Ohiocheoya Emmanuel on 07/01/2026.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var viewModel: MainTabViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            switch viewModel.selectedTab {
            case 0:
                TaskTabView()
            case 1:
                TaskCalendarView()
            case 2:
                NotificationView()
            case 3:
                ProfileView()
            default:
                EmptyView()
            }
            
            Spacer()
            
            BottomTabBar()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .onAppear{
            viewModel.getUser()
            viewModel.getUserTasksInProgress()
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(MainTabViewModel())
}
