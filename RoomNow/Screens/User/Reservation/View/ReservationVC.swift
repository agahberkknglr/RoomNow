//
//  ReservationVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.04.2025.
//

import UIKit

final class ReservationVC: UIViewController {

    private let viewModel: ReservationVM
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let confirmButton = UIButton()
    private let buttonView: UIView = {
        let view = UIView()
        view.backgroundColor = .appSecondaryBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(viewModel: ReservationVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        title = "Booking Summary"
        setupTableView()
        setupConfirmButton()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        tableView.registerCell(type: HotelInfoCell.self)
        tableView.registerCell(type: PriceCell.self)
        tableView.registerCell(type: RoomInfoCell.self)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupConfirmButton() {
        confirmButton.applyPrimaryStyle(with: "Book Now")
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        buttonView.addSubview(confirmButton)
        view.addSubview(buttonView)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            buttonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            confirmButton.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 12),
            confirmButton.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: 16),
            confirmButton.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -16),
            confirmButton.bottomAnchor.constraint(equalTo: buttonView.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            confirmButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    @objc private func confirmTapped() {
        viewModel.confirmReservation { [weak self] result in
            switch result {
            case .success:
                print("✅ Reservation and room updates complete")
                self?.showBookingSuccessAlert()
            case .failure(let error):
                print("❌ Error: \(error.localizedDescription)")
                self?.showBookingErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    private func showBookingSuccessAlert() {
        let alert = UIAlertController(
            title: "Booking Confirmed",
            message: "Your reservation was successfully completed.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigateAfterBooking()
        })

        present(alert, animated: true)
    }
    
    private func showBookingErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Booking Failed",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func navigateAfterBooking() {
        navigationController?.popToRootViewController(animated: true)
        tabBarController?.selectedIndex = 2
    }
}

extension ReservationVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 3 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1 // hotel + check-in/out
        case 1: return 1 // price summary
        case 2: return viewModel.selectedRooms.count // room info
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeue(HotelInfoCell.self, for: indexPath)
            cell.configure(hotel: viewModel.hotel,
                           checkIn: viewModel.searchParams.checkInDate,
                           checkOut: viewModel.searchParams.checkOutDate,
                           guests: viewModel.searchParams.guestCount)
            return cell

        case 1:
            let cell = tableView.dequeue(PriceCell.self, for: indexPath)
            cell.configure(totalPrice: viewModel.totalPrice,
                           nights: viewModel.numberOfNights)
            return cell
            
        case 2:
            let room = viewModel.selectedRooms[indexPath.row]
            let cell = tableView.dequeue(RoomInfoCell.self, for: indexPath)
            cell.configure(room: room, typeName: room.description, nights: viewModel.numberOfNights, guest: viewModel.fullName)
            return cell

        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
}
