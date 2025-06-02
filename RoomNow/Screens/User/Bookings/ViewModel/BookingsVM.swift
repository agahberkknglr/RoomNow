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
    private var imageCache: [String: String] = [:] 

    var isUserLoggedIn: Bool {
        return AuthManager.shared.currentUser != nil
    }
    
    func fetchReservations(completion: @escaping () -> Void) {
        FirebaseManager.shared.fetchReservations { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let reservations):
                let updatedReservations = reservations.map { res -> Reservation in
                    var updated = res
                    let now = Date()
                    
                    if now >= res.checkInDate && now < res.checkOutDate && res.status == .active {
                        updated.status = .ongoing
                        if let uid = Auth.auth().currentUser?.uid, let id = updated.id {
                            FirebaseManager.shared.markReservationOngoing(userId: uid, reservationId: id)
                        }
                    } else if now >= res.checkOutDate && res.status == .active {
                        updated.status = .completed
                        updated.completedAt = now
                        if let uid = Auth.auth().currentUser?.uid, let id = updated.id {
                            FirebaseManager.shared.markReservationCompleted(userId: uid, reservationId: id, date: now)
                        }
                    }

                    return updated
                }

                // Cache image URLs
                let dispatchGroup = DispatchGroup()

                for reservation in updatedReservations {
                    dispatchGroup.enter()
                    FirebaseManager.shared.fetchHotelImageURL(hotelId: reservation.hotelId) { [weak self] url in
                        self?.imageCache[reservation.hotelId] = url
                        dispatchGroup.leave()
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    let groupedDict = Dictionary(grouping: updatedReservations) { $0.city }
                    self.groupedReservations = groupedDict
                        .map { (city: $0.key.capitalized, reservations: $0.value) }
                        .sorted { $0.city < $1.city }

                    completion()
                }

            case .failure(let error):
                print("❌ Failed to fetch reservations:", error.localizedDescription)
                self.groupedReservations = []
                completion()
            }
        }
    }

    func imageURL(for hotelId: String) -> String? {
        imageCache[hotelId]
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
