//
//  RoomSelectionVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 15.05.2025.
//

import Foundation

protocol RoomSelectionVMProtocol {
    var availableRooms: [RoomType] { get }
    var hotelName: String { get }
    func filterAvailableRooms()
}

final class RoomSelectionVM: RoomSelectionVMProtocol {
    
    private let hotel: Hotel
    private let searchParams: HotelSearchParameters
    
    private(set) var availableRooms: [RoomType] = []
    
    var hotelName: String { hotel.name }
    
    init(hotel: Hotel, searchParams: HotelSearchParameters) {
        self.hotel = hotel
        self.searchParams = searchParams
        filterAvailableRooms()
    }
    
    func filterAvailableRooms() {
        availableRooms = hotel.roomTypes.compactMap { type in
            let filtered = type.rooms.filter {
                $0.bedCapacity >= searchParams.guestCount &&
                $0.isAvailable(for: searchParams.checkInDate, checkOut: searchParams.checkOutDate)
            }
            return filtered.isEmpty ? nil : RoomType(typeName: type.typeName, rooms: filtered)
        }
    }
}
