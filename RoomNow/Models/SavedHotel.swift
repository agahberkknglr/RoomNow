//
//  SavedHotel.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 21.05.2025.
//

import Foundation

struct SavedHotel: Codable {
    let hotelId: String
    let hotelName: String
    let city: String
    let location: String
    let savedAt: Date
    let checkInDate: Date
    let checkOutDate: Date
    let guestCount: Int
    let roomCount: Int
    let selectedRoomNumber: String?
    let totalPrice: Int
    let numberOfNights: Int
    let imageUrl: String
}
