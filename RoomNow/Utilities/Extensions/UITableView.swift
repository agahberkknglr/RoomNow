//
//  UITableView.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 13.05.2025.
//

import UIKit

extension UITableView {
    func registerCell<T: UITableViewCell>(type: T.Type) {
        register(type, forCellReuseIdentifier: String(describing: type))
    }
}
