//
//  UICollectionView.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 18.05.2025.
//

import UIKit

extension UICollectionView {
    
    func register<T: UICollectionViewCell>(_ cellType: T.Type) {
        let identifier = String(describing: cellType)
        register(cellType, forCellWithReuseIdentifier: identifier)
    }
    
    func dequeue<T: UICollectionViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T {
        let identifier = String(describing: cellType)
        guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T else {
            fatalError(" Could not dequeue cell with identifier: \(identifier)")
        }
        return cell
    }
    
}
