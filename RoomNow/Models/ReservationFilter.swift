//
//  ReservationFilter.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 15.06.2025.
//

struct ReservationFilter {
    var selectedCities: Set<String> = []
    var selectedHotels: Set<String> = []
    var selectedStatuses: Set<ReservationStatus> = []
    var userQuery: String = ""

    var isEmpty: Bool {
        return selectedCities.isEmpty &&
               selectedHotels.isEmpty &&
               selectedStatuses.isEmpty &&
               userQuery.isEmpty
    }

    func matches(_ reservation: AdminReservation) -> Bool {
        let cityMatch = selectedCities.isEmpty || selectedCities.contains(reservation.reservation.city)
        let hotelMatch = selectedHotels.isEmpty || selectedHotels.contains(reservation.reservation.hotelName)
        let statusMatch = selectedStatuses.isEmpty || selectedStatuses.contains(reservation.reservation.status)

        let query = userQuery.lowercased()
        let nameMatch = userQuery.isEmpty || reservation.reservation.fullName.lowercased().contains(query)
        let emailMatch = userQuery.isEmpty || reservation.reservation.email.lowercased().contains(query)

        return cityMatch && hotelMatch && statusMatch && (nameMatch || emailMatch)
    }
}
