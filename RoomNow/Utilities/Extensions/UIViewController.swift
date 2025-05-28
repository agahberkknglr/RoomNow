//
//  UIViewController.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 17.05.2025.
//

import UIKit

private var loadingIndicatorKey: UInt8 = 0

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
    
    private var loadingIndicator: UIActivityIndicatorView {
        if let existing = objc_getAssociatedObject(self, &loadingIndicatorKey) as? UIActivityIndicatorView {
            return existing
        }

        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true

        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        objc_setAssociatedObject(self, &loadingIndicatorKey, spinner, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return spinner
    }

    func showLoadingIndicator() {
        loadingIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
    }
}


extension UIViewController {
    
    func observeKeyboardChanges(scrollView: UIScrollView) {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.adjustForKeyboard(notification: notification, scrollView: scrollView, showing: true)
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.adjustForKeyboard(notification: notification, scrollView: scrollView, showing: false)
        }
    }
    
    func stopObservingKeyboardChanges() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func adjustForKeyboard(notification: Notification, scrollView: UIScrollView, showing: Bool) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = showing ? keyboardFrame.height : 0
        
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.scrollIndicatorInsets.bottom = keyboardHeight
        
        // Optional: Scroll to bottom if it's a UITableView or UICollectionView
        if let tableView = scrollView as? UITableView {
            let lastRow = tableView.numberOfRows(inSection: 0) - 1
            if lastRow >= 0 {
                let indexPath = IndexPath(row: lastRow, section: 0)
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
}
