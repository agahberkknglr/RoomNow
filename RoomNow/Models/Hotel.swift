//
//  Hotel.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 28.04.2025.
//

import Foundation

struct Hotel: Codable {
    var id: String?
    let name: String
    let city: String
    let rating: Double
    let location: String
    let description: String
    let imageUrls: [String]
    let amenities: [String]
    let roomTypes: [RoomType]
}

struct RoomType: Codable {
    let typeName: String
    let rooms: [HotelRoom]
}

struct HotelRoom: Codable {
    let bedCapacity: Int
    let description: String
    let price: Double
    let roomNumber: String
    let bookedDates: [BookedDateRange]?
}

struct BookedDateRange: Codable {
    let start: Date?
    let end: Date?
}

extension HotelRoom {
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

extension Hotel {
    static func mockFromSaved(_ saved: SavedHotel) -> Hotel {
        return Hotel(
            id: saved.hotelId,
            name: saved.hotelName,
            city: saved.city,
            rating: 4.5,
            location: "",
            description: "",
            imageUrls: [],
            amenities: [],
            roomTypes: []
        )
    }
}
