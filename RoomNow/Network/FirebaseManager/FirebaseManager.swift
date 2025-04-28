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
}
