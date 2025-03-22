//
//  SearchVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 22.03.2025.
//

import Foundation

protocol SearchVMProtocol {
    func viewDidLoad()
}

final class SearchVM {
    weak var view: SearchVCProtocol?
}

extension SearchVM: SearchVMProtocol {
    func viewDidLoad() {
        view?.configureVC()
    }
}
