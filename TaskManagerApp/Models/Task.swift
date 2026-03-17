//
//  Task.swift
//  TaskManagerApp
//
//  Created by Ohiocheoya Emmanuel on 07/01/2026.
//

import Foundation

struct TaskModel: Identifiable, Decodable {
    let id: String
    var title: String
    var description: String?
    var status: String
    let dueDate: Date?
    let userId: String
    let taskListId: String
    var isStarred: Bool?
    let createdAt, updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, description, status, dueDate, userId, taskListId, isStarred, createdAt, updatedAt
    }
}
