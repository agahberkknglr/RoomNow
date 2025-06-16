//
//  UserFilterVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 16.06.2025.
//

import UIKit

final class UserFilterVC: UIViewController {

    var onApplyFilter: ((UserFilter) -> Void)?
    private var currentFilter = UserFilter()

    private enum Section: Int, CaseIterable {
        case gender
        case sort
    }

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search username or email"
        sb.autocapitalizationType = .none
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Filter Users"
        view.backgroundColor = .appBackground
        setupUI()
        tableView.reloadData()
    }

    func configure(with filter: UserFilter) {
        self.currentFilter = filter
    }

    private func setupUI() {
        view.addSubview(searchBar)
        searchBar.delegate = self

        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let applyButton = UIButton(type: .system)
        applyButton.applyPrimaryStyle(with: "Apply Filter")
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
        applyButton.translatesAutoresizingMaskIntoConstraints = false

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetTapped))

        let footer = UIView()
        footer.addSubview(applyButton)
        applyButton.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 16).isActive = true
        applyButton.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -16).isActive = true
        applyButton.topAnchor.constraint(equalTo: footer.topAnchor, constant: 12).isActive = true
        applyButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        tableView.tableFooterView = footer
        footer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 60)
    }

    @objc private func applyTapped() {
        onApplyFilter?(currentFilter)
        dismiss(animated: true)
    }

    @objc private func resetTapped() {
        currentFilter = UserFilter()
        searchBar.text = ""
        tableView.reloadData()
    }
}

extension UserFilterVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .gender: return 3
        case .sort: return 2
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .gender: return "Gender"
        case .sort: return "Sort"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let section = Section(rawValue: indexPath.section)!
        
        switch section {
        case .gender:
            let genders = ["Male", "Female", "Other"]
            let value = genders[indexPath.row]
            cell.textLabel?.text = value
            cell.accessoryType = currentFilter.genders.contains(value) ? .checkmark : .none
            
        case .sort:
            let options = [SortOption.nameAsc, SortOption.nameDesc]
            let labels = ["A-Z", "Z-A"]
            let option = options[indexPath.row]
            cell.textLabel?.text = labels[indexPath.row]
            cell.accessoryType = (currentFilter.sortOption == option) ? .checkmark : .none

        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = Section(rawValue: indexPath.section)!

        switch section {
        case .gender:
            let genders = ["Male", "Female", "Other"]
            let selectedGender = genders[indexPath.row]

            if currentFilter.genders.contains(selectedGender) {
                currentFilter.genders.remove(selectedGender)
            } else {
                currentFilter.genders.insert(selectedGender)
            }

        case .sort:
            let options = [SortOption.nameAsc, SortOption.nameDesc]
            let selected = options[indexPath.row]

            if currentFilter.sortOption == selected {
                currentFilter.sortOption = nil
            } else {
                currentFilter.sortOption = selected
            }
        }
        
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
    }

}

extension UserFilterVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentFilter.searchText = searchText.isEmpty ? nil : searchText
    }
}
