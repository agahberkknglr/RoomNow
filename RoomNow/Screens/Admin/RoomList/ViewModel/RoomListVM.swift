//
//  RoomListVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 12.06.2025.
//

import Foundation

final class RoomListVM {
    private(set) var rooms: [Room] = []
    private let hotelId: String

    init(hotelId: String) {
        self.hotelId = hotelId
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
}

