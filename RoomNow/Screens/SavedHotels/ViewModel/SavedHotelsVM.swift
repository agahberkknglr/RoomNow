//
//  SavedHotelsVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 22.05.2025.
//

import Foundation

final class SavedHotelsVM {
    let city: String
    private(set) var savedHotels: [SavedHotel]

    init(city: String, savedHotels: [SavedHotel]) {
        self.city = city
        self.savedHotels = savedHotels
    }

    var numberOfItems: Int {
        savedHotels.count
    }

    func hotel(at index: Int) -> SavedHotel {
        savedHotels[index]
    }
    
    func removeHotel(at index: Int) {
        guard savedHotels.indices.contains(index) else { return }
        savedHotels.remove(at: index)
    }
    
    func reloadSavedHotels(completion: @escaping () -> Void) {
        FirebaseManager.shared.fetchSavedHotels { [weak self] result in
            switch result {
            case .success(let hotels):
                self?.savedHotels = hotels.filter { $0.city.lowercased() == self?.city.lowercased() }
            case .failure(let error):
                print("Failed to reload saved hotels:", error.localizedDescription)
            }
            completion()
        }
    }

}

