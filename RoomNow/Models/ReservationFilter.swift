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

    var isEmpty: Bool {
        return selectedCities.isEmpty && selectedHotels.isEmpty && selectedStatuses.isEmpty
    }

    func matches(_ reservation: AdminReservation) -> Bool {
        let cityMatch = selectedCities.isEmpty || selectedCities.contains(reservation.reservation.city)
        let hotelMatch = selectedHotels.isEmpty || selectedHotels.contains(reservation.reservation.hotelName)
        let statusMatch = selectedStatuses.isEmpty || selectedStatuses.contains(reservation.reservation.status)

        return cityMatch && hotelMatch && statusMatch
    }
}
