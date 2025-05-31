//
//  UIButton.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 23.05.2025.
//

import UIKit

extension UIButton {
    func applyPrimaryStyle(with title: String) {
        self.backgroundColor = UIColor.appButtonBackground
        self.setTitle(title, for: .normal)
        self.setTitleColor(.appAccent, for: .normal)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
    }
    
    func applyPrimaryChatStyle(with title: String) {
        self.backgroundColor = UIColor.appButtonBackground
        self.setTitle(title, for: .normal)
        self.setTitleColor(.appAccent, for: .normal)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
    }
    
    func applyPrimaryOnboardingStyle(with title: String) {
        self.backgroundColor = UIColor.appButtonBackground
        self.setTitle(title, for: .normal)
        self.setTitleColor(.appAccent, for: .normal)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
    }
    
    func applyLogOutStyle() {
        self.backgroundColor = UIColor.appButtonBackground
        self.setTitleColor(.appError, for: .normal)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
    }

    func setEnabled(_ isEnabled: Bool) {
        self.isEnabled = isEnabled
        self.alpha = isEnabled ? 1.0 : 0.5
    }
}
