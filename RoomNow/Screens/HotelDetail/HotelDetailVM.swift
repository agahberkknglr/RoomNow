//
//  HotelDetailVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.04.2025.
//

import Foundation

protocol HotelDetailVMProtocol {
    func viewDidLoad()
}

final class HotelDetailVM {
    weak var view: HotelDetailVCProtocol?
}

extension HotelDetailVM: HotelDetailVMProtocol {
    func viewDidLoad() {
        
    }
}
