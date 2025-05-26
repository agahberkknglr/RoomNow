//
//  ParsedSearchData.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 27.05.2025.
//

import Foundation

struct ParsedSearchData: Codable {
    let destination: String
    let checkIn: String
    let checkOut: String
    let guestCount: Int
    let roomCount: Int
}
