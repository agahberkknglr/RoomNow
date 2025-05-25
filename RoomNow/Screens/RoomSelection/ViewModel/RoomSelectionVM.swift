//
//  RoomSelectionVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 15.05.2025.
//

import Foundation

protocol RoomSelectionVMProtocol {
    var availableRooms: [Room] { get }
    var hotelName: String { get }
    var numberOfNights: Int { get }
    var checkInDate: Date { get }
    var checkOutDate: Date { get }
    var guestCount: Int { get }
    var roomCount: Int { get }
    var hotel: Hotel { get }
    var searchParams: HotelSearchParameters { get }
    
    var selectedRooms: [Room] { get }
    var isSelectionComplete: Bool { get }
    
    func filterAvailableRooms()
    func toggleSelection(for room: Room)
    func isRoomSelected(_ room: Room) -> Bool
}

final class RoomSelectionVM: RoomSelectionVMProtocol {
    
    private(set) var hotel: Hotel
    private let _searchParams: HotelSearchParameters
    private let allRooms: [Room]
    
    private(set) var availableRooms: [Room] = []
    private(set) var selectedRooms: [Room] = []
    
    var hotelName: String { hotel.name }
    var checkInDate: Date { searchParams.checkInDate }
    var checkOutDate: Date { searchParams.checkOutDate }
    var guestCount: Int { searchParams.guestCount }
    var roomCount: Int { searchParams.roomCount }
    var searchParams: HotelSearchParameters { return self._searchParams }

    var numberOfNights: Int {
        let nights = Calendar.current.dateComponents([.day], from: checkInDate, to: checkOutDate).day ?? 1
        return max(nights, 1)
    }
    
    var isSelectionComplete: Bool {
        selectedRooms.count == roomCount &&
        selectedRooms.map(\.bedCapacity).reduce(0, +) >= guestCount
    }
    
    init(hotel: Hotel, rooms: [Room], searchParams: HotelSearchParameters) {
        self.hotel = hotel
        self.allRooms = rooms
        self._searchParams = searchParams
        filterAvailableRooms()
    }
    
    func filterAvailableRooms() {
        availableRooms = allRooms.filter {
            $0.isAvailable(for: searchParams.checkInDate, checkOut: searchParams.checkOutDate)
        }
    }
    
    func toggleSelection(for room: Room) {
        if let index = selectedRooms.firstIndex(where: { $0.roomNumber == room.roomNumber }) {
            selectedRooms.remove(at: index)
        } else {
            guard selectedRooms.count < roomCount else { return }
            selectedRooms.append(room)
        }
    }

    func isRoomSelected(_ room: Room) -> Bool {
        selectedRooms.contains(where: { $0.roomNumber == room.roomNumber })
    }
}
