//
//  RegisterVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 20.05.2025.
//

import UIKit

final class RegisterVC: UIViewController {

    private let viewModel: RegisterVMProtocol = RegisterVM()

    private let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.autocapitalizationType = .none
        tf.borderStyle = .roundedRect
        tf.keyboardType = .emailAddress
        return tf
    }()

    private let passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        return tf
    }()

    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .appButtonBackground
        button.setTitleColor(.appAccent, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
    }

    @objc private func registerTapped() {
        guard
            let email = emailField.text, !email.isEmpty,
            let password = passwordField.text, !password.isEmpty
        else {
            showError("Please fill in all fields")
            return
        }

        viewModel.register(email: email, password: password) { [weak self] errorMessage in
            DispatchQueue.main.async {
                if let errorMessage = errorMessage {
                    self?.showError(errorMessage)
                } else {
                    self?.errorLabel.isHidden = true
                    self?.handleSuccess()
                }
            }
        }
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    private func handleSuccess() {
        print("Registration successful")
        if let tabBarVC = self.tabBarController as? TabBarVC {
            tabBarVC.reloadTabsAfterLogin()
            tabBarVC.selectedIndex = 3
        }
    }

    private func setupUI() {
        view.backgroundColor = .appBackground
        let stack = UIStackView(arrangedSubviews: [emailField, passwordField, registerButton, errorLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            registerButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}

