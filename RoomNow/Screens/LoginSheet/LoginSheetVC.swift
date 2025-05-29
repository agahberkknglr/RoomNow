//
//  LoginSheetVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.05.2025.
//

import UIKit

final class LoginSheetVC: UIViewController {

    private let titleLabel = UILabel()
    private let featureStackView = UIStackView()
    private let loginButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appSecondaryBackground
        setupUI()
    }
    
    private func setupUI() {
        titleLabel.text = "Sign in to Continue"
        titleLabel.applyTitleStyle()
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        featureStackView.axis = .vertical
        featureStackView.spacing = 12
        featureStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(featureStackView)

        let features = [
            "• Make reservation for your dream hotel",
            "• Get access to your booking history",
            "• View saved hotels",
            "• Save your reservations",
            "• Make reservation with ChatBot"
        ]

        features.forEach {
            let label = UILabel()
            label.text = $0
            label.applyCellTitleStyle()
            label.numberOfLines = 0
            featureStackView.addArrangedSubview(label)
        }

        loginButton.applyPrimaryStyle(with: "Sign in")
        loginButton.layer.cornerRadius = 10
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            featureStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            featureStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            featureStackView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            loginButton.topAnchor.constraint(equalTo: featureStackView.bottomAnchor, constant: 32),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            loginButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
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
