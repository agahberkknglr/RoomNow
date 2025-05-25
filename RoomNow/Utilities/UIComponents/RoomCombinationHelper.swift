//
//  RoomCombinationHelper.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 24.05.2025.
//

import Foundation

struct RoomCombinationHelper {
    static func findCombination(
        rooms: [(typeName: String, room: Room)],
        requiredRooms: Int,
        requiredBeds: Int
    ) -> [(typeName: String, room: Room)] {
        let allCombinations = combinations(of: rooms, choosing: requiredRooms)

        for combo in allCombinations {
            let totalBeds = combo.map { $0.room.bedCapacity }.reduce(0, +)
            if totalBeds >= requiredBeds {
                return combo
            }
        }

        return []
    }

    private static func combinations<T>(of elements: [T], choosing k: Int) -> [[T]] {
        guard k > 0 else { return [[]] }
        guard let first = elements.first else { return [] }

        let subcombos = combinations(of: Array(elements.dropFirst()), choosing: k - 1)
        let withFirst = subcombos.map { [first] + $0 }
        let withoutFirst = combinations(of: Array(elements.dropFirst()), choosing: k)

        return withFirst + withoutFirst
    }
}
