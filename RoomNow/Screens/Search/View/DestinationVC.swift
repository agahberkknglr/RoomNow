//
//  DestinationVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 22.03.2025.
//

import UIKit

final class DestinationVC: UIViewController {
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search..."
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isHidden = true
        return tableView
    }()

    private let viewModel = DestinationVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .secondarySystemBackground
        setupUI()
        
        //tableView.delegate = self
        tableView.dataSource = self
        searchTextField.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        
        viewModel.fetchCities { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Failed to fetch cities: \(error.localizedDescription)")
                }
            }
        }
    }

    private func setupUI() {
        view.addSubview(searchTextField)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 40),
            
            tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

}

extension DestinationVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        viewModel.filterCities(with: searchText)
        tableView.isHidden = viewModel.filteredCities.isEmpty
        tableView.reloadData()
        return true
    }
    
    private func filterData(_ query: String) {
        viewModel.filterCities(with: query)
        tableView.isHidden = viewModel.filteredCities.isEmpty
        tableView.reloadData()
    }
}

extension DestinationVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredCities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        let city = viewModel.filteredCities[indexPath.row]
        cell.textLabel?.text = city.name
        return cell
    }
}
