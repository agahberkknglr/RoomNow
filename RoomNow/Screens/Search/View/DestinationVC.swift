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
    
    private var allData: [String] = ["Antalya", "Manisa", "Mugla", "Izmir", "Ankara", "Istanbul"]
    private var filteredData: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .secondarySystemBackground
        setupUI()
        
        //tableView.delegate = self
        tableView.dataSource = self
        searchTextField.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        filteredData = allData
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
        filterData(searchText)
        return true
    }
    
    private func filterData(_ query: String) {
        if query.isEmpty {
            filteredData.removeAll()
            tableView.isHidden = true
        } else {
            filteredData = allData.filter { $0.lowercased().range(of: query.lowercased()) != nil }
            tableView.isHidden = filteredData.isEmpty
        }
        tableView.reloadData()
    }
}

extension DestinationVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = filteredData[indexPath.row]
        return cell
    }
}
