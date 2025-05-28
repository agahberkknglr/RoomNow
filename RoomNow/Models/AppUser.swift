//
//  User.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 20.05.2025.
//

import Foundation

struct AppUser: Codable {
    let uid: String
    var username: String
    var email: String
    var gender: String
    var dateOfBirth: String
    var profileImageBase64: String?
}
