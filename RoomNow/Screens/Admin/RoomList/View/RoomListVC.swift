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
        view.backgroundColor = .systemBackground
        setupTableView()
        setupAddButton()
        loadRooms()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RoomCell")
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }

    private func setupAddButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addRoomTapped)
        )
    }

    private func loadRooms() {
        viewModel.fetchRooms {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    @objc private func addRoomTapped() {
        //let vc = AdminAddEditRoomVC(mode: .add(hotelId: viewModel.hotelId))
        //navigationController?.pushViewController(vc, animated: true)
    }
}

extension RoomListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.rooms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let room = viewModel.rooms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell", for: indexPath)
        cell.textLabel?.text = "\(room.roomType) • Room \(room.roomNumber) • \(room.bedCapacity) beds • $\(room.price)"
        return cell
    }
}

