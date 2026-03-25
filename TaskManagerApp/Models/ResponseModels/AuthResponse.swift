//
//  AuthResponse.swift
//  TaskManagerApp
//
//  Created by Ohiocheoya Emmanuel on 12/03/2026.
//

// Authentication response models
struct AuthResponse: Decodable {
    let success: Bool
    let message: String?
    let data: AuthData
}

struct AuthData: Decodable {
    let user: User
    let accessToken: String
    let refreshToken: String?
}
