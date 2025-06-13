//
//  AdminAddEditRoomVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 13.06.2025.
//

import UIKit

final class AdminAddEditRoomVC: UIViewController {
    private let viewModel: AdminAddEditRoomVM

    private let roomNumberField = UITextField()
    private let roomTypeField = UITextField()
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
        view.backgroundColor = .systemBackground
        setupFields()
        fillFieldsIfNeeded()
    }

    private func setupFields() {
        let stack = UIStackView(arrangedSubviews: [roomNumberField, roomTypeField, bedCountField, priceField, saveButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

        [roomNumberField, roomTypeField, bedCountField, priceField].forEach {
            $0.borderStyle = .roundedRect
        }

        roomNumberField.placeholder = "Room Number"
        roomTypeField.placeholder = "Room Type (e.g. Deluxe)"
        bedCountField.placeholder = "Bed Capacity"
        priceField.placeholder = "Price"

        bedCountField.keyboardType = .numberPad
        roomNumberField.keyboardType = .numberPad
        priceField.keyboardType = .decimalPad

        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }

    private func fillFieldsIfNeeded() {
        guard let room = viewModel.existingRoom else { return }

        roomNumberField.text = "\(room.roomNumber)"
        roomTypeField.text = room.roomType
        bedCountField.text = "\(room.bedCapacity)"
        priceField.text = "\(room.price)"
    }

    @objc private func saveTapped() {
        viewModel.roomNumber = roomNumberField.text ?? ""
        viewModel.roomType = roomTypeField.text ?? ""
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

