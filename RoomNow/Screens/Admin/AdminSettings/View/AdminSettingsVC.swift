//
//  AdminSettingsVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 9.06.2025.
//

import UIKit

final class AdminSettingsVC: UITableViewController {

    private enum Section: Int, CaseIterable {
        case actions
        case account
    }

    private let actions: [String] = [
        "View All Reservations",
        "View All Users" // future
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Manage"
        view.backgroundColor = .appBackground
        tableView.backgroundColor = .appBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .actions:
            return actions.count
        case .account:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .actions: return "Admin Tools"
        case .account: return "Account"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .appSecondaryBackground
        switch Section(rawValue: indexPath.section)! {
        case .actions:
            cell.textLabel?.text = actions[indexPath.row]
            cell.textLabel?.textColor = .label
            cell.textLabel?.textAlignment = .left
            cell.accessoryType = .disclosureIndicator
        case .account:
            cell.textLabel?.text = "Logout"
            cell.textLabel?.textColor = .systemRed
            cell.textLabel?.textAlignment = .center
            cell.accessoryType = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch Section(rawValue: indexPath.section)! {
        case .actions:
            switch indexPath.row {
            case 0:
                // View All Reservations
                let vc = AllReservationsVC()
                navigationController?.pushViewController(vc, animated: true)
            case 1:
                // View All Users – placeholder
                print("TODO: View all users")
            default: break
            }
        case .account:
            let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { _ in
                self.performLogout()
            }))
            present(alert, animated: true)
        }
    }

    private func performLogout() {
        AuthManager.shared.logout { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = scene.windows.first {
                        window.rootViewController = UserTabBarVC() // switch back to user flow
                        window.makeKeyAndVisible()
                    }
                case .failure(let error):
                    print("Logout failed:", error)
                }
            }
        }
    }
}
