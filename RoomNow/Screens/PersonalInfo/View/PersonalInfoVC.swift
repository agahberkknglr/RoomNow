//
//  PersonalInfoVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 23.05.2025.
//

import UIKit

final class PersonalInfoVC: UIViewController {

    private let stack = UIStackView()

    private let fullNameField = UITextField()
    private let emailField = UITextField()
    private let phoneField = UITextField()
    private let noteField = UITextField()
    private let continueButton = UIButton(type: .system)
    
    private let viewModel: PersonalInfoVM

    init(viewModel: PersonalInfoVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupFields()
        setupLayout()
        setupActions()
    }

    private func setupFields() {
        [fullNameField, emailField, phoneField, noteField].forEach {
            $0.borderStyle = .roundedRect
            $0.backgroundColor = .appSecondaryBackground
        }

        fullNameField.placeholder = "Full Name"
        emailField.placeholder = "Email"
        phoneField.placeholder = "Phone"
        noteField.placeholder = "Note (Optional)"
        fullNameField.text = viewModel.fullName
        emailField.text = viewModel.email
    }

    private func setupLayout() {
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(fullNameField)
        stack.addArrangedSubview(emailField)
        stack.addArrangedSubview(phoneField)
        stack.addArrangedSubview(noteField)
        stack.addArrangedSubview(continueButton)

        continueButton.setTitle("Review Reservation", for: .normal)
        continueButton.backgroundColor = .appButtonBackground
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 8

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            continueButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setupActions() {
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
    }

    @objc private func continueTapped() {
        viewModel.fullName = fullNameField.text ?? ""
        viewModel.email = emailField.text ?? ""
        viewModel.phone = phoneField.text ?? ""
        viewModel.note = noteField.text ?? ""

        guard viewModel.isFormValid else {
            showAlert("Please fill in all required fields.")
            return
        }

        // TODO: Navigate to Summary screen, pass selectedRooms + personalInfo
        print("✅ Proceed with info:", viewModel.fullName, viewModel.email, viewModel.phone)
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Missing Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
