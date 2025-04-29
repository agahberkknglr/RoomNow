//
//  TabBarVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 22.03.2025.
//

import UIKit

class TabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let searchVC = UINavigationController(rootViewController: SearchVC())
        let savedVC = UINavigationController(rootViewController: SavedVC())
        let bookingsVC = UINavigationController(rootViewController: BookingsVC())
        let loginVC = UINavigationController(rootViewController: LoginVC())
        
        searchVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        savedVC.tabBarItem.image = UIImage(systemName: "heart")
        bookingsVC.tabBarItem.image = UIImage(systemName: "bag")
        loginVC.tabBarItem.image = UIImage(systemName: "person.circle")
        
        searchVC.title = "Search"
        savedVC.title = "Saved"
        bookingsVC.title = "Bookings"
        loginVC.title = "Login"
        
        tabBar.tintColor = .white
        setViewControllers([searchVC, savedVC, bookingsVC, loginVC], animated: true)
    }
}
