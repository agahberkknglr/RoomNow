//
//  RoomSelectionVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 15.05.2025.
//

import UIKit

final class RoomSelectionVC: UIViewController {
    private let hotel: Hotel
    private let searchParams: HotelSearchParameters

    init(hotel: Hotel, searchParams: HotelSearchParameters) {
        self.hotel = hotel
        self.searchParams = searchParams
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        title = "Available Rooms"
    }
}
