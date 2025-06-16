//
//  UIImageView.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 12.06.2025.
//

import UIKit

extension UIImageView {
    func setImage(fromBase64 base64String: String?, placeholder: String = "building.2.fill") {
        if let base64 = base64String,
           let image = base64.asBase64Image {
            self.image = image
        } else {
            self.image = UIImage(systemName: placeholder)
        }
    }
}
