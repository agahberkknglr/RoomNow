//
//  ResultVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 27.04.2025.
//

import Foundation

protocol ResultVMProtocol {
    func viewDidLoad()
    func fetchHotels(completion: @escaping () -> Void)
}

final class ResultVM {
    
    weak var view: ResultVCProtocol?
    private let searchParameters: HotelSearchParameters
    private(set) var hotels: [Hotel] = []
    
    init(searchParameters: HotelSearchParameters) {
        self.searchParameters = searchParameters
        print(searchParameters)
    }
}

extension ResultVM: ResultVMProtocol {
    
    func viewDidLoad() {
        view?.configureVC()
    }
    
    func fetchHotels(completion: @escaping () -> Void) {
        FirebaseManager.shared.fetchHotels(searchParameters: searchParameters) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let hotels):
                self.hotels = hotels
                print(" Found \(hotels.count) hotels matching search criteria.")
                            
                            for hotel in hotels {
                                print("Hotel Name: \(hotel.name)")
                                print("City: \(hotel.city)")
                                print("Stars: \(hotel.rating)")
                                print("---")
                            }
                completion()
            case .failure(let error):
                print("Failed to fetch hotels: \(error.localizedDescription)")
                completion()
            }
        }
    }

}

