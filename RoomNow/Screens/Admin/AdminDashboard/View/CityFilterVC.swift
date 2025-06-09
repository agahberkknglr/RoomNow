//
//  CityFilterVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 9.06.2025.
//

import UIKit

final class CityFilterVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    private var allCities: [String]
    private var filteredCities: [String]
    private let tableView = UITableView()
    private let searchBar = UISearchBar()

    var onCitySelected: ((String?) -> Void)?

    init(cities: [String]) {
        self.allCities = cities
        self.filteredCities = cities
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Select City"
        setupUI()
    }

    private func setupUI() {
        searchBar.placeholder = "Search cities"
        searchBar.delegate = self

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CityCell")

        view.addSubview(searchBar)
        view.addSubview(tableView)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
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
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCities.count + 1 // Include "All"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
        if indexPath.row == 0 {
            cell.textLabel?.text = "Show All"
        } else {
            cell.textLabel?.text = filteredCities[indexPath.row - 1].capitalized
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true)
        if indexPath.row == 0 {
            onCitySelected?(nil)
        } else {
            onCitySelected?(filteredCities[indexPath.row - 1])
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredCities = allCities
        } else {
            filteredCities = allCities.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
    }
}
