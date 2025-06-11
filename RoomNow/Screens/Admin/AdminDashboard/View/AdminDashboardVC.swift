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
            action: #selector(addHotelTapped)
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
        viewModel.didUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    @objc private func addHotelTapped() {
        let vc = AdminAddEditHotelVC()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
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
}
