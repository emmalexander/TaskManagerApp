//
//  JSONDecoder+Ext.swift
//  TaskManagerApp
//
//  Created by Antigravity on 12/03/2026.
//

import Foundation

extension JSONDecoder {
    /// A pre-configured JSONDecoder for API responses with support for various ISO8601 date formats.
    static var apiDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds
        return decoder
    }
}

extension JSONDecoder.DateDecodingStrategy {
    /// A custom date decoding strategy that handles ISO8601 strings with or without fractional seconds.
    static let iso8601WithFractionalSeconds = custom { decoder in
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss'Z'"
        ]
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
    }
}
