//
//  GetTasksByStatusResponse.swift
//  TaskManagerApp
//
//  Created by Ohiocheoya Emmanuel on 17/03/2026.
//

import Foundation

struct GetTasksByStatusResponse: Decodable {
    let success: Bool
    let data: GetTasksByStatusData
}

struct GetTasksByStatusData: Decodable {
    let page: Int
    let totalPages: Int
    let totalTasks: Int // Interest
    let tasks: [TaskModel]
}
