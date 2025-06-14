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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        fetchData()
    }

    private func setupUI() {
        title = "All Reservations"
        view.backgroundColor = .appBackground
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.pinToEdges(of: view)
    }

    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .appBackground
    }

    private func fetchData() {
        viewModel.fetchReservations { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

extension AllReservationsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.reservations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let res = viewModel.reservations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = """
        Hotel: \(res.reservation.hotelName)
        User: \(res.userId)
        Check-in: \(formatter.string(from: res.reservation.checkInDate))
        Check-out: \(formatter.string(from: res.reservation.checkOutDate))
        Status: \(res.reservation.status.rawValue.capitalized)
        """
        return cell
    }
}

