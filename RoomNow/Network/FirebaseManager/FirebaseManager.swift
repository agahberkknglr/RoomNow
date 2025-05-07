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
    func fetchHotelsAsJSON()
    func uploadHotelsToFirestore()
    
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
    
    func fetchHotelsAsJSON() {
        let db = Firestore.firestore()
        db.collection("hotels").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found")
                return
            }

            var jsonArray: [[String: Any]] = []

            for document in documents {
                var data = document.data()

                // Convert FIRTimestamp to ISO8601 string
                data = self.convertTimestampsToString(in: data)

                data["id"] = document.documentID
                jsonArray.append(data)
            }

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)

                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print(jsonString)
                }

            } catch {
                print("Failed to serialize data to JSON: \(error)")
            }
        }
    }

    func convertTimestampsToString(in dict: [String: Any]) -> [String: Any] {
        var result = [String: Any]()
        for (key, value) in dict {
            if let timestamp = value as? Timestamp {
                result[key] = ISO8601DateFormatter().string(from: timestamp.dateValue())
            } else if let subDict = value as? [String: Any] {
                result[key] = convertTimestampsToString(in: subDict)
            } else if let array = value as? [Any] {
                result[key] = array.map { item -> Any in
                    if let ts = item as? Timestamp {
                        return ISO8601DateFormatter().string(from: ts.dateValue())
                    } else if let dictItem = item as? [String: Any] {
                        return convertTimestampsToString(in: dictItem)
                    } else {
                        return item
                    }
                }
            } else {
                result[key] = value
            }
        }
        return result
    }
    
    func uploadHotelsToFirestore() {
        let db = Firestore.firestore()
        
        guard let hotels = loadHotelJSON() else { return }
        let isoFormatter = ISO8601DateFormatter()

        for var hotel in hotels {
            // Convert string dates in bookedDates → Timestamp
            if var roomTypes = hotel["roomTypes"] as? [[String: Any]] {
                for i in 0..<roomTypes.count {
                    if var rooms = roomTypes[i]["rooms"] as? [[String: Any]] {
                        for j in 0..<rooms.count {
                            if var bookedDates = rooms[j]["bookedDates"] as? [[String: Any]] {
                                for k in 0..<bookedDates.count {
                                    if let startStr = bookedDates[k]["start"] as? String,
                                       let startDate = isoFormatter.date(from: startStr) {
                                        bookedDates[k]["start"] = Timestamp(date: startDate)
                                    }
                                    if let endStr = bookedDates[k]["end"] as? String,
                                       let endDate = isoFormatter.date(from: endStr) {
                                        bookedDates[k]["end"] = Timestamp(date: endDate)
                                    }
                                }
                                rooms[j]["bookedDates"] = bookedDates
                            }
                        }
                        roomTypes[i]["rooms"] = rooms
                    }
                }
                hotel["roomTypes"] = roomTypes
            }

            // Upload to Firestore
            if let id = hotel["id"] as? String {
                db.collection("hotels").document(id).setData(hotel) { error in
                    if let error = error {
                        print("❌ Failed to upload hotel \(id): \(error)")
                    } else {
                        print("✅ Uploaded hotel \(id)")
                    }
                }
            }
        }
    }

    
    func loadHotelJSON() -> [[String: Any]]? {
        guard let url = Bundle.main.url(forResource: "antalya_hotels_dual_roomtypes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            print("❌ Failed to load or parse JSON")
            return nil
        }
        return jsonArray
    }


}
