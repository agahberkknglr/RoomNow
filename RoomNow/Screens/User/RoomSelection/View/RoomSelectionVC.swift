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
    private var tableViewBottomConstraint: NSLayoutConstraint?

    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.applyPrimaryStyle(with: "Continue Reservation")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let buttonView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .appSecondaryBackground
        view.isHidden = true
        return view
    }()
    
    private var groupedRooms: [(type: String, rooms: [Room])] = []
    
    init(hotel: Hotel, rooms: [Room], searchParams: HotelSearchParameters) {
        self.viewModel = RoomSelectionVM(hotel: hotel, rooms: rooms, searchParams: searchParams)
        super.init(nibName: nil, bundle: nil)
        self.title = "Select Room"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        groupedRooms = Dictionary(grouping: viewModel.availableRooms, by: { $0.roomType })
            .sorted { $0.key < $1.key }
            //.map { (type: $0.key, rooms: $0.value) }
            .map { (type: $0.key, rooms: $0.value.sorted { $0.price < $1.price }) }
        setupTableView()
        setupButton()
        updateContinueButtonVisibility()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none

        tableView.registerCell(type: RoomTypeCell.self)
        
        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            tableViewBottomConstraint!
        ])
    }
    
    private func updateContinueButtonVisibility() {
        let shouldShowButton = viewModel.isSelectionComplete
        buttonView.isHidden = !shouldShowButton

        tableViewBottomConstraint?.isActive = false

        if shouldShowButton {
            tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: buttonView.topAnchor)
        } else {
            tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        }

        tableViewBottomConstraint?.isActive = true

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupButton() {
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        buttonView.addSubview(continueButton)
        view.addSubview(buttonView)
        NSLayoutConstraint.activate([
            buttonView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            buttonView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            continueButton.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 12),
            continueButton.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -16),
            continueButton.bottomAnchor.constraint(equalTo: buttonView.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            continueButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    @objc private func continueTapped() {
        let vm = PersonalInfoVM(
            hotel: viewModel.hotel,
            searchParams: viewModel.searchParams,
            selectedRooms: viewModel.selectedRooms
        )

        let vc = PersonalInfoVC(viewModel: vm)

        vm.notifyViewUpdate = { [weak vc] in
            DispatchQueue.main.async {
                vc?.reloadTableView()
            }
        }

        navigationController?.pushViewController(vc, animated: true)
    }
}

extension RoomSelectionVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        groupedRooms.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = groupedRooms[indexPath.section]
        let cell = tableView.dequeue(RoomTypeCell.self, for: indexPath)
        cell.configure(
            typeName: section.type,
            rooms: section.rooms,
            selectedRooms: viewModel.selectedRooms,
            forNights: viewModel.numberOfNights,
            startDate: viewModel.checkInDate,
            endDate: viewModel.checkOutDate
        )
        cell.delegate = self
        return cell
    }
}

extension RoomSelectionVC: UITableViewDelegate {
    
}

extension RoomSelectionVC: RoomTypeCellDelegate {
    func didSelectRoom(_ room: Room) {
        viewModel.toggleSelection(for: room)
        tableView.reloadData()
        updateContinueButtonVisibility()
    }
}
