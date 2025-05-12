//
//  SearchVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 22.03.2025.
//

import Foundation

protocol SearchVMProtocol: AnyObject {
    var delegate: SearchVMDelegate? { get set }
    var numberOfRooms: Int { get }
    var numberOfAdults: Int { get }
    var numberOfChildren: Int { get }
    var selectedStartDate: Date? { get }
    var selectedEndDate: Date? { get }
    func viewDidLoad()
    func updateSelectedCity(_ city: City)
    func updateSelectedDates(start: Date, end: Date)
    func updateSelectedRoomInfo(rooms: Int, adults: Int, children: Int)
    func getRoomButtonTitle() -> String
    func getDateButtonTitle() -> String
    func getDestinationTitle() -> String
    func isSearchEnabled() -> Bool
    func getSearchParameters() -> HotelSearchParameters?
}

protocol SearchVMDelegate: AnyObject {
    func updateUI()
}

final class SearchVM {
    weak var delegate: SearchVMDelegate?
    
    var numberOfRooms: Int { selectedRooms }
    var numberOfAdults: Int { selectedAdults }
    var numberOfChildren: Int { selectedChildren }
    
    var selectedStartDate: Date? { _selectedStartDate }
    var selectedEndDate: Date? { _selectedEndDate }

    private var selectedCity: City?
    private var _selectedStartDate: Date?
    private var _selectedEndDate: Date?
    private var selectedRooms: Int = 1
    private var selectedAdults: Int = 2
    private var selectedChildren: Int = 0
}

extension SearchVM: SearchVMProtocol {
    func viewDidLoad() {
        delegate?.updateUI()
    }

    func updateSelectedCity(_ city: City) {
        selectedCity = city
        delegate?.updateUI()
    }

    func updateSelectedDates(start: Date, end: Date) {
        _selectedStartDate = start
        _selectedEndDate = end
        delegate?.updateUI()
    }

    func updateSelectedRoomInfo(rooms: Int, adults: Int, children: Int) {
        selectedRooms = rooms
        selectedAdults = adults
        selectedChildren = children
        delegate?.updateUI()
    }

    func getDestinationTitle() -> String {
        return selectedCity?.name ?? "Select Destination"
    }

    func getDateButtonTitle() -> String {
        guard let start = selectedStartDate, let end = selectedEndDate else {
            return "Select Dates"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        formatter.timeZone = TimeZone(identifier: "Europe/Istanbul")
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }

    func getRoomButtonTitle() -> String {
        let childrenText = selectedChildren > 0 ? (selectedChildren > 1 ? "\(selectedChildren) children" : "\(selectedChildren) child") : "No children"
        return "\(selectedRooms) room • \(selectedAdults) adults • \(childrenText)"
    }

    func isSearchEnabled() -> Bool {
        return selectedCity != nil && selectedStartDate != nil && selectedEndDate != nil
    }

    func getSearchParameters() -> HotelSearchParameters? {
        guard let city = selectedCity,
              let start = selectedStartDate,
              let end = selectedEndDate else { return nil }

        return HotelSearchParameters(
            destination: city.name.lowercased(),
            checkInDate: start,
            checkOutDate: end,
            guestCount: selectedAdults + selectedChildren,
            roomCount: selectedRooms
        )
    }
}

