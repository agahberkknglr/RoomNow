//
//  Room.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 25.05.2025.
//

import Foundation
import FirebaseFirestore

struct Room: Codable {
    @DocumentID var id: String?
    let hotelId: String
    let roomType: String
    let roomNumber: String
    let bedCapacity: Int
    let description: String
    let price: Double
    let bookedDates: [BookedDateRange]?
}

struct BookedDateRange: Codable {
    let start: Date?
    let end: Date?
}

extension Room {
    func isAvailable(for checkIn: Date, checkOut: Date) -> Bool {
        guard let bookedDates = bookedDates else { return true }
        
        for booking in bookedDates {
            guard let start = booking.start, let end = booking.end else {
                continue
            }
            if (checkIn < end) && (checkOut > start) {
                return false
            }
        }
        return true
    }
}
