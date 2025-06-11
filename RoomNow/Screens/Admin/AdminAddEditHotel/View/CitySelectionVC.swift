//
//  CitySelectionVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 11.06.2025.
//

import UIKit

final class CitySelectionVC: UIViewController {

    private let tableView = UITableView()
    private let searchBar = UISearchBar()

    private let allCities: [City]
    private var filteredCities: [City]

    var onCitySelected: ((City) -> Void)?

    init(cities: [City]) {
        self.allCities = cities
        self.filteredCities = cities
        super.init(nibName: nil, bundle: nil)
        self.title = "Select City"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        searchBar.placeholder = "Search city"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CityCell")

        view.addSubview(searchBar)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissSelf))
    }

    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
}

extension CitySelectionVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let city = filteredCities[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = city.name.capitalized
        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let city = filteredCities[indexPath.row]
        onCitySelected?(city)
        dismiss(animated: true)
    }
}

extension CitySelectionVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredCities = allCities
        } else {
            filteredCities = allCities.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
}
