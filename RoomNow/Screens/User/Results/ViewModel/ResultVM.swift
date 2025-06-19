//
//  ResultVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 27.04.2025.
//

import Foundation

protocol ResultVMProtocol {
    var hotelRooms: [(hotel: Hotel, rooms: [Room])] { get }
    var filteredHotelRooms: [(hotel: Hotel, rooms: [Room])] { get }
    var searchParameters: HotelSearchParameters { get set }
    var delegate: ResultVMDelegate? { get set }
    var currentFilter: HotelFilterOptions? { get }
    func fetchHotels()
    func applyFilter(_ options: HotelFilterOptions)
}

protocol ResultVMDelegate: AnyObject {
    func didFetchHotels()
}

final class ResultVM: ResultVMProtocol {
    
    weak var delegate: ResultVMDelegate?
    private(set) var hotelRooms: [(hotel: Hotel, rooms: [Room])] = []
    private(set) var filteredHotelRooms: [(hotel: Hotel, rooms: [Room])] = []
    var searchParameters: HotelSearchParameters
    private(set) var currentFilter: HotelFilterOptions? = nil


    init(searchParameters: HotelSearchParameters) {
        self.searchParameters = searchParameters
    }

    func fetchHotels() {
        FirebaseManager.shared.fetchHotels(searchParameters: searchParameters) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let hotelRooms):
                self.hotelRooms = hotelRooms
                self.filteredHotelRooms = hotelRooms
                self.delegate?.didFetchHotels()
            case .failure(let error):
                print("Failed to fetch hotels: \(error.localizedDescription)")
                self.delegate?.didFetchHotels()
            }
        }
    }
    
    func applyFilter(_ options: HotelFilterOptions) {
        self.currentFilter = options
        var filtered = hotelRooms

        if let minRating = options.minRating {
            filtered = filtered.filter { $0.hotel.rating >= minRating }
        }

        if let sort = options.sortBy {
            switch sort {
            case .priceAsc:
                filtered.sort {
                    let combo1 = HotelCellVM(hotel: $0.hotel, rooms: $0.rooms, searchParams: searchParameters).roomCombination
                    let combo2 = HotelCellVM(hotel: $1.hotel, rooms: $1.rooms, searchParams: searchParameters).roomCombination

                    let price1 = combo1.reduce(0) { $0 + Int($1.price) }
                    let price2 = combo2.reduce(0) { $0 + Int($1.price) }

                    return price1 < price2
                }
            case .priceDesc:
                filtered.sort {
                    let combo1 = HotelCellVM(hotel: $0.hotel, rooms: $0.rooms, searchParams: searchParameters).roomCombination
                    let combo2 = HotelCellVM(hotel: $1.hotel, rooms: $1.rooms, searchParams: searchParameters).roomCombination

                    let price1 = combo1.reduce(0) { $0 + Int($1.price) }
                    let price2 = combo2.reduce(0) { $0 + Int($1.price) }

                    return price1 > price2
                }
            case .ratingAsc:
                filtered.sort { $0.hotel.rating < $1.hotel.rating }
            case .ratingDesc:
                filtered.sort { $0.hotel.rating > $1.hotel.rating }
            }
        }
        
        if !options.selectedAmenities.isEmpty {
            let selectedStrings = options.selectedAmenities.map { $0.rawValue }
            filtered = filtered.filter { hotelTuple in
                let hotelAmenities = hotelTuple.hotel.amenities
                return selectedStrings.allSatisfy { hotelAmenities.contains($0) }
            }
        }

        self.filteredHotelRooms = filtered
        delegate?.didFetchHotels()
    }

}


