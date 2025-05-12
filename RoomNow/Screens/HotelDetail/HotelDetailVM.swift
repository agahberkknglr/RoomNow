//
//  HotelDetailVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.04.2025.
//

import Foundation

// MARK: - Protocol

protocol HotelDetailVMProtocol: AnyObject {
    var hotelName: String { get }
    var location: String { get }
    var ratingText: String { get }
    var description: String { get }
    var imageUrls: [String] { get }
    var amenities: [String] { get }
    var availableRooms: [HotelDetailVM.RoomDisplayData] { get }
}

// MARK: - ViewModel

final class HotelDetailVM: HotelDetailVMProtocol {
    
    struct RoomDisplayData {
        let typeName: String
        let roomNumber: String
        let bedCapacity: Int
        let price: Double
        let description: String
    }

    private let hotel: Hotel
    private let searchParams: HotelSearchParameters

    init(hotel: Hotel, searchParams: HotelSearchParameters) {
        self.hotel = hotel
        self.searchParams = searchParams
    }

    var hotelName: String { hotel.name }
    var location: String { hotel.location }
    var ratingText: String { "⭐️ \(hotel.rating)" }
    var description: String { hotel.description }
    var imageUrls: [String] { hotel.imageUrls }
    var amenities: [String] { hotel.amenities }

    var availableRooms: [RoomDisplayData] {
        hotel.roomTypes.flatMap { type in
            type.rooms.filter {
                $0.isAvailable(for: searchParams.checkInDate, checkOut: searchParams.checkOutDate)
            }.map { room in
                RoomDisplayData(
                    typeName: type.typeName,
                    roomNumber: room.roomNumber,
                    bedCapacity: room.bedCapacity,
                    price: room.price,
                    description: room.description
                )
            }
        }
    }
}

