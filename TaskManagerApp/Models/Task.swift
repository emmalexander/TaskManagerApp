//
//  Task.swift
//  TaskManagerApp
//
//  Created by Ohiocheoya Emmanuel on 07/01/2026.
//

import Foundation

struct TaskModel: Identifiable {
    var id: ObjectIdentifier
    var name: String
    var isCompleted: Bool
    var progress: Double
    let createdAt: Date
}
