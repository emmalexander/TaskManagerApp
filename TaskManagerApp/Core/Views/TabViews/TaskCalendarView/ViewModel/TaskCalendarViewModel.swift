//
//  CalendarViewModel.swift
//  TaskManagerApp
//

import Foundation
import Combine

class TaskCalendarViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var tasksForSelectedDate: [TaskModel] = []
    
    // In a real app, we would fetch tasks from the API for the selected date
    func fetchTasks() {
        // Placeholder implementation
    }
}
