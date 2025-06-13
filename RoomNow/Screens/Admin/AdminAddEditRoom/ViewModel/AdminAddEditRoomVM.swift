//
//  AdminAddEditRoomVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 13.06.2025.
//

import Foundation

enum AdminRoomMode {
    case add(hotelId: String)
    case edit(hotelId: String, room: Room)

    var isEditing: Bool {
        switch self {
        case .edit: return true
        case .add: return false
        }
    }

    var hotelId: String {
        switch self {
        case .add(let id), .edit(let id, _): return id
        }
    }
}

final class AdminAddEditRoomVM {
    private let mode: AdminRoomMode

    var roomNumber: String = ""
    var roomType: String = ""
    var bedCapacity: Int?
    var price: Double?
    var description: String = ""

    var existingRoom: Room? {
        switch mode {
        case .edit(_, let room): return room
        case .add: return nil
        }
    }

    var hotelId: String {
        return mode.hotelId
    }

    init(mode: AdminRoomMode) {
        self.mode = mode

        if case .edit(_, let room) = mode {
            self.roomNumber = room.roomNumber
            self.roomType = room.roomType
            self.bedCapacity = room.bedCapacity
            self.price = room.price
            self.description = room.description
        }
    }

    func validate() -> String? {
        if roomNumber.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Room number is required."
        }

        if roomType.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Room type is required."
        }

        guard let beds = bedCapacity, beds > 0 else {
            return "Bed capacity must be a valid number."
        }

        guard let roomPrice = price, roomPrice >= 0 else {
            return "Price must be a valid number."
        }

        if description.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Room description is required."
        }

        return nil
    }

    func saveRoom(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let beds = bedCapacity,
              let roomPrice = price
        else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Missing or invalid fields."])))
            return
        }

        let id = existingRoom?.id ?? UUID().uuidString

        let room = Room(
            id: id,
            hotelId: hotelId,
            roomType: roomType,
            roomNumber: roomNumber,
            bedCapacity: beds,
            description: description,
            price: roomPrice,
            bookedDates: existingRoom?.bookedDates ?? [] // or nil
        )

        FirebaseManager.shared.addOrUpdateRoom(hotelId: hotelId, room: room, completion: completion)
    }
}
