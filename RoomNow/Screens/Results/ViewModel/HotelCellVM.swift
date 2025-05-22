//
//  HotelCellVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 22.05.2025.
//

import Foundation

final class HotelCellVM {
    private let hotel: Hotel
    private let searchParams: HotelSearchParameters

    var checkInDate: Date { searchParams.checkInDate }
    var checkOutDate: Date { searchParams.checkOutDate }
    var guestCount: Int { searchParams.guestCount }
    
    private(set) var isSaved: Bool = false

    init(hotel: Hotel, searchParams: HotelSearchParameters) {
        self.hotel = hotel
        self.searchParams = searchParams
    }

    var hotelId: String? { hotel.id }
    var hotelName: String { hotel.name }
    var hotelLocation: String { hotel.location }
    var hotelRatingText: String { "\(hotel.rating)" }

    var cheapestAvailableRoom: (typeName: String, room: HotelRoom)? {
        return hotel.roomTypes
            .flatMap { type in type.rooms.map { (typeName: type.typeName, room: $0) } }
            .filter {
                $0.room.bedCapacity >= searchParams.guestCount &&
                $0.room.isAvailable(for: searchParams.checkInDate, checkOut: searchParams.checkOutDate)
            }
            .min(by: { $0.room.price < $1.room.price })
    }

    func loadSavedStatus(completion: @escaping () -> Void) {
        guard let id = hotel.id else {
            completion()
            return
        }

        FirebaseManager.shared.isHotelSaved(for: id) { [weak self] result in
            if case .success(let saved) = result {
                self?.isSaved = saved
            }
            completion()
        }
    }

    func toggleSaveStatus(completion: @escaping (Bool) -> Void) {
        guard let hotelId = hotel.id else {
            completion(false)
            return
        }

        if isSaved {
            FirebaseManager.shared.deleteSavedHotel(hotelId: hotelId) { [weak self] result in
                if case .success = result {
                    self?.isSaved = false
                }
                completion(self?.isSaved ?? false)
            }
        } else {
            let nights = Calendar.current.dateComponents([.day], from: checkInDate, to: checkOutDate).day ?? 1
            guard let cheapest = cheapestAvailableRoom else {
                completion(false)
                return
            }
            let totalPrice = nights * Int(cheapest.room.price)

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
                selectedRoomNumber: cheapestAvailableRoom?.room.roomNumber,
                totalPrice: totalPrice,
                numberOfNights: nights
            )

            FirebaseManager.shared.saveHotel(saved) { [weak self] result in
                if case .success = result {
                    self?.isSaved = true
                }
                completion(self?.isSaved ?? false)
            }
        }
    }

}
