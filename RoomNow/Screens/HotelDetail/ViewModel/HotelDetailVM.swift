//
//  HotelDetailVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.04.2025.
//

import Foundation
import CoreLocation

// MARK: - Protocol

enum HotelDetailSectionType {
    case title
    case imageGallery
    case checkInOut
    case roomGuestInfo
    case cheapestRoom
    case map
    case amenities
    case description
}

struct HotelDetailSection {
    let type: HotelDetailSectionType
    let data: Any?
}

protocol HotelDetailVMProtocol: AnyObject {
    var sections: [HotelDetailSection] { get }
    var hotelName: String { get }
    var location: String { get }
    var ratingText: String { get }
    var imageUrls: [String] { get }
    var checkInDateText: String { get }
    var checkOutDateText: String { get }
    var checkInDate: Date { get }
    var checkOutDate: Date { get }
    var guestInfoText: String { get }
    var cheapestRoom: HotelDetailVM.RoomDisplayData? { get }
    var mockCoordinate: CLLocationCoordinate2D { get }
    var amenities: [Amenity] { get }
    var description: String { get }
}

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

    var sections: [HotelDetailSection] {
        return [
            HotelDetailSection(type: .title, data: nil),
            HotelDetailSection(type: .imageGallery, data: imageUrls),
            HotelDetailSection(type: .checkInOut, data: [checkInDateText, checkOutDateText]),
            HotelDetailSection(type: .roomGuestInfo, data: guestInfoText),
            HotelDetailSection(type: .cheapestRoom, data: cheapestRoom),
            HotelDetailSection(type: .map, data: nil),
            HotelDetailSection(type: .amenities, data: amenities),
            HotelDetailSection(type: .description, data: description)
        ]
    }

    var hotelName: String { hotel.name }
    var location: String { hotel.location }
    var ratingText: String { "⭐️ \(hotel.rating)" }
    //var imageUrls: [String] { hotel.imageUrls }
    var imageUrls: [String] {
        return ["hotelph", "hotelph", "hotelph", "hotelph"]
    }

    var checkInDateText: String {
        format(date: searchParams.checkInDate)
    }

    var checkOutDateText: String {
        format(date: searchParams.checkOutDate)
    }
    
    var checkInDate: Date {
        searchParams.checkInDate
    }
    
    var checkOutDate: Date {
        searchParams.checkOutDate
    }

    var guestInfoText: String {
        "\(searchParams.roomCount) room • \(searchParams.guestCount) guests"
    }

    var cheapestRoom: RoomDisplayData? {
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
        }.min(by: { $0.price < $1.price })
    }

    var mockCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784) // Istanbul
    }
    
    var amenities: [Amenity] {
        hotel.amenities.compactMap { Amenity.from(string: $0) }
    }

    var description: String {
        hotel.description
    }

    private func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        formatter.timeZone = TimeZone(identifier: "Europe/Istanbul")
        return formatter.string(from: date)
    }
}


