//
//  TasksViewModel.swift
//  TaskManagerApp
//
//  Created by Ohiocheoya Emmanuel on 07/01/2026.
//

import Foundation
import Combine

class TasksViewModel: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var selectedSegment: Int = 0 // 0: My Tasks, 1: In-progress, 2: Completed
}

