//
//  UserDetailVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 16.06.2025.
//

import Foundation

protocol UserDetailVMProtocol {
    var user: AppUser { get }
    var reservations: [Reservation] { get }
    var onDataChanged: (() -> Void)? { get set }

    func fetchReservations()
}

final class UserDetailVM: UserDetailVMProtocol {
    let user: AppUser
    private(set) var reservations: [Reservation] = [] {
        didSet { onDataChanged?() }
    }
    var onDataChanged: (() -> Void)?

    init(user: AppUser) {
        self.user = user
    }

    func fetchReservations() {
        FirebaseManager.shared.fetchReservations(forUserId: user.uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let reservations):
                    self?.reservations = reservations
                    self?.onDataChanged?()
                case .failure(let error):
                    print("Error fetching reservations:", error)
                }
            }
        }
    }

}
