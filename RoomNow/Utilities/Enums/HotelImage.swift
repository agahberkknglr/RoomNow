//
//  HotelImage.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 11.06.2025.
//

import UIKit

enum HotelImage {
    case existing(base64: String)
    case new(image: UIImage)

    var uiImage: UIImage? {
        switch self {
        case .existing(let base64):
            guard let data = Data(base64Encoded: base64) else { return nil }
            return UIImage(data: data)
        case .new(let image):
            return image
        }
    }

    var base64String: String? {
        switch self {
        case .existing(let base64):
            return base64
        case .new(let image):
            return image.jpegData(compressionQuality: 0.3)?.base64EncodedString()
        }
    }
}
