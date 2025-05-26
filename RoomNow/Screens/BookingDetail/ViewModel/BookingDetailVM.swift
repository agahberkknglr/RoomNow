//
//  BookingDetailVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 26.05.2025.
//

import Foundation
import FirebaseAuth

final class BookingDetailVM {
    
    var reservation: Reservation  // must be var to allow mutation
    private(set) var reservationId: String
    
    init(reservation: Reservation, reservationId: String) {
        self.reservation = reservation
        self.reservationId = reservationId
    }

    var isCancelable: Bool {
        reservation.status == .active && Date() < reservation.checkInDate
    }
    
    var numberOfNights: Int {
        let nights = Calendar.current.dateComponents([.day], from: reservation.checkInDate, to: reservation.checkOutDate).day ?? 1
        return max(nights, 1)
    }

    func cancelReservation(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in."])))
            return
        }

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
            FirebaseManager.shared.removeBookedDate(
                hotelId: reservation.hotelId,
                roomNumber: roomNumber,
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
