//
//  ReservationVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.04.2025.
//

import UIKit

final class ReservationVC: UIViewController {

    private let viewModel: ReservationVM
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let confirmButton = UIButton(type: .system)

    init(viewModel: ReservationVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Reservation Summary"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupTableView()
        setupConfirmButton()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupConfirmButton() {
        confirmButton.setTitle("Confirm Reservation", for: .normal)
        confirmButton.setTitleColor(.appAccent, for: .normal)
        confirmButton.backgroundColor = .appButtonBackground
        confirmButton.layer.cornerRadius = 8
        confirmButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        view.addSubview(confirmButton)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            confirmButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            confirmButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    @objc private func confirmTapped() {
        print("🛎 Reservation Confirmed")
        // Later: call FirebaseManager.shared.saveReservation(...)
    }
}

extension ReservationVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 3 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 3 // Hotel info
        case 1: return viewModel.selectedRooms.count
        case 2: return 3 // User info
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        switch indexPath.section {
        case 0:
            let rows = [
                "🏨 \(viewModel.hotel.name)",
                "📍 \(viewModel.hotel.location)",
                "🗓 \(viewModel.searchParams.checkInDate.formatted()) → \(viewModel.searchParams.checkOutDate.formatted())"
            ]
            cell.textLabel?.text = rows[indexPath.row]
        case 1:
            let room = viewModel.selectedRooms[indexPath.row]
            cell.textLabel?.text = "🛏 Room \(room.roomNumber) – ₺\(Int(room.price)) x \(viewModel.numberOfNights) nights"
        case 2:
            let rows = [
                "👤 \(viewModel.fullName)",
                "📧 \(viewModel.email)",
                "📞 \(viewModel.phone)"
            ]
            cell.textLabel?.text = rows[indexPath.row]
        default:
            break
        }
        return cell
    }
}

