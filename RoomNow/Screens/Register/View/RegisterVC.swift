//
//  RegisterVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 20.05.2025.
//

import UIKit

final class RegisterVC: UIViewController {

    private let viewModel: RegisterVMProtocol = RegisterVM()
    
    private let nameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Fullname"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .default
        tf.autocorrectionType = .no
        tf.returnKeyType = .next
        tf.textContentType = .name
        tf.backgroundColor = .appSecondaryBackground
        return tf
    }()

    private let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.autocapitalizationType = .none
        tf.borderStyle = .roundedRect
        tf.keyboardType = .emailAddress
        tf.returnKeyType = .next
        tf.textContentType = .emailAddress
        tf.autocorrectionType = .no
        tf.backgroundColor = .appSecondaryBackground
        return tf
    }()
    
    private let dobField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Date of Birth"
        tf.borderStyle = .roundedRect
        tf.returnKeyType = .done
        tf.backgroundColor = .appSecondaryBackground
        return tf
    }()
    
    private let genderPicker: UISegmentedControl = {
        let sg = UISegmentedControl(items: ["Male", "Female", "Other"])
        sg.selectedSegmentIndex = 0
        sg.setTitleTextAttributes([.foregroundColor: UIColor.appSecondaryText], for: .normal)
        sg.setTitleTextAttributes([.foregroundColor: UIColor.appAccent], for: .selected)
        sg.backgroundColor = .appSecondaryBackground
        sg.selectedSegmentTintColor = .appButtonBackground
        return sg
    }()

    /// Text ContentType .newPassword some error about iCloud Keychain is disabled for simulator
    private let passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.returnKeyType = .next
        tf.textContentType = .oneTimeCode
        tf.backgroundColor = .appSecondaryBackground
        return tf
    }()

    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.applyPrimaryStyle(with: "Register")
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
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.maximumDate = Calendar.current.date(byAdding: .year, value: -15, to: Date())
        picker.preferredDatePickerStyle = .wheels
        return picker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tfNavigation()
        dobPrickerTarget()
        dobToolbar()
        registerAction()
    }
    
    private func dobPrickerTarget(){
        dobField.inputView = datePicker
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    private func dobToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: false)

        dobField.inputAccessoryView = toolbar
    }
    
    @objc private func doneTapped() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dobField.text = formatter.string(from: datePicker.date)
        dobField.resignFirstResponder()
    }
    
    @objc private func dateChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dobField.text = formatter.string(from: datePicker.date)
    }

    private func registerAction() {
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
    }
    
    @objc private func registerTapped() {
        guard
            let name = nameField.text, !name.isEmpty,
            let email = emailField.text, !email.isEmpty,
            let password = passwordField.text, !password.isEmpty,
            let dob = dobField.text, !dob.isEmpty
        else {
            showError("Please fill in all fields")
            return
        }

        let gender = genderPicker.titleForSegment(at: genderPicker.selectedSegmentIndex) ?? "Other"

        viewModel.register(email: email, password: password, username: name, dateOfBirth: dob, gender: gender) { [weak self] errorMessage in
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
        setNavigation(title: "Register")
        let stack = UIStackView(arrangedSubviews: [
            nameField,
            emailField,
            passwordField,
            dobField,
            genderPicker,
            registerButton,
            errorLabel
        ])
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
    
    private func tfNavigation(){
        nameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        dobField.delegate = self
    }
}

extension RegisterVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField:
            emailField.becomeFirstResponder()
        case emailField:
            passwordField.becomeFirstResponder()
        case passwordField:
            dobField.becomeFirstResponder()
        case dobField:
            dobField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}

