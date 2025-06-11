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
    
    func applyTitleStyle() {
        self.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        self.textColor = .appPrimaryText
        self.numberOfLines = 0
        self.textAlignment = .left
        self.adjustsFontForContentSizeCategory = true
    }
    
    func applySubtitleStyle() {
        self.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        self.textColor = .appSecondaryText
        self.numberOfLines = 0
        self.textAlignment = .left
        self.adjustsFontForContentSizeCategory = true
    }
    
    func applySubtitleSecondStyle() {
        self.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        self.textColor = .appSecondaryText
        self.numberOfLines = 0
        self.textAlignment = .left
        self.adjustsFontForContentSizeCategory = true
    }
    
    func applyCellTitleStyle() {
        self.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        self.textColor = .appPrimaryText
        self.numberOfLines = 0
        self.textAlignment = .left
        self.adjustsFontForContentSizeCategory = true
    }
    
    func applyCellSubtitleStyle() {
        self.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        self.textColor = .appSecondaryText
        self.numberOfLines = 0
        self.textAlignment = .left
        self.adjustsFontForContentSizeCategory = true
    }
    
    func applyCellSecondSubtitleStyle() {
        self.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        self.textColor = .appSecondaryText
        self.numberOfLines = 0
        self.textAlignment = .left
        self.adjustsFontForContentSizeCategory = true
    }
}
