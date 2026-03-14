//
//  NotificationViewModel.swift
//  TaskManagerApp
//

import Foundation
import Combine

struct NotificationModel: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let time: String
    let type: NotificationType
}

enum NotificationType {
    case task, project, reminder
}

class NotificationViewModel: ObservableObject {
    @Published var notifications: [NotificationModel] = []
    
    init() {
        loadMockNotifications()
    }
    
    private func loadMockNotifications() {
        notifications = [
            NotificationModel(title: "Task Assigned", message: "You have been assigned to 'Design System Update'", time: "2h ago", type: .task),
            NotificationModel(title: "Project Deadline", message: "Deadline for 'App Launch' is approaching", time: "5h ago", type: .project),
            NotificationModel(title: "Reminder", message: "Don't forget to review the weekly report", time: "1d ago", type: .reminder)
        ]
    }
}
