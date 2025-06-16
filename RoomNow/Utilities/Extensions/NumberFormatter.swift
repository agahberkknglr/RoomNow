//
//  NumberFormatter.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 16.06.2025.
//

import Foundation

extension NumberFormatter {
    static var integerFormatter: NumberFormatter {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 0
        nf.minimumFractionDigits = 0
        return nf
    }
}
