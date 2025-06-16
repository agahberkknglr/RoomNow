//
//  UserFilter.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 16.06.2025.
//

enum SortOption: Hashable {
    case nameAsc
    case nameDesc
}

struct UserFilter {
    var searchText: String?
    var genders: Set<String> = []
    var sortOption: SortOption?
}
