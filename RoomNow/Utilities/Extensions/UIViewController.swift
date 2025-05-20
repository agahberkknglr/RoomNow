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
    
    func showAlert(title: String, message: String, actionTitle: String = "OK") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func showInputAlert(
        title: String,
        message: String,
        placeholder: String,
        confirmTitle: String = "Send",
        cancelTitle: String = "Cancel",
        keyboardType: UIKeyboardType = .emailAddress,
        completion: @escaping (String?) -> Void
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField {
            $0.placeholder = placeholder
            $0.keyboardType = keyboardType
        }

        let confirm = UIAlertAction(title: confirmTitle, style: .default) { _ in
            let text = alert.textFields?.first?.text
            completion(text)
        }

        let cancel = UIAlertAction(title: cancelTitle, style: .cancel) { _ in
            completion(nil)
        }

        alert.addAction(confirm)
        alert.addAction(cancel)

        present(alert, animated: true)
    }
}
