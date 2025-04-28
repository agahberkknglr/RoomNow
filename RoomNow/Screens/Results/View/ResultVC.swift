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
    
    private let viewModel: ResultVM

    init(searchParameters: HotelSearchParameters) {
        self.viewModel = ResultVM(searchParameters: searchParameters)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        viewModel.viewDidLoad()
    }
}

extension ResultVC: ResultVCProtocol {
    func configureVC() {
        view.backgroundColor = .white
        
        viewModel.fetchHotels {
            DispatchQueue.main.async {
                print("Oteller geldi, CollectionView/TableView reload yapılacak.")
                // burada reloadData çağıracağız (sonraki adımda)
            }
        }
    }
}
