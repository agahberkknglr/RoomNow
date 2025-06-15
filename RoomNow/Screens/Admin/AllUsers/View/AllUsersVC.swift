//
//  AllUsersVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 15.06.2025.
//

import UIKit

final class AllUsersVC: UIViewController {
    private let viewModel: AllUsersVMProtocol = AllUsersVM()
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "All Users"
        view.backgroundColor = .appBackground

        setupTableView()
        fetchData()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .appBackground
        view.addSubview(tableView)
        tableView.pinToEdges(of: view)
    }

    private func fetchData() {
        viewModel.fetchUsers { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

extension AllUsersVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = viewModel.users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(user.username) (\(user.email))"
        return cell
    }
}
