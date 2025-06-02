//
//  ReservationVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.04.2025.
//

import Foundation
import FirebaseAuth

final class ReservationVM {
    let hotel: Hotel
    let searchParams: HotelSearchParameters
    let selectedRooms: [Room]

    let fullName: String
    let email: String
    let phone: String
    let note: String?

    init(
        hotel: Hotel,
        searchParams: HotelSearchParameters,
        selectedRooms: [Room],
        fullName: String,
        email: String,
        phone: String,
        note: String?
    ) {
        self.hotel = hotel
        self.searchParams = searchParams
        self.selectedRooms = selectedRooms
        self.fullName = fullName
        self.email = email
        self.phone = phone
        self.note = note
    }

    var numberOfNights: Int {
        let nights = Calendar.current.dateComponents([.day], from: searchParams.checkInDate, to: searchParams.checkOutDate).day ?? 1
        return max(nights, 1)
    }

    var totalPrice: Int {
        selectedRooms.reduce(0) { $0 + (Int($1.price) * numberOfNights) }
    }
    
    func confirmReservation(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let hotelId = hotel.id else {
            let error = NSError(domain: "ReservationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Hotel ID is missing."])
            completion(.failure(error))
            return
        }

        let roomIds = selectedRooms.compactMap { $0.id }

        FirebaseManager.shared.checkRoomAvailability(
            roomIds: roomIds,
            startDate: searchParams.checkInDate,
            endDate: searchParams.checkOutDate
        ) { [weak self] result in
            switch result {
            case .success(let allAvailable):
                guard allAvailable else {
                    let error = NSError(domain: "ReservationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "One or more rooms are no longer available."])
                    completion(.failure(error))
                    return
                }

                guard let self = self else { return }

                let reservation = Reservation(
                    hotelId: hotelId,
                    hotelName: hotel.name,
                    city: hotel.city,
                    checkInDate: self.searchParams.checkInDate,
                    checkOutDate: self.searchParams.checkOutDate,
                    guestCount: self.searchParams.guestCount,
                    roomCount: self.selectedRooms.count,
                    selectedRoomNumbers: self.selectedRooms.map { $0.roomNumber },
                    totalPrice: self.totalPrice,
                    fullName: self.fullName,
                    email: self.email,
                    phone: self.phone,
                    note: self.note?.isEmpty == true ? nil : self.note,
                    reservedAt: Date(),
                    status: .active,
                    completedAt: nil,
                    cancelledAt: nil
                )

                FirebaseManager.shared.saveReservation(reservation) { result in
                    switch result {
                    case .success:
                        self.updateRoomDates(completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func updateRoomDates(completion: @escaping (Result<Void, Error>) -> Void) {
        let group = DispatchGroup()
        var firstError: Error?
        
        for room in selectedRooms {
            group.enter()
            guard let roomId = room.id else {
                print("Room ID is nil for room number: \(room.roomNumber)")
                continue
            }
            FirebaseManager.shared.updateBookedDates(
                for: roomId,
                startDate: searchParams.checkInDate,
                endDate: searchParams.checkOutDate
            ) { result in
                if case .failure(let error) = result, firstError == nil {
                    firstError = error
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let error = firstError {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }


}
