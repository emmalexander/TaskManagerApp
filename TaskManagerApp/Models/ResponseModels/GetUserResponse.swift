//
//  GetUserResponse.swift
//  TaskManagerApp
//
//  Created by Ohiocheoya Emmanuel on 12/03/2026.
//

import Foundation

struct GetUserResponse: Decodable {
    let success: Bool
    let data: UserData
}

struct UserData: Decodable {
    let user: User
    let taskLists: [TaskList]
}

struct User: Decodable {
    let id: String
    let firstName, lastName, email: String
    let phoneNumber: String?
    let createdAt: Date
    //let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName, lastName, email, phoneNumber, createdAt
             //updatedAt
    }
}

struct TaskList: Identifiable, Decodable {
    let id: String
    let name: String
    let description: String?
    let tasks: [TaskModel]
    let userId: String
    let isDefault: Bool
    let createdAt, updatedAt: Date
    //let v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, description, tasks, userId, isDefault, createdAt, updatedAt
        //case v = "__v"
    }
}

