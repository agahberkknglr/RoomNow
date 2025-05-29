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
        title = "Your Personal Information"
        setupTableView()
        setupContinueButton()
        
        viewModel.notifyViewUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .appBackground
        tableView.registerCell(type: PersonalInfoCell.self)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    private func setupContinueButton() {
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.applyPrimaryStyle(with: "Next Step")
        continueButton.layer.cornerRadius = 10
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
        guard !viewModel.phone.isEmpty else {
            showAlert(title: "Phone number missing", message: "Please enter your phone number.")
            return
        }

        guard isValidPhone(viewModel.phone) else {
            showAlert(title: "Phone number is not valid", message: "Invalid phone number. Please enter a valid Turkish number like `5XXXXXXXXX` or `+90XXXXXXXXXX`.")
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
    
    private func isValidPhone(_ number: String) -> Bool {
        let phoneRegex = #"^(?:\+90|0)?5\d{9}$"#
        return NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: number)
    }

    private func toolbar(for tag: Int, title: String, isLast: Bool) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let label = UILabel()
        label.text = title
        label.textColor = .secondaryLabel
        let titleItem = UIBarButtonItem(customView: label)

        let action = isLast ? #selector(doneTapped) : #selector(nextTapped(_:))
        let nextItem = UIBarButtonItem(title: isLast ? "Done" : "Next", style: .done, target: self, action: action)
        nextItem.tag = tag

        toolbar.items = [.flexibleSpace(), titleItem, .flexibleSpace(), nextItem]
        return toolbar
    }

    @objc private func doneTapped() {
        view.endEditing(true)
    }

    @objc private func nextTapped(_ sender: UIBarButtonItem) {
        let nextTag = sender.tag + 1
        if let responder = tableView.viewWithTag(nextTag) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                responder.becomeFirstResponder()
            }
        } else {
            view.endEditing(true)
        }
    }
}

// MARK: - UITableViewDataSource

extension PersonalInfoVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 4 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(PersonalInfoCell.self, for: indexPath)
        cell.textField.delegate = self
        cell.textView.delegate = self

        let tag = indexPath.row
        let isLast = tag == 3

        switch tag {
        case 0:
            cell.configure(title: "Full Name", text: viewModel.fullName)
            cell.textField.tag = tag
            cell.textField.inputAccessoryView = toolbar(for: tag, title: "Full Name", isLast: isLast)
        case 1:
            cell.configure(title: "Email", text: viewModel.email, keyboard: .emailAddress)
            cell.textField.tag = tag
            cell.textField.inputAccessoryView = toolbar(for: tag, title: "Email", isLast: isLast)
        case 2:
            cell.configure(title: "Phone", text: viewModel.phone, keyboard: .phonePad)
            cell.textField.tag = tag
            cell.textField.inputAccessoryView = toolbar(for: tag, title: "Phone", isLast: isLast)
        case 3:
            cell.configure(title: "Note (Optional)", text: viewModel.note, isNote: true)
            cell.textView.tag = tag
            cell.textView.inputAccessoryView = toolbar(for: tag, title: "Note", isLast: isLast)
        default: break
        }

        return cell
    }
}

// MARK: - Delegates

extension PersonalInfoVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 0: viewModel.fullName = textField.text ?? ""
        case 1: viewModel.email = textField.text ?? ""
        case 2: viewModel.phone = textField.text ?? ""
        default: break
        }
    }
}

extension PersonalInfoVC: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.tag == 3 {
            viewModel.note = textView.text
        }
    }
}


