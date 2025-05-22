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
    private let emptyView: UILabel = {
        let label = UILabel()
        label.text = "You haven't saved any hotels yet."
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        view.addSubview(emptyView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    private func fetchData() {
        showLoadingIndicator()
        emptyView.isHidden = true
        tableView.isHidden = true
        
        viewModel.fetchSavedData { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoadingIndicator()

                let hasData = !self.viewModel.cityNames.isEmpty
                self.tableView.isHidden = !hasData
                self.emptyView.isHidden = hasData
                self.tableView.reloadData()
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

