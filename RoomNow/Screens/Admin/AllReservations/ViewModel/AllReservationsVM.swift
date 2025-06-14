//
//  AllReservationsVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 14.06.2025.
//

import Foundation

protocol AllReservationsVMProtocol {
    var reservations: [AdminReservation] { get }
    func fetchReservations(completion: @escaping () -> Void)
}

final class AllReservationsVM: AllReservationsVMProtocol {
    private(set) var reservations: [AdminReservation] = []

    func fetchReservations(completion: @escaping () -> Void) {
        FirebaseManager.shared.fetchAllReservations { [weak self] reservations in
            self?.reservations = reservations
            completion()
        }
    }
}

