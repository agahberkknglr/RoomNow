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
            amenities: []
        )
    }
}
