//
//  NotificationView.swift
//  TaskManagerApp
//

import SwiftUI

struct NotificationView: View {
    @StateObject var viewModel = NotificationViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            if viewModel.notifications.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.notifications) { notification in
                            NotificationRow(notification: notification)
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
    
    private var header: some View {
        HStack {
            Text("Notifications")
                .font(.largeTitle.weight(.bold))
            Spacer()
            Button(action: {}) {
                Text("Mark all read")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color(hex: 0x7B61FF))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell.slash")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)
            Text("No new notifications")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NotificationRow: View {
    let notification: NotificationModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconBackgroundColor.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundStyle(iconBackgroundColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(notification.title)
                        .font(.subheadline.weight(.bold))
                    Spacer()
                    Text(notification.time)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Text(notification.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .secondarySystemBackground)))
    }
    
    private var iconName: String {
        switch notification.type {
        case .task: return "list.bullet.rectangle.fill"
        case .project: return "folder.fill"
        case .reminder: return "clock.fill"
        }
    }
    
    private var iconBackgroundColor: Color {
        switch notification.type {
        case .task: return Color(hex: 0x7B61FF)
        case .project: return Color(hex: 0x5B8BFF)
        case .reminder: return Color(hex: 0xFF6AA2)
        }
    }
}

#Preview {
    NotificationView()
        .environmentObject(MainTabViewModel())
}
