//
//  PersonalInfoVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 23.05.2025.
//

import Foundation

final class PersonalInfoVM {
    // MARK: - Outputs for binding
    var fullName: String = ""
    var email: String = ""
    var phone: String = ""
    var note: String?
    
    var notifyViewUpdate: (() -> Void)?

    // MARK: - Data required for reservation
    let hotel: Hotel
    let searchParams: HotelSearchParameters
    let selectedRooms: [HotelRoom]

    init(hotel: Hotel, searchParams: HotelSearchParameters, selectedRooms: [HotelRoom]) {
        self.hotel = hotel
        self.searchParams = searchParams
        self.selectedRooms = selectedRooms

        loadUserData()
    }

    private func loadUserData() {
        if let cachedUser = AuthManager.shared.currentAppUser {
            self.fullName = cachedUser.username
            self.email = cachedUser.email
        } else {
            AuthManager.shared.fetchUserData { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let user):
                        self?.fullName = user.username
                        self?.email = user.email
                        self?.notifyViewUpdate?()
                    case .failure(let error):
                        print("❌ Could not load user:", error)
                    }
                }
            }
        }
    }
}
