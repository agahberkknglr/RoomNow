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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        viewModel.fetchHotels()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchHotels()
    }

    private func setupUI() {
        title = "Dashboard"
        view.backgroundColor = .appBackground
        view.addSubview(tableView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTapped)
        )
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.pinToEdges(of: view)
    }

    private func setupTableView() {
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.backgroundColor = .appBackground
        tableView.registerCell(type: AdminHotelCell.self)
        tableView.registerCell(type: AdminDashboardHeaderCell.self)
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func bindViewModel() {
        showLoadingIndicator()
        viewModel.didUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.hideLoadingIndicator()
                self?.tableView.reloadData()
            }
        }
    }
    
    @objc private func addTapped() {
        let actionSheet = UIAlertController(title: "Add New", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Add Hotel", style: .default, handler: { [weak self] _ in
            let vc = AdminAddEditHotelVC()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Add City", style: .default, handler: { [weak self] _ in
            let vc = AdminAddCityVC()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        
        if let popover = actionSheet.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }

        present(actionSheet, animated: true)
    }

    
    private func presentCityFilter() {
        let cities = viewModel.cities
        let vc = CityFilterVC(cities: cities)
        vc.onCitySelected = { [weak self] selectedCity in
            self?.viewModel.filter(by: selectedCity)
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    func attemptHotelDeletion(hotelId: String, hotelName: String) {
        let alert = UIAlertController(
            title: "Remove \(hotelName)",
            message: "Are you sure you want to delete \(hotelName)?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }

            self.viewModel.deleteHotelIfAllowed(hotelId: hotelId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.showAlert(title: "Success", message: "\(hotelName) deleted.")
                        self.viewModel.fetchHotels()
                    case .failure(let error):
                        self.showAlert(title: "Failed", message: error.localizedDescription)
                    }
                }
            }
        }))

        present(alert, animated: true)
    }
}

extension AdminDashboardVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredHotels.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeue(AdminDashboardHeaderCell.self, for: indexPath)
            cell.configure(hotelCount: viewModel.filteredHotels.count, adminName: viewModel.adminName)
            cell.onFilterTapped = { [weak self] in
                self?.presentCityFilter()
            }
            return cell
        }

        let hotel = viewModel.filteredHotels[indexPath.row - 1]
        let cell = tableView.dequeue(AdminHotelCell.self, for: indexPath)
        cell.configure(with: hotel)
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .appBackground
        return cell
    }
}

extension AdminDashboardVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row > 0 else { return }
        let hotel = viewModel.filteredHotels[indexPath.row - 1]
        let vc = AdminAddEditHotelVC(hotel: hotel)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.row > 0 else { return nil }
        let hotel = viewModel.filteredHotels[indexPath.row - 1]

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.attemptHotelDeletion(hotelId: hotel.id ?? "", hotelName: hotel.name)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

}
