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
    private let buttonView = UIView()
    
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
        
        viewModel.onHotelDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        viewModel.fetchRoomsForReservation { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
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
        tableView.registerCell(type: BookingMapInfoCell.self)
        tableView.registerCell(type: BookingOtherInfoCell.self)
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

        buttonView.backgroundColor = .appSecondaryBackground
        buttonView.addSubview(cancelButton)
        view.addSubview(buttonView)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        buttonView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            buttonView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            buttonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            
            cancelButton.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: 16),
            cancelButton.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -16),
            cancelButton.bottomAnchor.constraint(equalTo: buttonView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
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
    func numberOfSections(in tableView: UITableView) -> Int { 5 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 1 ? viewModel.reservation.selectedRoomNumbers.count : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reservation = viewModel.reservation
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeue(BookingHotelInfoCell.self, for: indexPath)
            guard let hotel = viewModel.hotel else { return cell }
            cell.configure(
                hotelName: reservation.hotelName,
                location: reservation.city,
                checkIn: reservation.checkInDate,
                checkOut: reservation.checkOutDate,
                guestCount: reservation.guestCount,
                imageURLs: hotel.imageUrls,
                status: reservation.status
            )
            return cell

        case 1:
            let roomNumber = "\(viewModel.reservation.selectedRoomNumbers[indexPath.row])"
            let room = viewModel.bookedRooms[roomNumber]
            let typeName = room?.roomType ?? ""
            let nights = viewModel.numberOfNights
            let guest = reservation.fullName
            let desc = room?.description
            let cell = tableView.dequeue(BookingRoomInfoCell.self, for: indexPath)
            cell.configure(roomNumber: roomNumber, typeName: typeName, nights: nights, guestName: guest, roomDescription: desc)
            return cell

        case 2:
            let cell = tableView.dequeue(BookingPriceInfoCell.self, for: indexPath)
            cell.configure(
                totalPrice: viewModel.reservation.totalPrice,
                nights: viewModel.numberOfNights
            )
            return cell
            
        case 3:
            let cell = tableView.dequeue(BookingMapInfoCell.self, for: indexPath)
            guard let hotel = viewModel.hotel else { return cell }
            let latitude = hotel.latitude
            let longitude = hotel.longitude
            let location = "\(hotel.city.capitalized), \(hotel.location)"
            cell.configure(latitude: latitude, longitude: longitude, name: location)
            return cell
            
        case 4:
            let cell = tableView.dequeue(BookingOtherInfoCell.self, for: indexPath)
            if let hotel = viewModel.hotel {
                let amenities = hotel.amenities.compactMap { Amenity.from(string: $0) }
                cell.configure(
                    description: hotel.description,
                    isExpanded: viewModel.isDescriptionExpanded,
                    amenities: amenities,
                    onToggle: { [weak self] in
                        self?.viewModel.isDescriptionExpanded.toggle()
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                )
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
}

