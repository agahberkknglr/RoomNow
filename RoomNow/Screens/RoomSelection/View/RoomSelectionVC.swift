//
//  RoomSelectionVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 15.05.2025.
//

import UIKit

import UIKit

final class RoomSelectionVC: UIViewController {
    
    private let viewModel: RoomSelectionVMProtocol
    private let tableView = UITableView()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue Reservation", for: .normal)
        button.backgroundColor = .appButtonBackground
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.isHidden = true
        return button
    }()
    
    init(hotel: Hotel, searchParams: HotelSearchParameters) {
        self.viewModel = RoomSelectionVM(hotel: hotel, searchParams: searchParams)
        super.init(nibName: nil, bundle: nil)
        self.title = "Select Room"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupTableView()
        setupButton()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none

        tableView.registerCell(type: RoomTypeCell.self)

        view.addSubview(tableView)
        tableView.pinToEdges(of: view, withInsets: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8))
    }
    
    private func setupButton() {
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        view.addSubview(continueButton)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            continueButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    @objc private func continueTapped() {
        let vm = PersonalInfoVM(
            selectedRooms: viewModel.selectedRooms,
            hotel: viewModel.hotel,
            searchParams: viewModel.searchParams
        )
        let vc = PersonalInfoVC(viewModel: vm)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func updateContinueButtonVisibility() {
        continueButton.isHidden = !viewModel.isSelectionComplete
    }
}

extension RoomSelectionVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.availableRooms.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let roomType = viewModel.availableRooms[indexPath.section]
        let cell = tableView.dequeue(RoomTypeCell.self, for: indexPath)
        cell.configure(typeName: roomType.typeName, rooms: roomType.rooms, selectedRooms: viewModel.selectedRooms, forNights: viewModel.numberOfNights, startDate: viewModel.checkInDate, endDate: viewModel.checkOutDate)
        cell.delegate = self
        return cell
    }
}

extension RoomSelectionVC: UITableViewDelegate {
    
}

extension RoomSelectionVC: RoomTypeCellDelegate {
    func didSelectRoom(_ room: HotelRoom) {
        viewModel.toggleSelection(for: room)
        tableView.reloadData()
        updateContinueButtonVisibility()
    }
}
