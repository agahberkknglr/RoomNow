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
                
                var fetchedHotels: [Hotel] = []
                
                for doc in documents {
                    do {
                        let hotel = try doc.data(as: Hotel.self)
                        fetchedHotels.append(hotel)
                        
                        print("Hotel fetched: \(hotel.name)")
                        print("RoomTypes count: \(hotel.roomTypes.count)")
                        
                        for roomType in hotel.roomTypes {
                            print("- RoomType: \(roomType.typeName)")
                            print("- Rooms count: \(roomType.rooms.count)")
                            for room in roomType.rooms {
                                print("-- RoomNumber: \(room.roomNumber), BedCapacity: \(room.bedCapacity)")
                            }
                        }
                    } catch {
                        print("❌ Hotel decode FAILED for document \(doc.documentID): \(error)")
                    }
                }
                
                let filteredHotels = fetchedHotels.filter { hotel in
                    for roomType in hotel.roomTypes {
                        for room in roomType.rooms {
                            if room.bedCapacity >= searchParameters.guestCount &&
                                room.isAvailable(for: searchParameters.checkInDate, checkOut: searchParameters.checkOutDate) {
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
