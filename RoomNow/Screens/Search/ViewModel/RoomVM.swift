//
//  RoomVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 12.05.2025.
//

import Foundation

protocol RoomVMProtocol: AnyObject {
    var numberOfRooms: Int { get }
    var numberOfAdults: Int { get }
    var numberOfChildren: Int { get }
    var isPetSelected: Bool { get }

    func setRooms(_ value: Int)
    func setAdults(_ value: Int)
    func setChildren(_ value: Int)
    func setPetSelected(_ value: Bool)
}

final class RoomVM: RoomVMProtocol {
    private(set) var numberOfRooms: Int
    private(set) var numberOfAdults: Int
    private(set) var numberOfChildren: Int
    private(set) var isPetSelected: Bool = false

    init(rooms: Int = 1, adults: Int = 2, children: Int = 0) {
        self.numberOfRooms = rooms
        self.numberOfAdults = adults
        self.numberOfChildren = children
    }

    func setRooms(_ value: Int) {
        numberOfRooms = max(1, value)
    }

    func setAdults(_ value: Int) {
        numberOfAdults = max(1, value)
    }

    func setChildren(_ value: Int) {
        numberOfChildren = max(0, value)
    }

    func setPetSelected(_ value: Bool) {
        isPetSelected = value
    }
}

