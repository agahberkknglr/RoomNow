//
//  City.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 28.04.2025.
//

import Foundation
import FirebaseFirestore

struct City: Codable {
    @DocumentID var id: String?
    let name: String
}
