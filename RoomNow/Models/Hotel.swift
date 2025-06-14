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
    let latitude: Double
    let longitude: Double
    let imageUrls: [String]
    let amenities: [String]
    let isAvailable: Bool
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
            latitude: 0.0,
            longitude: 0.0,
            imageUrls: [],
            amenities: [],
            isAvailable: true
        )
    }
}
