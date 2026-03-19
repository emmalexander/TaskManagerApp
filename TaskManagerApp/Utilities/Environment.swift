//
//  Environment.swift
//  TaskManagerApp
//
//  Created by Ohiocheoya Emmanuel on 18/03/2026.
//

import Foundation

public enum EnvironmentVariable {
    enum Keys {
        static let baseUrl: String = "BASE_URL"
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist file not found")
        }
        return dict
    }()
    
    static let baseUrl: String = {
        guard let baseUrlString = infoDictionary[Keys.baseUrl] as? String else {
            fatalError("base URL not set in plist file")
        }
        return baseUrlString
    }()
}
