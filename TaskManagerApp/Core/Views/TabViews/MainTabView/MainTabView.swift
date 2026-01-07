//
//  MainTabView.swift
//  TaskManagerApp
//
//  Created by Ohiocheoya Emmanuel on 07/01/2026.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var viewModel: TasksViewModel = TasksViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            switch viewModel.selectedTab {
            case 0:
                TaskTabView(viewModel: viewModel)
            case 1:
                ScrollView {
                    Text("Chart Page")
                }
            case 2:
                ScrollView {
                    Text("Chart Page")
                }
            case 3:
                ScrollView {
                    Text("Chart Page")
                }
            default:
                ScrollView {
                    EmptyView()
                }
            }
            
            Spacer()
            
            BottomTabBar(viewModel: viewModel)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

#Preview {
    MainTabView()
}
