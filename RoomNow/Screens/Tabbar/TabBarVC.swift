//
//  TabBarVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 22.03.2025.
//

import UIKit

final class TabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let searchVC = UINavigationController(rootViewController: SearchVC())
        searchVC.title = "Search"
        searchVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")

        let savedVC = UINavigationController(rootViewController: SavedVC())
        savedVC.title = "Saved"
        savedVC.tabBarItem.image = UIImage(systemName: "heart")

        let bookingsVC = UINavigationController(rootViewController: BookingsVC())
        bookingsVC.title = "Bookings"
        bookingsVC.tabBarItem.image = UIImage(systemName: "bag")

        let isLoggedIn = AuthManager.shared.currentUser != nil

        let accountVC: UINavigationController
        if isLoggedIn {
            accountVC = UINavigationController(rootViewController: ProfileVC())
            accountVC.title = "Profile"
            accountVC.tabBarItem.image = UIImage(systemName: "person.fill")
        } else {
            accountVC = UINavigationController(rootViewController: LoginVC())
            accountVC.title = "Login"
            accountVC.tabBarItem.image = UIImage(systemName: "person.circle")
        }

        tabBar.tintColor = .appAccent
        tabBar.backgroundColor = .appSecondaryBackground

        setViewControllers([searchVC, savedVC, bookingsVC, accountVC], animated: false)
    }
    
    func reloadTabsAfterLogin() {
        setupTabs()
        selectedIndex = 3
    }
    
    func reloadTabsAfterLogout() {
        setupTabs()
        selectedIndex = 3
    }

}
