//
//  AdminAddEditRoomVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 13.06.2025.
//

import UIKit

final class AdminAddEditRoomVC: UIViewController {
    private let viewModel: AdminAddEditRoomVM
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let roomNumberField = UITextField()
    private let roomTypeField = UITextField()
    private let descriptionView = UITextView()
    private let bedCountField = UITextField()
    private let priceField = UITextField()
    private let saveButton = UIButton(type: .system)

    init(mode: AdminRoomMode) {
        self.viewModel = AdminAddEditRoomVM(mode: mode)
        super.init(nibName: nil, bundle: nil)
        title = mode.isEditing ? "Edit Room" : "Add Room"
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupFields()
        fillFieldsIfNeeded()
    }

    private func setupFields() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])

        [roomNumberField, roomTypeField, descriptionView, bedCountField, priceField, saveButton].forEach {
            contentStack.addArrangedSubview($0)
        }

        [roomNumberField, roomTypeField, bedCountField, priceField].forEach {
            $0.borderStyle = .roundedRect
            $0.applyButtonStyleLook()
            $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
        }

        roomNumberField.placeholder = "Room Number"
        roomTypeField.placeholder = "Room Type (e.g. Deluxe)"
        bedCountField.placeholder = "Bed Capacity"
        priceField.placeholder = "Price"

        bedCountField.keyboardType = .numberPad
        roomNumberField.keyboardType = .numberPad
        priceField.keyboardType = .decimalPad

        descriptionView.applyButtonStyleLook()
        descriptionView.heightAnchor.constraint(equalToConstant: 120).isActive = true

        saveButton.applyPrimaryStyle(with: "Save")
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }


    private func fillFieldsIfNeeded() {
        guard let room = viewModel.existingRoom else { return }

        roomNumberField.text = "\(room.roomNumber)"
        roomTypeField.text = room.roomType
        descriptionView.text = room.description
        bedCountField.text = "\(room.bedCapacity)"
        priceField.text = "\(room.price)"
    }

    @objc private func saveTapped() {
        viewModel.roomNumber = roomNumberField.text ?? ""
        viewModel.roomType = roomTypeField.text ?? ""
        viewModel.description = descriptionView.text ?? ""
        viewModel.bedCapacity = Int(bedCountField.text ?? "")
        viewModel.price = Double(priceField.text ?? "")

        if let error = viewModel.validate() {
            showAlert(title: "Invalid Input", message: error)
            return
        }

        viewModel.saveRoom { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    self?.showAlert(title: "Save Failed", message: error.localizedDescription)
                }
            }
        }
    }
}

