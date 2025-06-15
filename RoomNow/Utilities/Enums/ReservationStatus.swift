
//
//  ReservationStatus.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 25.05.2025.
//

import UIKit

enum ReservationStatus: String, Codable, CaseIterable {
    case active
    case ongoing
    case cancelled
    case completed
    
    var description: String {
        switch self {
        case .active, .ongoing:
            return "Reservations can be canceled up to 1 day before check-in."
        case .completed:
            return "This reservation has been completed."
        case .cancelled:
            return "This reservation was cancelled."
        }
    }

    var color: UIColor {
        switch self {
        case .active: return .appSuccess
        case .ongoing: return .appWarning
        case .completed: return .appSecondaryText
        case .cancelled: return .appError
        }
    }
}
