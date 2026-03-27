//
//  SignInResponse.swift
//  TaskManagerApp
//
//  Created by Ohiocheoya Emmanuel on 26/03/2026.
//

import Foundation

struct SignInResponse: Decodable {
    let success: Bool
    let message: String?
    let data: SignInData
}

struct SignInData: Decodable {
    //let user: User
    let accessToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "accessToken"
        case refreshToken = "refreshToken"
    }
}
