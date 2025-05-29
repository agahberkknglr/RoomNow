//
//  LoginSheetVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.05.2025.
//

import UIKit

final class LoginSheetVC: UIViewController {

    private let titleLabel = UILabel()
    private let reservationLabel = UILabel()
    private let historyLabel = UILabel()
    private let saveLabel = UILabel()
    private let bookingLabel = UILabel()
    private let chatLabel = UILabel()
    private let loginButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appSecondaryBackground
        setupUI()
    }
    
    private func setupUI() {
        titleLabel.text = "Sign in to Continue"
        titleLabel.applyTitleStyle()
        titleLabel.font = .boldSystemFont(ofSize: 32)
        titleLabel.textAlignment = .left

        reservationLabel.text = "Make reservation for your dream hotel"
        historyLabel.text = "Get access to your booking history"
        saveLabel.text = "View saved hotels"
        bookingLabel.text = "Save your reservations"
        chatLabel.text = "Make reservation with ChatBot"
        
        reservationLabel.applyCellTitleStyle()
        historyLabel.applyCellTitleStyle()
        saveLabel.applyCellTitleStyle()
        bookingLabel.applyCellTitleStyle()
        chatLabel.applyCellTitleStyle()

        loginButton.applyPrimaryStyle(with: "Sign in")
        loginButton.layer.cornerRadius = 10
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)

        [titleLabel, reservationLabel, historyLabel, saveLabel, bookingLabel, chatLabel, loginButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            reservationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            reservationLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            reservationLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            historyLabel.topAnchor.constraint(equalTo: reservationLabel.bottomAnchor, constant: 8),
            historyLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            historyLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            saveLabel.topAnchor.constraint(equalTo: historyLabel.bottomAnchor, constant: 8),
            saveLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            saveLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            bookingLabel.topAnchor.constraint(equalTo: saveLabel.bottomAnchor, constant: 8),
            bookingLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bookingLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            chatLabel.topAnchor.constraint(equalTo: bookingLabel.bottomAnchor, constant: 8),
            chatLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            chatLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            loginButton.topAnchor.constraint(equalTo: chatLabel.bottomAnchor, constant: 32),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func loginTapped() {
        dismiss(animated: true) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let tabBar = window.rootViewController as? TabBarVC {
                tabBar.selectedIndex = 3
            }
        }
    }
}
