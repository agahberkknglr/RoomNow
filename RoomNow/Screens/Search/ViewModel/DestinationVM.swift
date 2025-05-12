//
//  DestinationVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 28.04.2025.
//

import Foundation

protocol DestinationVMDelegate: AnyObject {
    func didUpdateCityList()
    func didFailToLoadCities(error: Error)
}

protocol DestinationVMProtocol: AnyObject {
    var delegate: DestinationVMDelegate? { get set }
    var numberOfCities: Int { get }
    func city(at index: Int) -> City?
    func fetchCities()
    func filterCities(with query: String)
}

final class DestinationVM: DestinationVMProtocol {
    
    weak var delegate: DestinationVMDelegate?
    
    private let firebaseManager: FirebaseManagerProtocol
    private var allCities: [City] = []
    private var filteredCities: [City] = []

    init(firebaseManager: FirebaseManagerProtocol = FirebaseManager.shared) {
        self.firebaseManager = firebaseManager
    }

    var numberOfCities: Int {
        return filteredCities.count
    }

    func city(at index: Int) -> City? {
        guard index >= 0 && index < filteredCities.count else { return nil }
        return filteredCities[index]
    }

    func fetchCities() {
        firebaseManager.fetchCities { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let cities):
                    self?.allCities = cities
                    self?.filteredCities = cities
                    self?.delegate?.didUpdateCityList()
                case .failure(let error):
                    self?.delegate?.didFailToLoadCities(error: error)
                }
            }
        }
    }

    func filterCities(with query: String) {
        guard !query.isEmpty else {
            filteredCities = []
            delegate?.didUpdateCityList()
            return
        }

        filteredCities = allCities.filter {
            $0.name.lowercased().hasPrefix(query.lowercased())
        }
        delegate?.didUpdateCityList()
    }
}
