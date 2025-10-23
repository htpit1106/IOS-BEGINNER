//
//  Common.swift
//  Todo_App2
//
//  Created by Admin on 10/27/25.
//

import Foundation

class Common {
    
    
    func isoToDate(_ iso: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: iso) {
            return date
        }
        return nil
    }
    func dateToIso(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}
