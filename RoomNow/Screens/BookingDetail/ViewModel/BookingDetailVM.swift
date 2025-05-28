//
//  BookingDetailVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 26.05.2025.
//

import Foundation
import FirebaseAuth

final class BookingDetailVM {
    
    private(set) var hotel: Hotel?
    private(set) var bookedRooms: [String: Room] = [:]
    var reservation: Reservation
    private(set) var reservationId: String
    
    var onHotelDataUpdated: (() -> Void)?
    
    init(reservation: Reservation, reservationId: String) {
        self.reservation = reservation
        self.reservationId = reservationId
        fetchHotelData()
    }
    
    private func fetchHotelData() {
        FirebaseManager.shared.fetchHotel(by: reservation.hotelId) { [weak self] result in
            switch result {
            case .success(let hotel):
                self?.hotel = hotel
                self?.onHotelDataUpdated?()
            case .failure(let error):
                print("Failed to fetch hotel data: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchRoomsForReservation(completion: @escaping () -> Void) {
        FirebaseManager.shared.fetchRooms(for: [reservation.hotelId]) { [weak self] result in
            switch result {
            case .success(let allRooms):

                let selectedNumbers = Set(self?.reservation.selectedRoomNumbers ?? [])
                let matchedRooms = allRooms.filter { selectedNumbers.contains($0.roomNumber) }
                for room in matchedRooms {
                    self?.bookedRooms[room.roomNumber] = room
                }
                completion()
            case .failure(let error):
                print("Failed to fetch rooms: \(error)")
                completion()
            }
        }
    }

    var isCancelable: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let checkInDay = Calendar.current.startOfDay(for: reservation.checkInDate)
        return reservation.status == .active && today < checkInDay
    }

    
    var canBeDeleted: Bool {
        return reservation.status == .cancelled || reservation.status == .completed
    }
    
    var numberOfNights: Int {
        let nights = Calendar.current.dateComponents([.day], from: reservation.checkInDate, to: reservation.checkOutDate).day ?? 1
        return max(nights, 1)
    }
    
    func deleteReservation(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in."])))
            return
        }

        FirebaseManager.shared.deleteReservation(userId: uid, reservationId: reservationId) { result in
            completion(result)
        }
    }

    func cancelReservation(completion: @escaping (Result<Void, Error>) -> Void) {

        FirebaseManager.shared.cancelReservation(for: reservationId) { [weak self] result in
            switch result {
            case .success:
                self?.reservation.status = .cancelled
                self?.reservation.cancelledAt = Date()
                self?.removeBookedDatesForRooms(completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func removeBookedDatesForRooms(completion: @escaping (Result<Void, Error>) -> Void) {
        let group = DispatchGroup()
        var firstError: Error?

        for roomNumber in reservation.selectedRoomNumbers {
            group.enter()
            let roomId = "\(reservation.hotelId)_\(roomNumber)"
            FirebaseManager.shared.removeBookedDate(
                roomId: roomId,
                startDate: reservation.checkInDate,
                endDate: reservation.checkOutDate
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
