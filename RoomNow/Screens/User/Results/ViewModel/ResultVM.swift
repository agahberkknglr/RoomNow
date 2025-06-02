//
//  ResultVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 27.04.2025.
//

import Foundation

protocol ResultVMProtocol {
    var hotelRooms: [(hotel: Hotel, rooms: [Room])] { get }
    var searchParameters: HotelSearchParameters { get }
    var delegate: ResultVMDelegate? { get set }

    func fetchHotels()
}

protocol ResultVMDelegate: AnyObject {
    func didFetchHotels()
}

final class ResultVM: ResultVMProtocol {
    
    weak var delegate: ResultVMDelegate?
    private(set) var hotelRooms: [(hotel: Hotel, rooms: [Room])] = []
    let searchParameters: HotelSearchParameters

    init(searchParameters: HotelSearchParameters) {
        self.searchParameters = searchParameters
    }

    func fetchHotels() {
        FirebaseManager.shared.fetchHotels(searchParameters: searchParameters) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let hotelRooms):
                self.hotelRooms = hotelRooms
                self.delegate?.didFetchHotels()
            case .failure(let error):
                print("Failed to fetch hotels: \(error.localizedDescription)")
                self.delegate?.didFetchHotels()
            }
        }
    }
}


