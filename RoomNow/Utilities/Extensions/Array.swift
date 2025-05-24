//
//  Array.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 24.05.2025.
//

extension Array {
    func combinations(ofCount k: Int) -> [[Element]] {
        guard k > 0 else { return [[]] }
        guard let first = self.first else { return [] }

        let subarray = Array(self.dropFirst())
        let withFirst = subarray.combinations(ofCount: k - 1).map { [first] + $0 }
        let withoutFirst = subarray.combinations(ofCount: k)

        return withFirst + withoutFirst
    }
}

