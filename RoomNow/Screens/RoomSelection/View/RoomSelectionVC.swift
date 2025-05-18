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
    
    init(hotel: Hotel, searchParams: HotelSearchParameters) {
        self.viewModel = RoomSelectionVM(hotel: hotel, searchParams: searchParams)
        super.init(nibName: nil, bundle: nil)
        self.title = "Select a Room"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupTableView()
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
}

extension RoomSelectionVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.availableRooms.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }

    //func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //    viewModel.availableRooms[section].typeName.capitalized
    //}

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let roomType = viewModel.availableRooms[indexPath.section]
        let cell = tableView.dequeue(RoomTypeCell.self, for: indexPath)
        cell.configure(typeName: roomType.typeName, rooms: roomType.rooms)
        return cell
    }
}

extension RoomSelectionVC: UITableViewDelegate {
    
}
