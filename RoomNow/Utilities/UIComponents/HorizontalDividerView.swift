//
//  HorizontalDividerView.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 19.05.2025.
//

import UIKit

final class HorizontalDividerView: UIView {
    init(height: CGFloat = 1.0, color: UIColor = .appDivider) {
        super.init(frame: .zero)
        backgroundColor = color
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
