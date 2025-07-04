//
//  RoomListVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 12.06.2025.
//

import UIKit

final class RoomListVC: UIViewController {
    private let viewModel: RoomListVM
    private let tableView = UITableView()
    
    init(hotelId: String) {
        self.viewModel = RoomListVM(hotelId: hotelId)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rooms"
        view.backgroundColor = .appBackground
        setupTableView()
        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRooms()
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .appBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RoomCell.self, forCellReuseIdentifier: RoomCell.reuseID)
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    
    private func setupNavBar() {
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addRoomTapped)
        )
        let sortButton = UIBarButtonItem(
            title: "Sort",
            style: .plain,
            target: self,
            action: #selector(sortTapped)
        )
        navigationItem.rightBarButtonItems = [sortButton, addButton]
    }
    
    @objc private func sortTapped() {
        let alert = UIAlertController(title: "Sort Rooms By", message: nil, preferredStyle: .actionSheet)
        
        RoomSortOption.allCases.forEach { option in
            alert.addAction(UIAlertAction(title: option.rawValue, style: .default, handler: { _ in
                self.viewModel.sortOption = option
                self.tableView.reloadData()
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func loadRooms() {
        showLoadingIndicator()
        viewModel.fetchRooms {
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
                self.tableView.reloadData()
            }
        }
    }
    
    @objc private func addRoomTapped() {
        let hotelId = viewModel.getHotelId
        let vc = AdminAddEditRoomVC(mode: .add(hotelId: hotelId))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func attemptRoomDeletion(room: Room) {
        viewModel.attemptRoomDeletion(room) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    self.loadRooms()
                case .failure(RoomDeletionError.hasBookings):
                    self.showAlert(title: "Cannot Delete", message: "This room has active or upcoming reservations.")
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
}


extension RoomListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sortedRooms().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let room = viewModel.sortedRooms()[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: RoomCell.reuseID, for: indexPath) as! RoomCell
        cell.configure(with: room)
        cell.selectionStyle = .none
        cell.backgroundColor = .appBackground
        return cell
    }
}

extension RoomListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let hotelId = viewModel.getHotelId
        let room = viewModel.sortedRooms()[indexPath.row]
        let vc = AdminAddEditRoomVC(mode: .edit(hotelId: hotelId, room: room))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let room = viewModel.sortedRooms()[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            self?.attemptRoomDeletion(room: room)
            completionHandler(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

