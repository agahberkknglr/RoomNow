//
//  AdminAddEditHotelVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 10.06.2025.
//

import Foundation

final class AdminAddEditHotelVM {

    var hotelToEdit: Hotel?

    var name: String = ""
    var city: String = ""
    var rating: String = ""
    var location: String = ""
    var description: String = ""
    var latitude: String = ""
    var longitude: String = ""
    var imageURL: String = ""
    var amenities: String = ""

    var isEditMode: Bool {
        hotelToEdit != nil
    }

    init(hotel: Hotel? = nil) {
        self.hotelToEdit = hotel
        if let hotel = hotel {
            name = hotel.name
            city = hotel.city
            rating = String(hotel.rating)
            location = hotel.location
            description = hotel.description
            latitude = String(hotel.latitude)
            longitude = String(hotel.longitude)
            imageURL = hotel.imageUrls.first ?? ""
            amenities = hotel.amenities.joined(separator: ", ")
        }
    }

    func saveHotel(completion: @escaping (Result<Void, Error>) -> Void) {
        guard
            let ratingVal = Double(rating),
            let lat = Double(latitude),
            let lng = Double(longitude)
        else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid numeric values."])))
            return
        }

        let newHotel = Hotel(
            id: hotelToEdit?.id ?? UUID().uuidString,
            name: name,
            city: city,
            rating: ratingVal,
            location: location,
            description: description,
            latitude: lat,
            longitude: lng,
            imageUrls: imageURL.isEmpty ? [] : [imageURL],
            amenities: amenities
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
        )

        FirebaseManager.shared.addOrUpdateHotel(newHotel, completion: completion)
    }
}

