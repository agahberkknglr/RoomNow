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

        let firstView = UINavigationController(rootViewController: SearchVC())
        
        firstView.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        
        firstView.title = "Search"
        
        tabBar.tintColor = .white
        setViewControllers([firstView], animated: true)
    }
}
