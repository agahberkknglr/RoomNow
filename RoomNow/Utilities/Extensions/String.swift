//
//  String.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.05.2025.
//

import Foundation

extension String {
    var isValidEmail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
}
