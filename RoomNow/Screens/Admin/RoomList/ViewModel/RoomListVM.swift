//
//  RoomListVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 12.06.2025.
//

import Foundation

enum RoomDeletionError: Error {
    case hasBookings
}

final class RoomListVM {
    private(set) var rooms: [Room] = []
    private let hotelId: String
    var sortOption: RoomSortOption = .roomNumber

    init(hotelId: String) {
        self.hotelId = hotelId
    }
    
    var getHotelId: String {
        return hotelId
    }

    func fetchRooms(completion: @escaping () -> Void) {
        FirebaseManager.shared.fetchRooms(for: hotelId) { result in
            switch result {
            case .success(let rooms):
                self.rooms = rooms
            case .failure(let error):
                print("Error fetching rooms: \(error)")
                self.rooms = []
            }
            completion()
        }
    }
    
    func sortedRooms() -> [Room] {
        switch sortOption {
        case .priceLowToHigh:
            return rooms.sorted { $0.price < $1.price }
        case .priceHighToLow:
            return rooms.sorted { $0.price > $1.price }
        case .roomNumber:
            return rooms.sorted { $0.roomNumber < $1.roomNumber }
        case .bedCount:
            return rooms.sorted { $0.bedCapacity > $1.bedCapacity }
        }
    }
    
    func hasRoomBookings(_ room: Room) -> Bool {
        let now = Date()
        return room.bookedDates?.contains(where: {
            guard let start = $0.start, let end = $0.end else { return false }
            return end > now
        }) ?? false
    }
    
    func attemptRoomDeletion(_ room: Room, completion: @escaping (Result<Void, Error>) -> Void) {
        if hasRoomBookings(room) {
            completion(.failure(RoomDeletionError.hasBookings))
            return
        }

        guard let id = room.id else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing room ID."])))
            return
        }

        FirebaseManager.shared.deleteRoom(roomId: id, completion: completion)
    }
}

