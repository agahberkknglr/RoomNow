//
//  HotelDetailVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.04.2025.
//

import UIKit

protocol HotelDetailVCProtocol: AnyObject {
    func configureVC()
}

final class HotelDetailVC: UIViewController {
    
    private let viewModel: HotelDetailVMProtocol

    init(viewModel: HotelDetailVMProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
    }
}

extension HotelDetailVC: HotelDetailVCProtocol {
    func configureVC() {
        view.backgroundColor = .appBackground
    }
}
