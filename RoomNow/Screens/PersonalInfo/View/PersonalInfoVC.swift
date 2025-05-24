//
//  PersonalInfoVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 23.05.2025.
//

import UIKit

final class PersonalInfoVC: UIViewController {

    private let tableView = UITableView()
    
    private let continueButton = UIButton()
    private let buttonView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appSecondaryBackground
        return view
    }()
    
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
        title = "Personal Information"
        setupTableView()
        setupContinueButton()
        notifyVM()
    }
    
    private func notifyVM() {
        viewModel.notifyViewUpdate = { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        //tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(type: PersonalInfoCell.self)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupContinueButton() {
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.applyPrimaryStyle(with: "Review Reservation")
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        buttonView.addSubview(continueButton)
        view.addSubview(buttonView)
        
        NSLayoutConstraint.activate([
            buttonView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            buttonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            continueButton.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 12),
            continueButton.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -16),
            continueButton.bottomAnchor.constraint(equalTo: buttonView.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            continueButton.heightAnchor.constraint(equalToConstant: 48)
        ])

    }

    @objc private func continueTapped() {
        guard !viewModel.fullName.isEmpty, !viewModel.email.isEmpty, !viewModel.phone.isEmpty else {
            showAlert("Please fill all fields.")
            return
        }

        let summaryVM = ReservationVM(
            hotel: viewModel.hotel,
            searchParams: viewModel.searchParams,
            selectedRooms: viewModel.selectedRooms,
            fullName: viewModel.fullName,
            email: viewModel.email,
            phone: viewModel.phone,
            note: viewModel.note
        )

        navigationController?.pushViewController(ReservationVC(viewModel: summaryVM), animated: true)
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Missing Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension PersonalInfoVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 4 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(PersonalInfoCell.self, for: indexPath)
        cell.textField.delegate = self
        cell.textField.tag = indexPath.row
        cell.textField.returnKeyType = (indexPath.row == 3) ? .done : .next

        switch indexPath.row {
        case 0:
            cell.configure(placeholder: "Full Name", text: viewModel.fullName)
        case 1:
            cell.configure(placeholder: "Email", text: viewModel.email, keyboard: .emailAddress)
        case 2:
            cell.configure(placeholder: "Phone", text: viewModel.phone, keyboard: .phonePad)
        case 3:
            cell.configure(placeholder: "Note (Optional)", text: viewModel.note)
        default: break
        }

        return cell
    }
}

extension PersonalInfoVC: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 0: viewModel.fullName = textField.text ?? ""
        case 1: viewModel.email = textField.text ?? ""
        case 2: viewModel.phone = textField.text ?? ""
        case 3: viewModel.note = textField.text
        default: break
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        if let nextField = tableView.viewWithTag(nextTag) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
