//
//  ProfileVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.04.2025.
//

import UIKit

final class ProfileVC: UIViewController {

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 8
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = .systemBackground
        setupUI()
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }

    private func setupUI() {
        view.addSubview(logoutButton)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 200),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func logoutTapped() {
        AuthManager.shared.logout { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Logged out")
                    if let tabBarVC = self?.tabBarController as? TabBarVC {
                        tabBarVC.reloadTabsAfterLogout()
                        tabBarVC.selectedIndex = 3
                    }
                case .failure(let error):
                    print("❌ Logout failed:", error.localizedDescription)
                }
            }
        }
    }
}
