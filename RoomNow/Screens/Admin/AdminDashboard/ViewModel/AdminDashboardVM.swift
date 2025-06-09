//
//  AdminDashboardVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 1.06.2025.
//

import Foundation


final class AdminDashboardVM {

    var hotels: [Hotel] = []
    var didUpdate: (() -> Void)?
    var adminName: String = "Hotel Manager"

    func fetchHotels() {
        FirebaseManager.shared.fetchHotels { [weak self] result in
            switch result {
            case .success(let hotels):
                self?.hotels = hotels
                self?.didUpdate?()
            case .failure(let error):
                print("Failed to fetch hotels:", error)
            }
        }
    }
}
