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
    var numberOfNights: Int { get }
    var checkInDate: Date { get }
    var checkOutDate: Date { get }
    var guestCount: Int { get }
    var roomCount: Int { get }
    var hotel: Hotel { get }
    
    var selectedRooms: [HotelRoom] { get }
    var isSelectionComplete: Bool { get }
    
    func filterAvailableRooms()
    func toggleSelection(for room: HotelRoom)
    func isRoomSelected(_ room: HotelRoom) -> Bool
}

final class RoomSelectionVM: RoomSelectionVMProtocol {
    
    private(set) var hotel: Hotel
    private let searchParams: HotelSearchParameters
    
    private(set) var availableRooms: [RoomType] = []
    private(set) var selectedRooms: [HotelRoom] = []
    
    var hotelName: String { hotel.name }

    var checkInDate: Date { searchParams.checkInDate }

    var checkOutDate: Date { searchParams.checkOutDate }

    var guestCount: Int { searchParams.guestCount }

    var roomCount: Int { searchParams.roomCount }

    var numberOfNights: Int {
        let nights = Calendar.current.dateComponents([.day], from: checkInDate, to: checkOutDate).day ?? 1
        return max(nights, 1)
    }
    
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
    
    func toggleSelection(for room: HotelRoom) {
        if let index = selectedRooms.firstIndex(where: { $0.roomNumber == room.roomNumber }) {
            selectedRooms.remove(at: index)
        } else {
            guard selectedRooms.count < roomCount else { return }
            selectedRooms.append(room)
        }
    }

    func isRoomSelected(_ room: HotelRoom) -> Bool {
        selectedRooms.contains(where: { $0.roomNumber == room.roomNumber })
    }

    var isSelectionComplete: Bool {
        selectedRooms.count == roomCount
    }
}
