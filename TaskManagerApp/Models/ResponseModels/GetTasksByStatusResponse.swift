//
//  GetTasksByStatusResponse.swift
//  TaskManagerApp
//
//  Created by Ohiocheoya Emmanuel on 17/03/2026.
//

import Foundation

struct GetTasksByStatusResponse: Decodable {
    let success: Bool
    let data: [TaskModel]
}
