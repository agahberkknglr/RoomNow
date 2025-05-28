//
//  Date.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 28.05.2025.
//

import UIKit

extension Date {
    func toShortReadableFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMMM d"
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }
}
