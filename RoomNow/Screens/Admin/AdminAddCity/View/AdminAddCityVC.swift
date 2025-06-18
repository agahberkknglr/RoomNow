//
//  AdminAddCityVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 18.06.2025.
//

import UIKit

final class AdminAddCityVC: UIViewController {

    private var viewModel: AdminAddCityVMProtocol
    private let nameField = UITextField()
    private let saveButton = UIButton(type: .system)

    init(viewModel: AdminAddCityVMProtocol = AdminAddCityVM()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        setupNavBar()
    }

    private func setupUI() {
        title = "Add City"
        view.backgroundColor = .appBackground

        nameField.placeholder = "Enter city name"
        nameField.borderStyle = .roundedRect
        nameField.autocapitalizationType = .none
        nameField.autocorrectionType = .no
        nameField.applyButtonStyleLook()
        nameField.translatesAutoresizingMaskIntoConstraints = false

        saveButton.applyPrimaryStyle(with: "Save City")
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        view.addSubview(nameField)
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            nameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            nameField.heightAnchor.constraint(equalToConstant: 44),

            saveButton.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func setupNavBar() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Manage Cities",
            style: .plain,
            target: self,
            action: #selector(manageCitiesTapped)
        )

    }
    
    @objc private func manageCitiesTapped() {
        let vc = ManageCitiesVC()
        navigationController?.pushViewController(vc, animated: true)
    }

    private func bindViewModel() {
        viewModel.onSuccess = { [weak self] in
            self?.presentAlert(title: "Success", message: "City added.") {
                self?.navigationController?.popViewController(animated: true)
            }
        }

        viewModel.onError = { [weak self] message in
            self?.presentAlert(title: "Error", message: message)
        }
    }

    @objc private func saveTapped() {
        viewModel.addCity(named: nameField.text ?? "")
    }

    private func presentAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
        present(alert, animated: true)
    }
}

