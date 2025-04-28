//
//  FirebaseManager.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 28.04.2025.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

protocol FirebaseManagerProtocol {
    
    func fetchCities(completion: @escaping (Result<[City], Error>) -> Void)
    func fetchHotels(searchParameters: HotelSearchParameters, completion: @escaping (Result<[Hotel], Error>) -> Void)
}

final class FirebaseManager {
    static let shared = FirebaseManager()
    
    private init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
}

extension FirebaseManager: FirebaseManagerProtocol {
    
    func fetchCities(completion: @escaping (Result<[City], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("cities").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let snapshot = snapshot {
                let cities = snapshot.documents.compactMap { (queryDocumentSnapshot) -> City? in
                    return try? queryDocumentSnapshot.data(as: City.self )
                }
                completion(.success(cities))
            }
        }
    }
    
    func fetchHotels(searchParameters: HotelSearchParameters, completion: @escaping (Result<[Hotel], Error>) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("hotels")
            .whereField("city", isEqualTo: searchParameters.destination.lowercased())
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
               //let fetchedHotels = documents.compactMap { doc -> Hotel? in
               //    try? doc.data(as: Hotel.self)
               //}
                let fetchedHotels = documents.compactMap { doc -> Hotel? in
                    let hotel = try? doc.data(as: Hotel.self)
                    
                    if let hotel = hotel {
                        print("Hotel fetched: \(hotel.name)")
                        print("RoomTypes count: \(hotel.roomTypes.count)")
                        for roomType in hotel.roomTypes {
                            print("- RoomType: \(roomType.typeName)")
                            print("- Rooms count: \(roomType.rooms.count)")
                            for room in roomType.rooms {
                                print("-- RoomNumber: \(room.roomNumber), BedCapacity: \(room.bedCapacity)")
                            }
                        }
                    } else {
                        print("Hotel decode FAILED for document \(doc.documentID)")
                    }
                    
                    return hotel
                }
                
                let filteredHotels = fetchedHotels.filter { hotel in
                    for roomType in hotel.roomTypes {
                        for room in roomType.rooms {
                            if room.bedCapacity >= searchParameters.guestCount {
                                return true
                            }
                        }
                    }
                    return false
                }
                
                completion(.success(filteredHotels))
            }
    }
}
