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

        setupNavBar()
        setupTableView()
        fetchData()
    }

    private func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(openFilterVC)
        )
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.identifier)
        tableView.backgroundColor = .appBackground
        view.addSubview(tableView)
        tableView.pinToEdges(of: view)
    }

    private func fetchData() {
        viewModel.fetchUsers { [weak self] in
            guard let self = self else { return }
            self.updateHeaderTitle()
            self.tableView.reloadData()
        }
    }

    private func updateHeaderTitle() {
        let count = viewModel.filteredUsers.count
        tableView.tableHeaderView = makeHeaderLabel(with: "Users: \(count)")
    }

    private func makeHeaderLabel(with text: String) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40)
        return label
    }

    @objc private func openFilterVC() {
        let vc = UserFilterVC()
        
        if let currentFilter = (viewModel as? AllUsersVM)?.currentFilter {
            vc.configure(with: currentFilter)
        }
        
        vc.onApplyFilter = { [weak self] filter in
            (self?.viewModel as? AllUsersVM)?.applyFilter(filter)
            self?.updateHeaderTitle()
            self?.tableView.reloadData()
        }
        
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}

extension AllUsersVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = viewModel.filteredUsers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as! UserCell
        cell.configure(with: user)
        cell.backgroundColor = .appBackground
        cell.selectionStyle = .none
        return cell
    }
}

extension AllUsersVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = viewModel.filteredUsers[indexPath.row]
        let vm = UserDetailVM(user: selectedUser)
        let vc = UserDetailVC(viewModel: vm)
        navigationController?.pushViewController(vc, animated: true)
    }
}
