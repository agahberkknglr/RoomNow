//
//  LoginVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.04.2025.
//

import UIKit

final class LoginVC: UIViewController {

    private let viewModel: LoginVMProtocol = LoginVM()

    private let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.borderStyle = .roundedRect
        tf.textContentType = .emailAddress
        tf.returnKeyType = .next
        tf.autocorrectionType = .no
        tf.backgroundColor = .appSecondaryBackground
        return tf
    }()

    private let passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.textContentType = .password
        tf.returnKeyType = .done
        tf.autocorrectionType = .no
        tf.backgroundColor = .appSecondaryBackground
        return tf
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .appButtonBackground
        button.setTitleColor(.appAccent, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.layer.cornerRadius = 8
        return button
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appWarning
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let registerLabel: UILabel = {
        let label = UILabel()
        label.text = "Don't have an account? Register"
        label.textColor = .appAccent
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let forgotPasswordLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appAccent
        label.text = "Forgot Password?"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loginButtonTarget()
        registerAction()
        forgotPasswordAction()
        tfNavigation()
    }
    
    private func tfNavigation() {
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    private func loginButtonTarget() {
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
    }
    
    @objc private func loginTapped() {
        guard
            let email = emailField.text, !email.isEmpty,
            let password = passwordField.text, !password.isEmpty
        else {
            showError("Please fill in all fields")
            return
        }

        viewModel.login(email: email, password: password) { [weak self] errorMessage in
            DispatchQueue.main.async {
                if let errorMessage = errorMessage {
                    self?.showError(errorMessage)
                } else {
                    self?.errorLabel.isHidden = true
                    self?.navigateAfterLogin()
                }
            }
        }
    }
    
    private func registerAction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(openRegister))
        registerLabel.addGestureRecognizer(tap)
    }
    
    @objc private func openRegister() {
        navigationController?.pushViewController(RegisterVC(), animated: true)
    }
    
    private func forgotPasswordAction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(forgotPasswordTapped))
        forgotPasswordLabel.addGestureRecognizer(tap)
    }

    @objc private func forgotPasswordTapped() {
        showInputAlert(
            title: "Reset Password",
            message: "Enter your email",
            placeholder: "Email"
        ) { [weak self] email in
            guard let email = email, !email.isEmpty else { return }
            self?.viewModel.resetPassword(email: email) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.showAlert(title: "Success", message: "Reset link sent to \(email)")
                    case .failure(let error):
                        self?.showAlert(title: "Error", message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    private func navigateAfterLogin() {
        print("Login successful")
        if let tabBarVC = self.tabBarController as? TabBarVC {
            tabBarVC.reloadTabsAfterLogin()
            tabBarVC.selectedIndex = 3
        }
    }

    private func setupUI() {
        view.backgroundColor = .appBackground
        setNavigation(title: "Login")
        let stack = UIStackView(arrangedSubviews: [emailField, passwordField, forgotPasswordLabel, loginButton, registerLabel, errorLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            loginButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailField:
            passwordField.becomeFirstResponder()
        case passwordField:
            passwordField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}


