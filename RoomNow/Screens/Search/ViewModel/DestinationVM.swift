//
//  DestinationVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 28.04.2025.
//

protocol DestinationVMProtocol: AnyObject {
    var cities: [City] { get }
    var filteredCities: [City] { get }
    
    func fetchCities(completion: @escaping (Result<Void, Error>) -> Void)
    func filterCities(with query: String)
}

final class DestinationVM: DestinationVMProtocol {
    private let firebaseManager: FirebaseManagerProtocol
    private(set) var cities: [City] = []
    private(set) var filteredCities: [City] = []
    
    init(firebaseManager: FirebaseManagerProtocol = FirebaseManager.shared) {
        self.firebaseManager = firebaseManager
    }
    
    func fetchCities(completion: @escaping (Result<Void, Error>) -> Void) {
        firebaseManager.fetchCities { [weak self] result in
            switch result {
            case .success(let cities):
                self?.cities = cities
                self?.filteredCities = cities
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func filterCities(with query: String) {
        print("Searching: \(query)")
        guard !query.isEmpty else {
            filteredCities = cities
            return
        }
        
        filteredCities = cities.filter { city in
            city.name.lowercased().hasPrefix(query.lowercased())
        }
    }
}
