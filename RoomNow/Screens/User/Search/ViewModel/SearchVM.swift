//
//  SearchVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 22.03.2025.
//

import Foundation
import FirebaseAuth

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
    func getSelectedCityName() -> String?
    func isSearchEnabled() -> Bool
    func getSearchParameters() -> HotelSearchParameters?
    func saveRecentSearch()
    func numberOfRecentSearches() -> Int
    func recentSearch(at index: Int) -> HotelSearchParameters?
    func recentSearchTitle(at index: Int) -> String
    func loadRecentSearches()
    func historyCellViewModel(at index: Int) -> HistoryCellViewModel
    func deleteRecentSearch(at index: Int)
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
    private(set) var recentSearches: [RecentSearch] = []

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
    
    func getSelectedCityName() -> String? {
        return selectedCity?.name
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
    
    func saveRecentSearch() {
        guard let userId = Auth.auth().currentUser?.uid,
              let parameters = getSearchParameters() else { return }
        CoreDataManager.shared.saveRecentSearch(parameters, for: userId)
    }

    func loadRecentSearches() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        recentSearches = CoreDataManager.shared.fetchRecentSearches(for: userId)
        delegate?.updateUI()
    }

    func numberOfRecentSearches() -> Int {
        return recentSearches.count
    }

    func recentSearch(at index: Int) -> HotelSearchParameters? {
        let s = recentSearches[index]
        guard let destination = s.destination,
              let checkIn = s.checkInDate,
              let checkOut = s.checkOutDate else {
            return nil
        }
        
        return HotelSearchParameters(
            destination: destination,
            checkInDate: checkIn,
            checkOutDate: checkOut,
            guestCount: Int(s.guestCount),
            roomCount: Int(s.roomCount)
        )
    }

    func recentSearchTitle(at index: Int) -> String {
        let s = recentSearches[index]
        let destination = s.destination ?? ""
        let guestCount = Int(s.guestCount)
        let roomCount = Int(s.roomCount)
        return "\(destination.capitalized), \(roomCount) room, \(guestCount) guests"
    }
    
    func historyCellViewModel(at index: Int) -> HistoryCellViewModel {
        let search = recentSearches[index]
        
        let destination = search.destination ?? "Unknown"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        let checkIn = search.checkInDate.map { dateFormatter.string(from: $0) } ?? "-"
        let checkOut = search.checkOutDate.map { dateFormatter.string(from: $0) } ?? "-"
        let dateRange = "\(checkIn) - \(checkOut)"
        
        let guestSummary = "\(search.roomCount) room • \(search.guestCount) guests"

        return HistoryCellViewModel(
            destination: destination.capitalized,
            dateRange: dateRange,
            guestSummary: guestSummary
        )
    }
    
    func deleteRecentSearch(at index: Int) {
        guard index < recentSearches.count else { return }

        let search = recentSearches[index]
        CoreDataManager.shared.deleteRecentSearch(search)
        recentSearches.remove(at: index)
    }
}

