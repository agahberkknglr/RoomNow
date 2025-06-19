//
//  AdminAddEditHotelVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 10.06.2025.
//

import Foundation

final class AdminAddEditHotelVM {

    var hotelToEdit: Hotel?

    var id: String = ""
    var name: String = ""
    var selectedCity: City?
    var rating: String = ""
    var location: String = ""
    var description: String = ""
    var latitude: String = ""
    var longitude: String = ""
    var amenityList: [String] = []
    var isAvailable: Bool = true

    private(set) var hotelImages: [HotelImage] = []
    var base64Images: [String] {
        hotelImages.compactMap { $0.base64String }
    }

    var availableCities: [City] = []
    
    var isEditMode: Bool {
        hotelToEdit != nil
    }

    init(hotel: Hotel? = nil) {
        self.hotelToEdit = hotel
        if let hotel = hotel {
            name = hotel.name
            selectedCity = City(id: "", name: hotel.city)
            rating = String(hotel.rating)
            location = hotel.location
            description = hotel.description
            latitude = String(hotel.latitude)
            longitude = String(hotel.longitude)
            amenityList = hotel.amenities
            setInitialImages(from: hotel)
            isAvailable = hotel.isAvailable
        }
    }
    
    func setInitialImages(from hotel: Hotel) {
        hotelImages = hotel.imageUrls.compactMap { str in
            if str.hasPrefix("http"),
               let url = URL(string: str),
               let data = try? Data(contentsOf: url) {
                return .existing(base64: data.base64EncodedString())
            } else if Data(base64Encoded: str) != nil {
                return .existing(base64: str)
            } else {
                return nil
            }
        }
    }
    
    func setImages(_ images: [HotelImage]) {
        self.hotelImages = images
    }
    
    func loadCities(completion: @escaping () -> Void) {
        FirebaseManager.shared.fetchCities { result in
            switch result {
            case .success(let cities):
                self.availableCities = cities

                if let editing = self.hotelToEdit {
                    self.selectedCity = cities.first { $0.name.lowercased() == editing.city.lowercased() }
                }

            case .failure:
                self.availableCities = []
            }
            completion()
        }
    }
    
    func validateFields() -> String? {
        if name.isEmpty { return "Hotel name is required." }
        if selectedCity == nil { return "Please select a city." }
        if location.isEmpty { return "Location is required." }
        if description.isEmpty { return "Description is required." }

        guard let ratingVal = Double(rating), ratingVal >= 1 && ratingVal <= 5 else {
            return "Star must be a number between 1 and 5."
        }

        guard Double(latitude) != nil else {
            return "Latitude must be a valid number."
        }

        guard Double(longitude) != nil else {
            return "Longitude must be a valid number."
        }

        return nil 
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

        let hotelId = hotelToEdit?.id ?? UUID().uuidString

        let newHotel = Hotel(
            id: hotelId,
            name: name,
            city: selectedCity?.name ?? "",
            rating: ratingVal,
            location: location,
            description: description,
            latitude: lat,
            longitude: lng,
            imageUrls: base64Images,
            amenities: amenityList,
            isAvailable: isAvailable
        )

        FirebaseManager.shared.addOrUpdateHotel(newHotel) { [weak self] result in
            switch result {
            case .success:
                self?.hotelToEdit = newHotel
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}

