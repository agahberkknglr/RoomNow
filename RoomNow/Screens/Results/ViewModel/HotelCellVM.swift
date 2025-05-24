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
    var roomCombination: [(room: HotelRoom, typeName: String)] = []

    private(set) var isSaved: Bool = false

    init(hotel: Hotel, searchParams: HotelSearchParameters) {
        self.hotel = hotel
        self.searchParams = searchParams
        self.roomCombination = findValidRoomCombination(from: hotel)
    }

    var hotelId: String? { hotel.id }
    var hotelName: String { hotel.name }
    var hotelLocation: String { hotel.location }
    var hotelRatingText: String { "\(hotel.rating)" }
    
    private func findValidRoomCombination(from hotel: Hotel) -> [(room: HotelRoom, typeName: String)] {
        let allRooms: [(HotelRoom, String)] = hotel.roomTypes.flatMap { type in
            type.rooms.filter {
                $0.isAvailable(for: searchParams.checkInDate, checkOut: searchParams.checkOutDate)
            }.map { ($0, type.typeName) }
        }
        
        let roomCombos = allRooms.combinations(ofCount: searchParams.roomCount)

        for combo in roomCombos {
            let totalBeds = combo.reduce(0) { $0 + $1.0.bedCapacity }
            if totalBeds >= searchParams.guestCount {
                return combo
            }
        }

        return []
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
            let roomCombination = findValidRoomCombination(from: hotel)

            guard !roomCombination.isEmpty else {
                completion(false)
                return
            }

            let totalPrice = roomCombination.reduce(0) { $0 + (Int($1.room.price) * nights) }
            let selectedRoomNumber = roomCombination.first?.room.roomNumber // Or nil if you don’t want to store it

            let saved = SavedHotel(
                hotelId: hotelId,
                hotelName: hotel.name,
                city: hotel.city,
                location: hotel.location,
                savedAt: Date(),
                checkInDate: checkInDate,
                checkOutDate: checkOutDate,
                guestCount: guestCount,
                roomCount: roomCombination.count,
                selectedRoomNumber: selectedRoomNumber,
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
