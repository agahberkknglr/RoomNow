//
//  ResultVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 27.04.2025.
//

import UIKit

protocol ResultVCProtocol: AnyObject {
    func configureVC()
}

final class ResultVC: UIViewController {
    
    private let viewModel = ResultVM()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        viewModel.viewDidLoad()
    }


}

extension ResultVC: ResultVCProtocol {
    func configureVC() {
        view.backgroundColor = .blue
    }
}
