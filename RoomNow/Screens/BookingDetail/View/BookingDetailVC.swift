//
//  BookingDetailVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 26.05.2025.
//

import UIKit

final class BookingDetailVC: UIViewController {
    private let viewModel: BookingDetailVM
    private let tableView = UITableView()
    private let cancelButton = UIButton()

    init(viewModel: BookingDetailVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        if viewModel.canBeDeleted {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .trash,
                target: self,
                action: #selector(deleteTapped)
            )
        }
    }

    private func setupUI() {
        view.backgroundColor = .appBackground
        title = "Reservation Details"
        setupTableView()
        setupCancelButtonIfNeeded()
    }

    private func setupTableView() {
        tableView.backgroundColor = .appBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.registerCell(type: BookingHotelInfoCell.self)
        tableView.registerCell(type: BookingPriceInfoCell.self)
        tableView.registerCell(type: BookingRoomInfoCell.self)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func setupCancelButtonIfNeeded() {
        guard viewModel.isCancelable else { return tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true }

        cancelButton.setTitle("Cancel Reservation", for: .normal)
        cancelButton.backgroundColor = .appButtonBackground
        cancelButton.setTitleColor(.appError, for: .normal)
        cancelButton.layer.cornerRadius = 8
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    @objc private func cancelTapped() {
        let alert = UIAlertController(
            title: "Cancel Reservation",
            message: "Are you sure you want to cancel this reservation?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            self?.viewModel.cancelReservation { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        self?.showErrorAlert(message: error.localizedDescription)
                    }
                }
            }
        })

        present(alert, animated: true)
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func deleteTapped() {
        let alert = UIAlertController(
            title: "Delete Reservation",
            message: "Are you sure you want to permanently delete this reservation?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteReservation()
        })

        present(alert, animated: true)
    }
    
    private func deleteReservation() {
        viewModel.deleteReservation { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    print("Failed to delete:", error.localizedDescription)
                }
            }
        }
    }


}

extension BookingDetailVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 3 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 2 ? viewModel.reservation.selectedRoomNumbers.count : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reservation = viewModel.reservation

        switch indexPath.section {
        case 0:
            let cell = tableView.dequeue(BookingHotelInfoCell.self, for: indexPath)
            cell.configure(
                hotelName: viewModel.reservation.hotelName,
                location: viewModel.reservation.city,
                checkIn: viewModel.reservation.checkInDate,
                checkOut: viewModel.reservation.checkOutDate,
                guestCount: viewModel.reservation.guestCount
            )
            return cell

        case 1:
            let roomNumber = viewModel.reservation.selectedRoomNumbers[indexPath.row]
            let typeName = "Room Type Name in here..."
            let nights = viewModel.numberOfNights
            let guest = viewModel.reservation.fullName
            let cell = tableView.dequeue(BookingRoomInfoCell.self, for: indexPath)
            cell.configure(roomNumber: roomNumber, typeName: typeName, nights: nights, guestName: guest)
            return cell

        case 2:
            let cell = tableView.dequeue(BookingPriceInfoCell.self, for: indexPath)
            cell.configure(
                totalPrice: viewModel.reservation.totalPrice,
                nights: viewModel.numberOfNights
            )
            return cell

        default:
            return UITableViewCell()
        }
    }
}

