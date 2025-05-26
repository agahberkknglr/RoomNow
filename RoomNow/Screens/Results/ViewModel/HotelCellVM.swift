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
    private let allRooms: [Room]

    var checkInDate: Date { searchParams.checkInDate }
    var checkOutDate: Date { searchParams.checkOutDate }
    var guestCount: Int { searchParams.guestCount }

    private(set) var isSaved: Bool = false
    private(set) var roomCombination: [Room] = []

    init(hotel: Hotel, rooms: [Room], searchParams: HotelSearchParameters) {
        self.hotel = hotel
        self.searchParams = searchParams
        self.allRooms = rooms
        self.roomCombination = findValidRoomCombination()
    }

    var hotelId: String? { hotel.id }
    var hotelName: String { hotel.name }
    var hotelLocation: String { hotel.location }
    var hotelRatingText: String { "\(hotel.rating)" }
    var hotelImageUrl: String? { return hotel.imageUrls.first }
    
    private func findValidRoomCombination() -> [Room] {
        let availableRooms = allRooms.filter {
            $0.isAvailable(for: searchParams.checkInDate, checkOut: searchParams.checkOutDate)
        }

        if searchParams.roomCount == 1 {
            return availableRooms.first(where: { $0.bedCapacity >= searchParams.guestCount }).map { [$0] } ?? []
        } else {
            let combinations = availableRooms.combinations(ofCount: searchParams.roomCount)
            for combo in combinations {
                let totalBeds = combo.reduce(0) { $0 + $1.bedCapacity }
                if totalBeds >= searchParams.guestCount {
                    return combo
                }
            }
            return []
        }
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
            
            guard !roomCombination.isEmpty else {
                completion(false)
                return
            }

            let totalPrice = roomCombination.reduce(0) { $0 + Int($1.price) * nights }
            let selectedRoomNumber = roomCombination.first?.roomNumber

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
