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

extension ParsedSearchData {
    func toHotelSearchParameters() -> HotelSearchParameters {
        return HotelSearchParameters(
            destination: destination.lowercased(),
            checkInDate: DateFormatter.yyyyMMdd.date(from: checkIn) ?? Date(),
            checkOutDate: DateFormatter.yyyyMMdd.date(from: checkOut) ?? Date().addingTimeInterval(86400),
            guestCount: guestCount,
            roomCount: roomCount
        )
    }
    
    func toShortReadableDate(from raw: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = inputFormatter.date(from: raw) else { return raw }
        return date.toShortReadableFormat()
    }
}
