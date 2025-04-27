//
//  ResultVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 27.04.2025.
//

protocol ResultVMProtocol{
    func viewDidLoad()
}

final class ResultVM {
    weak var view: ResultVCProtocol?
}

extension ResultVM: ResultVMProtocol {
    func viewDidLoad() {
        view?.configureVC()
    }
}
