//
//  ViewController.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 21.03.2025.
//

import UIKit

protocol SearchVCProtocol: AnyObject {
    func configureVC()
}

final class SearchVC: UIViewController {
    
    private let viewModel = SearchVM()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        viewModel.viewDidLoad()
    }
}

extension SearchVC: SearchVCProtocol {
    
    func configureVC() {
        view.backgroundColor = .brown
    }
}
