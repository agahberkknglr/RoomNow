//
//  HotelDetailVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.04.2025.
//

import Foundation
import CoreLocation
import FirebaseAuth
import FirebaseFirestore

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
    var hotelForNavigation: Hotel { get }
    var searchParamsForNavigation: HotelSearchParameters { get }
    var isSaved: Bool { get set }

    func loadSavedStatus(completion: @escaping () -> Void)
    func toggleSavedStatus(completion: @escaping () -> Void)
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
    
    var hotelForNavigation: Hotel { hotel }
    var searchParamsForNavigation: HotelSearchParameters { searchParams }
    
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
    
    var isSaved: Bool = false

    func loadSavedStatus(completion: @escaping () -> Void) {
        guard let hotelId = hotel.id else {
            print(" Hotel ID is nil")
            completion()
            return
        }
        FirebaseManager.shared.isHotelSaved(for: hotelId) { [weak self] result in
            switch result {
            case .success(let saved):
                self?.isSaved = saved
            case .failure(let error):
                print(" Failed to load saved status:", error.localizedDescription)
                self?.isSaved = false
            }
            completion()
        }
    }

    func toggleSavedStatus(completion: @escaping () -> Void) {
        guard let hotelId = hotel.id else {
            print(" Hotel ID is nil")
            completion()
            return
        }
        
        if isSaved {
            FirebaseManager.shared.deleteSavedHotel(hotelId: hotelId) { [weak self] result in
                if case .success = result {
                    self?.isSaved = false
                }
                completion()
            }
        } else {
            let nights = Calendar.current.dateComponents([.day], from: checkInDate, to: checkOutDate).day ?? 1
            guard let cheapest = cheapestRoom else {
                return
            }
            let totalPrice = nights * Int(cheapest.price)

            let saved = SavedHotel(
                hotelId: hotelId,
                hotelName: hotel.name,
                city: hotel.city,
                location: hotel.location,
                savedAt: Date(),
                checkInDate: searchParams.checkInDate,
                checkOutDate: searchParams.checkOutDate,
                guestCount: searchParams.guestCount,
                roomCount: searchParams.roomCount,
                selectedRoomNumber: cheapest.roomNumber,
                totalPrice: totalPrice,
                numberOfNights: nights
            )
            
            FirebaseManager.shared.saveHotel(saved) { [weak self] result in
                if case .success = result {
                    self?.isSaved = true
                }
                completion()
            }
            
        }
    }
}


