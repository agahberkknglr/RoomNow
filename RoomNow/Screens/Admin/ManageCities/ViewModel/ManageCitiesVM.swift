//
//  ManageCitiesVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 18.06.2025.
//

import Foundation

protocol ManageCitiesVMProtocol {
    var filteredCities: [City] { get }
    var onUpdate: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }

    func fetchCities()
    func filterCities(by query: String)
    func deleteCity(at index: Int)
}

final class ManageCitiesVM: ManageCitiesVMProtocol {
    private(set) var allCities: [City] = []
    private(set) var filteredCities: [City] = []

    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?

    func fetchCities() {
        FirebaseManager.shared.fetchCities { [weak self] result in
            switch result {
            case .success(let cities):
                self?.allCities = cities
                self?.filteredCities = cities
                self?.onUpdate?()
            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }
    }

    func filterCities(by query: String) {
        if query.isEmpty {
            filteredCities = allCities
        } else {
            filteredCities = allCities.filter {
                $0.name.contains(query.lowercased())
            }
        }
        onUpdate?()
    }

    func deleteCity(at index: Int) {
        print("Trying to delete city at index \(index)")

        let city = filteredCities[index]
        print("Trying to delete city at city \(city)")
        guard let cityId = city.id else { return }

        print(city.name)
        FirebaseManager.shared.isCityInUse(cityName: city.name) { [weak self] inUse in
            guard let self = self else { return }

            if inUse {
                self.onError?("Cannot delete. City is used by one or more hotels.")
                return
            }

            FirebaseManager.shared.deleteCity(withId: cityId) { result in
                switch result {
                case .success:
                    print(city.name)
                    self.allCities.removeAll { $0.id == cityId }
                    self.filteredCities.remove(at: index)
                    self.onUpdate?()
                case .failure(let error):
                    print("fail \(city.name)")
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }
}
