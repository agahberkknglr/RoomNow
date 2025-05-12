//
//  DateVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 12.05.2025.
//

import Foundation

protocol DateVMProtocol: AnyObject {
    var selectedDates: [Date] { get }
    var selectedStartDate: Date? { get }
    var selectedEndDate: Date? { get }

    func preselectDates(start: Date?, end: Date?)
    func selectDate(_ date: Date) -> [Date]
}

final class DateVM: DateVMProtocol {
    private(set) var selectedDates: [Date] = []

    var selectedStartDate: Date? {
        selectedDates.sorted().first
    }

    var selectedEndDate: Date? {
        selectedDates.sorted().last
    }

    func preselectDates(start: Date?, end: Date?) {
        selectedDates = []
        if let start = start { selectedDates.append(start) }
        if let end = end { selectedDates.append(end) }
    }

    func selectDate(_ date: Date) -> [Date] {
        let istanbulTimeZone = TimeZone(identifier: "Europe/Istanbul")!
        var components = Calendar.current.dateComponents(in: istanbulTimeZone, from: date)
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.timeZone = istanbulTimeZone

        guard let normalizedDate = Calendar.current.date(from: components) else {
            return selectedDates
        }

        if selectedDates.count == 2 {
            selectedDates.removeAll()
        }

        if selectedDates.contains(normalizedDate) {
            selectedDates.removeAll(where: { $0 == normalizedDate })
        } else {
            selectedDates.append(normalizedDate)
        }

        selectedDates = Array(Set(selectedDates)).sorted()
        return selectedDates
    }
}
