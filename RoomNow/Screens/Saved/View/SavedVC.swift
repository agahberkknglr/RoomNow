//
//  SavedVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.04.2025.
//

import UIKit

final class SavedVC: UIViewController {

    private let viewModel = SavedVM()

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }

    private func setupUI() {
        title = "Saved"
        view.backgroundColor = .appBackground

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CityCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func fetchData() {
        viewModel.fetchSavedData { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

// MARK: - TableView DataSource

extension SavedVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.cityNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let city = viewModel.cityNames[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
        cell.textLabel?.text = city.capitalized
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension SavedVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let city = viewModel.cityNames[indexPath.row]
        let hotels = viewModel.hotels(for: city)
        print(city)
        print(hotels[0].hotelName)
        //let hotelListVC = SavedHotelVC(city: city, hotels: hotels)
        //navigationController?.pushViewController(hotelListVC, animated: true)
    }
}

