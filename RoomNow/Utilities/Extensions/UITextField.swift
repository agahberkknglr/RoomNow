//
//  UITextField.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 12.06.2025.
//

import UIKit

extension UITextField {
    func applyButtonStyleLook() {
        // Font and text color
        font = .systemFont(ofSize: 16)
        textColor = .label
        textAlignment = .left

        // Background and corner radius
        backgroundColor = .systemGray6
        layer.cornerRadius = 8

        // Padding (via leftView and rightView)
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        leftView = padding
        leftViewMode = .always

        let rightPadding = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        rightView = rightPadding
        rightViewMode = .always

        // No border
        borderStyle = .none

        // Clear button when editing (optional)
        clearButtonMode = .whileEditing
    }

    func setPlaceholder(_ text: String, color: UIColor = .placeholderText) {
        attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [.foregroundColor: color]
        )
    }

    func constrainHeight(to height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
}

