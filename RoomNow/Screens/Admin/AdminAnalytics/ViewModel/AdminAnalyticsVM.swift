//
//  AdminAnalyticsVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 16.06.2025.
//

import FirebaseFirestore

protocol AdminAnalyticsVMProtocol {
    var totalUsers: Int { get }
    var totalHotels: Int { get }
    var totalReservations: Int { get }

    var genderStats: [String: Int] { get }
    var monthlyReservations: [String: Int] { get }
    var orderedMonths: [String] { get }

    func fetchAnalytics(completion: @escaping () -> Void)
}

final class AdminAnalyticsVM: AdminAnalyticsVMProtocol {
    private(set) var totalUsers: Int = 0
    private(set) var totalHotels: Int = 0
    private(set) var totalReservations: Int = 0
    private(set) var genderStats: [String: Int] = [:]
    private(set) var monthlyReservations: [String: Int] = [:]
    private(set) var orderedMonths: [String] = []


    func fetchAnalytics(completion: @escaping () -> Void) {
        let group = DispatchGroup()

        group.enter()
        FirebaseManager.shared.fetchAllUsers { result in
            if case .success(let users) = result {
                let regularUsers = users.filter { $0.role == .user }
                self.totalUsers = regularUsers.count
                self.genderStats = Dictionary(grouping: regularUsers, by: { $0.gender })
                    .mapValues { $0.count }
            }
            group.leave()
        }

        group.enter()
        FirebaseManager.shared.fetchHotels { result in
            if case .success(let hotels) = result {
                self.totalHotels = hotels.count
            }
            group.leave()
        }

        group.enter()
        FirebaseManager.shared.fetchAllReservations { reservations in
            self.totalReservations = reservations.count

            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            formatter.locale = Locale(identifier: "en_US_POSIX")

            let rawGrouped = Dictionary(grouping: reservations, by: { formatter.string(from: $0.reservation.reservedAt) })
            let rawCounts = rawGrouped.mapValues { $0.count }

            let monthOrder = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul",
                              "Aug", "Sep", "Oct", "Nov", "Dec"]

            self.monthlyReservations = monthOrder.reduce(into: [String: Int]()) { result, month in
                result[month] = rawCounts[month] ?? 0
            }

            self.orderedMonths = monthOrder

            group.leave()
        }

        group.notify(queue: .main) {
            completion()
        }
    }
}

