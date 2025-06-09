//
//  AdminTabBarVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 9.06.2025.
//

import UIKit

final class AdminTabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let dashVC = UINavigationController(rootViewController: AdminDashboardVC())
        dashVC.title = "Dashboard"
        dashVC.tabBarItem.image = UIImage(systemName: "house")
        
        let settingsVC = UINavigationController(rootViewController: AdminSettingsVC())
        settingsVC.title = "Settings"
        settingsVC.tabBarItem.image = UIImage(systemName: "gear")

        tabBar.tintColor = .appAccent
        tabBar.backgroundColor = .appSecondaryBackground
        
        setViewControllers([dashVC, settingsVC], animated: false)

    }

}
