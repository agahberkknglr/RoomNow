//
//  Amenity.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 14.05.2025.
//

import UIKit

enum Amenity: String, CaseIterable {
    case pool = "swimming pool"
    case wifi = "free wifi"
    case room = "room service"
    case parking = "free parking"
    case laundry = "laundry service"
    case beach = "beach access"
    case privateBeach = "private beach"
    case breakfeast = "breakfast buffet"
    case paidBreakfeast = "paid breakfeast"
    case fitness = "fitness center"
    case spa = "spa"
    case bar = "bar"
    case barRoof = "rooftop bar"
    case kidsClub = "kids club"
    case tennis = "tennis court"
    case music = "live music"
    case airport = "airport shuttle"
    case tub = "hot tub"
    case pet = "pet friendly"
    case desk = "24 hour front desk"
    case roomDining = "in-room dining"
    case valet = "valet service"
    case restaurant = "restaurant"
    case smoke = "smoke free"
    
    
    var icon: UIImage? {
        switch self {
        case .pool: return UIImage(systemName: "figure.pool.swim")
        case .wifi: return UIImage(systemName: "wifi")
        case .room: return UIImage(systemName: "lamp.floor")
        case .parking: return UIImage(systemName: "parkingsign.circle")
        case .laundry: return UIImage(systemName: "washer")
        case .beach: return UIImage(systemName: "water.waves")
        case .privateBeach: return UIImage(systemName: "beach.umbrella")
        case .breakfeast: return UIImage(systemName: "fork.knife.circle")
        case .paidBreakfeast: return UIImage(systemName: "takeoutbag.and.cup.and.straw")
        case .fitness: return UIImage(systemName: "figure.run.circle")
        case .spa: return UIImage(systemName: "leaf.circle")
        case .bar: return UIImage(systemName: "cup.and.saucer")
        case .barRoof: return UIImage(systemName: "wineglass")
        case .kidsClub: return UIImage(systemName: "figure.child")
        case .tennis: return UIImage(systemName: "tennis.racket")
        case .music: return UIImage(systemName: "music.note")
        case .airport: return UIImage(systemName: "airplane")
        case .tub: return UIImage(systemName: "bathtub")
        case .pet: return UIImage(systemName: "pawprint")
        case .desk: return UIImage(systemName: "lamp.desk")
        case .roomDining: return UIImage(systemName: "birthday.cake")
        case .valet: return UIImage(systemName: "car")
        case .restaurant: return UIImage(systemName: "frying.pan")
        case .smoke: return UIImage(systemName: "nosign")
        }
    }
    
    var title: String {
        return self.rawValue.capitalized
    }
}

extension Amenity {
    static func from(string: String) -> Amenity? {
        return Amenity.allCases.first { $0.rawValue.lowercased() == string.lowercased() }
    }

}


