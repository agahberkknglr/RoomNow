//
//  UIViewController.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 17.05.2025.
//

import UIKit

extension UIViewController {

    func setNavigation(title: String, rightButtons: [UIBarButtonItem] = []) {
        navigationItem.title = title
        navigationItem.rightBarButtonItems = rightButtons
    }

    func makeBarButton(systemName: String, action: Selector) -> UIBarButtonItem {
        UIBarButtonItem(
            image: UIImage(systemName: systemName),
            style: .plain,
            target: self,
            action: action
        )
    }
}
