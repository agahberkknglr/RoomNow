//
//  PersonalInfoVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 23.05.2025.
//

import Foundation

final class PersonalInfoVM {
    let selectedRooms: [HotelRoom]
    let hotel: Hotel
    let searchParams: HotelSearchParameters

    var fullName: String = ""
    var email: String = ""
    var phone: String = ""
    var note: String = ""

    init(selectedRooms: [HotelRoom], hotel: Hotel, searchParams: HotelSearchParameters) {
        self.selectedRooms = selectedRooms
        self.hotel = hotel
        self.searchParams = searchParams

        if let user = AuthManager.shared.currentAppUser {
            self.fullName = user.username
            self.email = user.email
        }
    }
    var isFormValid: Bool {
        !fullName.isEmpty && !email.isEmpty && !phone.isEmpty
    }
}
