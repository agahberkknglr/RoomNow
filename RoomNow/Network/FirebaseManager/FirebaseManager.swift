//
//  FirebaseManager.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 28.04.2025.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

protocol FirebaseManagerProtocol {
    func fetchHotelsAsJSON()
    func uploadHotelsToFirestore()
    
    func fetchCities(completion: @escaping (Result<[City], Error>) -> Void)
    func fetchHotels(searchParameters: HotelSearchParameters, completion: @escaping (Result<[(hotel: Hotel, rooms: [Room])], Error>) -> Void)
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
    
    func fetchHotels(searchParameters: HotelSearchParameters, completion: @escaping (Result<[(hotel: Hotel, rooms: [Room])], Error>) -> Void) {
        let db = Firestore.firestore()

        db.collection("hotels")
            .whereField("city", isEqualTo: searchParameters.destination.lowercased())
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                let documents = snapshot?.documents ?? []
                let hotels: [Hotel] = documents.compactMap { try? $0.data(as: Hotel.self) }

                let hotelIds = hotels.compactMap { $0.id }

                self.fetchRooms(for: hotelIds) { result in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))

                    case .success(let allRooms):
                        let hotelTuples: [(Hotel, [Room])] = hotels.map { hotel in
                            let rooms = allRooms.filter { $0.hotelId == hotel.id }
                            return (hotel, rooms)
                        }

                        let validHotels = hotelTuples.filter { (hotel, rooms) in
                            let available = rooms.filter {
                                $0.isAvailable(for: searchParameters.checkInDate, checkOut: searchParameters.checkOutDate)
                            }
                            return self.hasValidCombination(of: available, requiredRoomCount: searchParameters.roomCount, requiredBedCount: searchParameters.guestCount)
                        }

                        completion(.success(validHotels))
                    }
                }
            }
    }

    
    private func hasValidCombination(of rooms: [Room], requiredRoomCount: Int, requiredBedCount: Int) -> Bool {
        func backtrack(_ index: Int, _ path: [Room], _ bedSum: Int) -> Bool {
            if path.count > requiredRoomCount { return false }
            if path.count == requiredRoomCount {
                return bedSum >= requiredBedCount
            }
            guard index < rooms.count else { return false }

            if backtrack(index + 1, path + [rooms[index]], bedSum + rooms[index].bedCapacity) {
                return true
            }

            return backtrack(index + 1, path, bedSum)
        }

        return backtrack(0, [], 0)
    }
    
    func fetchRooms(for hotelIds: [String], completion: @escaping (Result<[Room], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("rooms")
            .whereField("hotelId", in: hotelIds)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                let rooms = documents.compactMap { try? $0.data(as: Room.self) }
                completion(.success(rooms))
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
    
    
    func isHotelSaved(for hotelId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.success(false))
            return
        }

        let docRef = Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("savedHotels")
            .document(hotelId)

        docRef.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(snapshot?.exists == true))
            }
        }
    }

    func toggleSavedHotel(hotelId: String, isCurrentlySaved: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "User not logged in", code: 401)))
            return
        }

        let docRef = Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("savedHotels")
            .document(hotelId)

        if isCurrentlySaved {
            docRef.delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(false)) // now not saved
                }
            }
        } else {
            docRef.setData(["hotelId": hotelId]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(true)) // now saved
                }
            }
        }
    }
    
    func saveHotel(_ hotel: SavedHotel, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "User not logged in", code: 401)))
            return
        }

        do {
            let data = try Firestore.Encoder().encode(hotel)
            Firestore.firestore()
                .collection("users")
                .document(uid)
                .collection("savedHotels")
                .document(hotel.hotelId)
                .setData(data, completion: { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                })
        } catch {
            completion(.failure(error))
        }
    }

    func deleteSavedHotel(hotelId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "User not logged in", code: 401)))
            return
        }

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("savedHotels")
            .document(hotelId)
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    func fetchSavedHotels(completion: @escaping (Result<[SavedHotel], Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "Not logged in", code: 401)))
            return
        }

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("savedHotels")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let docs = snapshot?.documents {
                    let hotels = docs.compactMap { try? $0.data(as: SavedHotel.self) }
                    completion(.success(hotels))
                } else {
                    completion(.success([]))
                }
            }
    }
    
    func fetchHotel(by id: String, completion: @escaping (Result<Hotel, Error>) -> Void) {
        Firestore.firestore().collection("hotels").document(id).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot, snapshot.exists,
                      let data = try? snapshot.data(as: Hotel.self) {
                completion(.success(data))
            } else {
                completion(.failure(NSError(domain: "Hotel not found", code: 404)))
            }
        }
    }
    
    func saveReservation(_ reservation: Reservation, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "User not logged in", code: 401)))
            return
        }

        do {
            let data = try Firestore.Encoder().encode(reservation)
            Firestore.firestore()
                .collection("users")
                .document(uid)
                .collection("reservations")
                .addDocument(data: data) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }
    
    func updateBookedDates(for roomId: String, startDate: Date, endDate: Date, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let roomRef = db.collection("rooms").document(roomId)

        roomRef.updateData([
            "bookedDates": FieldValue.arrayUnion([
                [
                    "start": Timestamp(date: startDate),
                    "end": Timestamp(date: endDate)
                ]
            ])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func fetchReservations(completion: @escaping (Result<[Reservation], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "NoUserID", code: -1)))
            return
        }

        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .collection("reservations")
            .order(by: "reservedAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    let reservations = snapshot?.documents.compactMap {
                        try? $0.data(as: Reservation.self)
                    } ?? []
                    completion(.success(reservations))
                }
            }
    }


    func updateReservationStatus(userId: String, reservationId: String, newStatus: ReservationStatus, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        var updates: [String: Any] = [
            "status": newStatus.rawValue
        ]

        if newStatus == .completed {
            updates["completedAt"] = Timestamp(date: Date())
        } else if newStatus == .cancelled {
            updates["cancelledAt"] = Timestamp(date: Date())
        }

        db.collection("users").document(userId)
            .collection("reservations")
            .document(reservationId)
            .updateData(updates) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
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
