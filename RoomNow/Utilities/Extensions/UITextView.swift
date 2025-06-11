//
//  UITextView.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 12.06.2025.
//

import UIKit

extension UITextView {
    func applyButtonStyleLook() {
        // Font and text color
        font = .systemFont(ofSize: 16)
        textColor = .label
        textAlignment = .left

        // Background and corner radius
        backgroundColor = .systemGray6
        layer.cornerRadius = 8
        clipsToBounds = true

        // Padding (via textContainerInset)
        textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        // Remove border if any
        layer.borderWidth = 0
    }

    func constrainHeight(to height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
}

