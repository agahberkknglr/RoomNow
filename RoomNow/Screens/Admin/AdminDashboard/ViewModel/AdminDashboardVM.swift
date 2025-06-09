//
//  AdminDashboardVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 1.06.2025.
//

import Foundation


final class AdminDashboardVM {

    var allHotels: [Hotel] = []
    var filteredHotels: [Hotel] = []
    var didUpdate: (() -> Void)?
    var adminName: String = "Hotel Manager"
    
    var cities: [String] {
        let allCities = allHotels.map { $0.city }
        return Array(Set(allCities)).sorted()
    }
 
    func fetchHotels() {
        FirebaseManager.shared.fetchHotels { [weak self] result in
            switch result {
            case .success(let hotels):
                self?.allHotels = hotels
                self?.filteredHotels = hotels
                self?.didUpdate?()
            case .failure(let error):
                print("Fetch hotels error: \(error)")
            }
        }
    }

    func filter(by city: String?) {
        if let city = city {
            filteredHotels = allHotels.filter { $0.city == city }
        } else {
            filteredHotels = allHotels
        }
        didUpdate?()
    }
}
