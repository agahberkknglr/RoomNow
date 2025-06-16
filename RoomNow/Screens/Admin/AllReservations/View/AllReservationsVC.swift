//
//  AllReservationsVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 14.06.2025.
//

import UIKit

final class AllReservationsVC: UIViewController {

    private let viewModel: AllReservationsVMProtocol = AllReservationsVM()
    private let tableView = UITableView()
    private let emptyView: UILabel = {
        let label = UILabel()
        label.text = "No reservations found."
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(showFilterOptions)
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
    }

    private func setupUI() {
        title = "All Reservations"
        view.backgroundColor = .appBackground
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.pinToEdges(of: view)
        view.addSubview(emptyView)
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func setupTableView() {
        tableView.registerCell(type: ReservationCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .appBackground
    }
    
    private func updateHeaderTitle() {
        let count = viewModel.reservations.count
        let headerView = makeHeaderLabel(with: "Reservations: \(count)")
        headerView.layoutIfNeeded()
        let targetSize = CGSize(width: tableView.frame.width, height: UIView.layoutFittingCompressedSize.height)
        let height = headerView.systemLayoutSizeFitting(targetSize).height
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: height)
        
        tableView.tableHeaderView = headerView
    }
    
    private func makeHeaderLabel(with text: String) -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        return container
    }
    
    private func updateEmptyView() {
        emptyView.isHidden = !viewModel.reservations.isEmpty
        tableView.isHidden = viewModel.reservations.isEmpty
    }

    private func fetchData() {
        showLoadingIndicator()
        viewModel.fetchReservations { [weak self] in
            DispatchQueue.main.async {
                self?.hideLoadingIndicator()
                self?.updateHeaderTitle()
                self?.tableView.reloadData()
                self?.updateEmptyView()
            }
        }
    }
    
    @objc private func showFilterOptions() {
        guard let vm = viewModel as? AllReservationsVM else { return }

        let allCities = Set(vm.allReservations.map { $0.reservation.city }).sorted()
        let allHotels = Set(vm.allReservations.map { $0.reservation.hotelName }).sorted()

        let vc = ReservationFilterVC(
            cities: allCities,
            hotels: allHotels,
            selected: vm.currentFilter
        )

        vc.onFilterSelected = { [weak self] selected in
            vm.currentFilter = selected
            self?.updateHeaderTitle()
            self?.tableView.reloadData()
            self?.updateEmptyView()
        }

        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

}

extension AllReservationsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.reservations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let res = viewModel.reservations[indexPath.row]
        let cell = tableView.dequeue(ReservationCell.self, for: indexPath)
        cell.backgroundColor = .appBackground
        cell.configure(with: res.reservation)
        return cell
    }
}

extension AllReservationsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let adminReservation = viewModel.reservations[indexPath.row].reservation
        
        guard let id = adminReservation.id else {
            print("Reservation missing ID")
            return
        }

        let vm = BookingDetailVM(reservation: adminReservation, reservationId: id)
        let vc = BookingDetailVC(viewModel: vm, isAdminMode: true)
        navigationController?.pushViewController(vc, animated: true)
    }
}
