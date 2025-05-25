//
//  BookingsVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.04.2025.
//

import Foundation
import FirebaseAuth

final class BookingsVM {
    private(set) var groupedReservations: [(city: String, reservations: [Reservation])] = []

    func fetchReservations(completion: @escaping () -> Void) {
        FirebaseManager.shared.fetchReservations { [weak self] result in
            switch result {
            case .success(let reservations):

                let updatedReservations: [Reservation] = reservations.map { reservation in
                    var updatedReservation = reservation
                    if Date() > reservation.checkOutDate &&
                        reservation.status == .active {
                        
                        updatedReservation.status = .completed
                        updatedReservation.completedAt = Date()
                        
                        if let uid = Auth.auth().currentUser?.uid {
                            if let id = updatedReservation.id {
                                FirebaseManager.shared.markReservationCompleted(
                                    userId: uid,
                                    reservationId: id,
                                    date: updatedReservation.completedAt!
                                )
                            }
                        }
                    }
                    return updatedReservation
                }

                let groupedDict = Dictionary(grouping: updatedReservations) { $0.city }
                self?.groupedReservations = groupedDict
                    .map { (city: $0.key.capitalized, reservations: $0.value) }
                    .sorted(by: { $0.city < $1.city })

            case .failure(let error):
                print("❌ Failed to fetch reservations:", error.localizedDescription)
                self?.groupedReservations = []
            }
            completion()
        }
    }

    
    var numberOfSections: Int {
        groupedReservations.count
    }

    func numberOfItems(in section: Int) -> Int {
        groupedReservations[section].reservations.count
    }

    func reservation(at indexPath: IndexPath) -> Reservation {
        groupedReservations[indexPath.section].reservations[indexPath.row]
    }

    func cityTitle(for section: Int) -> String {
        groupedReservations[section].city.capitalized
    }
}
