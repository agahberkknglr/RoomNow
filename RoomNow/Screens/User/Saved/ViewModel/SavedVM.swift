//
//  SavedVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.04.2025.
//

import Foundation

final class SavedVM {
    private(set) var cityHotelMap: [String: [SavedHotel]] = [:]
    
    var isUserLoggedIn: Bool {
        return AuthManager.shared.currentUser != nil
    }

    func fetchSavedData(completion: @escaping () -> Void) {
        FirebaseManager.shared.fetchSavedHotels { [weak self] result in
            switch result {
            case .success(let hotels):
                self?.cityHotelMap = Dictionary(grouping: hotels, by: { $0.city })
            case .failure(let error):
                print(" Error fetching saved hotels: \(error)")
                self?.cityHotelMap = [:]
            }
            completion()
        }
    }

    var cityNames: [String] {
        Array(cityHotelMap.keys).sorted()
    }

    func hotels(for city: String) -> [SavedHotel] {
        cityHotelMap[city] ?? []
    }
}

