//
//  AllReservationsVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 14.06.2025.
//

import Foundation

protocol AllReservationsVMProtocol {
    var reservations: [AdminReservation] { get }
    var allReservations: [AdminReservation] { get }
    var currentFilter: ReservationFilter { get set }
    func fetchReservations(completion: @escaping () -> Void)
}

final class AllReservationsVM: AllReservationsVMProtocol {
    private(set) var reservations: [AdminReservation] = []
    private(set) var allReservations: [AdminReservation] = []

    var currentFilter = ReservationFilter() {
        didSet { applyFilter() }
    }

    func fetchReservations(completion: @escaping () -> Void) {
        FirebaseManager.shared.fetchAllReservations { [weak self] fetched in
            self?.allReservations = fetched
            self?.applyFilter()
            completion()
        }
    }

    private func applyFilter() {
        if currentFilter.isEmpty {
            reservations = allReservations
        } else {
            reservations = allReservations.filter { currentFilter.matches($0) }
        }
    }
}



