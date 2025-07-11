//
//  Reservation.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 25.05.2025.
//

import Foundation
import FirebaseFirestore

struct Reservation: Codable {
    @DocumentID var id: String?
    let hotelId: String
    let hotelName: String
    let city: String
    let checkInDate: Date
    let checkOutDate: Date
    let guestCount: Int
    let roomCount: Int
    let selectedRoomNumbers: [String]
    let totalPrice: Int
    let fullName: String
    let email: String
    let phone: String
    let note: String?
    let reservedAt: Date
    var status: ReservationStatus
    var completedAt: Date?
    var cancelledAt: Date?
}
