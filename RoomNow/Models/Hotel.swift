//
//  Hotel.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 28.04.2025.
//

import Foundation

struct Hotel: Decodable {
    var id: String?
    let name: String
    let city: String
    let rating: Double
    let description: String
    let imageUrls: [String]
    let amenities: [String]
    let roomTypes: [RoomType]
}

struct RoomType: Decodable {
    let typeName: String
    let rooms: [HotelRoom]
}

struct HotelRoom: Decodable {
    let bedCapacity: Int
    let description: String
    let price: Double
    let roomNumber: String
    //let bookedDates: BookedDates?
}

//struct BookedDates: Decodable {
//
//}

