//
//  UILabel.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 12.05.2025.
//

import UIKit

extension UILabel {
    func setMixedStyleText(
        prefix: String,
        suffix: String,
        prefixFont: UIFont = UIFont.systemFont(ofSize: 12),
        suffixFont: UIFont = UIFont.boldSystemFont(ofSize: 16),
        prefixColor: UIColor = .label,
        suffixColor: UIColor = .label
    ) {
        let attributedText = NSMutableAttributedString(string: prefix, attributes: [
            .font: prefixFont,
            .foregroundColor: prefixColor
        ])
        
        let suffixText = NSAttributedString(string: suffix, attributes: [
            .font: suffixFont,
            .foregroundColor: suffixColor
        ])
        
        attributedText.append(suffixText)
        self.attributedText = attributedText
    }
}
