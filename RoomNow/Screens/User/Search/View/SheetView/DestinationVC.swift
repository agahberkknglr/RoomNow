//
//  DestinationVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 22.03.2025.
//

import UIKit

protocol DestinationVCDelegate: AnyObject {
    func didSelectCity(_ city: City)
}

final class DestinationVC: UIViewController {

    private let searchTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Search..."
        tf.borderStyle = .roundedRect
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.smartQuotesType = .no
        tf.smartDashesType = .no
        tf.smartInsertDeleteType = .no
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .appBackground
        return tv
    }()

    private let emptyLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "No cities found"
        lbl.textAlignment = .center
        lbl.textColor = .appSecondaryText
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.isHidden = true
        return lbl
    }()
    private let initialPlaceholderLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Start typing to search for a city"
        lbl.textAlignment = .center
        lbl.textColor = .appSecondaryText
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let viewModel: DestinationVMProtocol
    weak var delegate: DestinationVCDelegate?

    // Dependency injection
    init(viewModel: DestinationVMProtocol = DestinationVM()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
        searchTextField.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        viewModel.fetchCities()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupUI() {
        view.addSubview(searchTextField)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(initialPlaceholderLabel)

        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 40),

            tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            initialPlaceholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            initialPlaceholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - ViewModel Delegate

extension DestinationVC: DestinationVMDelegate {
    func didUpdateCityList() {
        let hasQuery = !(searchTextField.text?.isEmpty ?? true)
        let hasResults = viewModel.numberOfCities > 0

        initialPlaceholderLabel.isHidden = hasQuery
        tableView.isHidden = !hasResults || !hasQuery
        emptyLabel.isHidden = hasResults || !hasQuery

        tableView.reloadData()
    }

    func didFailToLoadCities(error: Error) {
        print("Failed to load cities: \(error.localizedDescription)")
        tableView.isHidden = true
        emptyLabel.isHidden = false
    }
}

// MARK: - TableView

extension DestinationVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCities
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = viewModel.city(at: indexPath.row)?.name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedCity = viewModel.city(at: indexPath.row) {
            delegate?.didSelectCity(selectedCity)
            dismiss(animated: true)
        }
    }
}

// MARK: - Search TextField

extension DestinationVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        viewModel.filterCities(with: newText)
        return true
    }
}
