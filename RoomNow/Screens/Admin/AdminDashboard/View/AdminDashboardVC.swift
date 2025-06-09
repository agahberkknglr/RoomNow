//
//  AdminDashboardVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 1.06.2025.
//

import UIKit

final class AdminDashboardVC: UIViewController {

    private let viewModel = AdminDashboardVM()

    private let tableView = UITableView()
    private let headerLabel = UILabel()
    private let addButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        viewModel.fetchHotels()
        bindViewModel()
    }

    private func setupUI() {
        title = "Admin Dashboard"
        view.backgroundColor = .appBackground

        headerLabel.text = "Welcome, \(viewModel.adminName)"
        headerLabel.font = .boldSystemFont(ofSize: 24)

        addButton.setTitle("➕ Add New Hotel", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        addButton.addTarget(self, action: #selector(addHotelTapped), for: .touchUpInside)

        view.addSubview(headerLabel)
        view.addSubview(addButton)
        view.addSubview(tableView)

        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            addButton.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            tableView.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HotelCell")
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func bindViewModel() {
        viewModel.didUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    @objc private func addHotelTapped() {
    }
}

extension AdminDashboardVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.hotels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let hotel = viewModel.hotels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "HotelCell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = hotel.name
        config.secondaryText = hotel.city
        config.image = UIImage(systemName: "building.2.fill")
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let hotel = viewModel.hotels[indexPath.row]
        print(hotel)
    }
}
