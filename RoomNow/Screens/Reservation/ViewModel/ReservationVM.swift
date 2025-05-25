//
//  ReservationVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.04.2025.
//

import Foundation

final class ReservationVM {
    let hotel: Hotel
    let searchParams: HotelSearchParameters
    let selectedRooms: [Room]

    let fullName: String
    let email: String
    let phone: String
    let note: String?

    init(
        hotel: Hotel,
        searchParams: HotelSearchParameters,
        selectedRooms: [Room],
        fullName: String,
        email: String,
        phone: String,
        note: String?
    ) {
        self.hotel = hotel
        self.searchParams = searchParams
        self.selectedRooms = selectedRooms
        self.fullName = fullName
        self.email = email
        self.phone = phone
        self.note = note
    }

    var numberOfNights: Int {
        let nights = Calendar.current.dateComponents([.day], from: searchParams.checkInDate, to: searchParams.checkOutDate).day ?? 1
        return max(nights, 1)
    }

    var totalPrice: Int {
        selectedRooms.reduce(0) { $0 + (Int($1.price) * numberOfNights) }
    }
}
