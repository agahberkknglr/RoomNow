//
//  UIStackView.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 19.06.2025.
//

import UIKit

extension UIStackView {
    func setStars(from rating: Any?, tint: UIColor = .appAccent) {
        arrangedSubviews.forEach { $0.removeFromSuperview() }

        let intRating: Int = {
            switch rating {
            case let d as Double: return Int(d)
            case let s as String: return Int(Double(s) ?? 0)
            default: return 0
            }
        }()

        for _ in 0..<intRating {
            let star = UIImageView()
            star.contentMode = .scaleAspectFit
            star.tintColor = tint
            star.image = UIImage(systemName: "star.fill")
            star.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                star.widthAnchor.constraint(equalToConstant: 14),
                star.heightAnchor.constraint(equalToConstant: 14)
            ])
            addArrangedSubview(star)
        }
    }
}
