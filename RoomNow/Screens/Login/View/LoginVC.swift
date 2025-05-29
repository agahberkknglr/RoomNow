//
//  LoginVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.04.2025.
//

import UIKit

final class LoginVC: UIViewController {

    private let viewModel: LoginVMProtocol = LoginVM()
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        sv.keyboardDismissMode = .interactive
        return sv
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let formBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .appSecondaryBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel = UILabel()
    private let titleView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.borderStyle = .roundedRect
        tf.textContentType = .emailAddress
        tf.returnKeyType = .next
        tf.font = .systemFont(ofSize: 16)
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
        tf.font = .systemFont(ofSize: 16)
        tf.autocorrectionType = .no
        tf.backgroundColor = .appSecondaryBackground
        
        let toggleButton = UIButton(type: .custom)
        toggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        toggleButton.tintColor = .gray
        toggleButton.frame = CGRect(x: -8, y: 0, width: 24, height: 24)
        tf.rightView = toggleButton
        tf.rightViewMode = .always
        toggleButton.addTarget(nil, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        return tf
    }()

    private let loginButton: UIButton = {
        let button = UIButton()
        button.applyPrimaryStyle(with: "Sign in")
        return button
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appWarning
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.isHidden = true
        label.backgroundColor = .clear
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
            let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty,
            let password = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !password.isEmpty
        else {
            showError("Please fill in all fields")
            return
        }

        guard email.isValidEmail else {
            showError("Please enter a valid email.")
            return
        }

        showLoadingIndicator()
        loginButton.isEnabled = false

        viewModel.login(email: email, password: password) { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.hideLoadingIndicator()
                self?.loginButton.isEnabled = true

                if let errorMessage = errorMessage {
                    self?.showError("Password is incorrect or email doesn't exist")
                    print(errorMessage)
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
    
    @objc private func togglePasswordVisibility() {
        passwordField.isSecureTextEntry.toggle()
        let imageName = passwordField.isSecureTextEntry ? "eye.slash" : "eye"
        if let button = passwordField.rightView as? UIButton {
            button.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }

    private func setupUI() {
        view.backgroundColor = .appBackground
        setNavigation(title: "Sign in")
        
        titleLabel.applyTitleStyle()
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.text = "Welcome back"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -8)
        ])
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 130),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -48),
        ])

        let formFieldsStack = UIStackView(arrangedSubviews: [
            emailField,
            passwordField,
            forgotPasswordLabel,
            loginButton,
            errorLabel
        ])
        formFieldsStack.axis = .vertical
        formFieldsStack.spacing = 12
        formFieldsStack.translatesAutoresizingMaskIntoConstraints = false

        formBackgroundView.addSubview(formFieldsStack)
        NSLayoutConstraint.activate([
            formFieldsStack.topAnchor.constraint(equalTo: formBackgroundView.topAnchor, constant: 20),
            formFieldsStack.leadingAnchor.constraint(equalTo: formBackgroundView.leadingAnchor, constant: 16),
            formFieldsStack.trailingAnchor.constraint(equalTo: formBackgroundView.trailingAnchor, constant: -16),
            formFieldsStack.bottomAnchor.constraint(equalTo: formBackgroundView.bottomAnchor, constant: -20),
        ])
        contentStack.addArrangedSubview(titleView)
        contentStack.addArrangedSubview(formBackgroundView)
        contentStack.addArrangedSubview(registerLabel)

        loginButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
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


