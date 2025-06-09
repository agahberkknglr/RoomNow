//
//  AdminSettingsVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 9.06.2025.
//

import UIKit

final class AdminSettingsVC: UITableViewController {

    private enum Section: Int, CaseIterable {
        case account
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .appBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Logout only for now
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Account"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Logout"
        cell.textLabel?.textColor = .systemRed
        cell.textLabel?.textAlignment = .center
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { _ in
            self.performLogout()
        }))
        present(alert, animated: true)
    }

    private func performLogout() {
        AuthManager.shared.logout { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = scene.windows.first {
                        window.rootViewController = UserTabBarVC() // fallback to user flow
                        window.makeKeyAndVisible()
                    }
                case .failure(let error):
                    print("Logout failed:", error)
                }
            }
        }
    }
}
