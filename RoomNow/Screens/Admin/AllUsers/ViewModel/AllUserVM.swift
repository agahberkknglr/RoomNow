//
//  AllUserVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 16.06.2025.
//

import Foundation

protocol AllUsersVMProtocol {
    var users: [AppUser] { get }
    var filteredUsers: [AppUser] { get }
    func fetchUsers(completion: @escaping () -> Void)
    func applyFilter(_ filter: UserFilter)
}

final class AllUsersVM: AllUsersVMProtocol {
    private(set) var users: [AppUser] = []
    private(set) var filteredUsers: [AppUser] = []
    var currentFilter: UserFilter = UserFilter()

    func fetchUsers(completion: @escaping () -> Void) {
        FirebaseManager.shared.fetchAllUsers { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    let userOnly = users.filter { $0.role != .admin }
                    self?.users = userOnly
                    self?.filteredUsers = userOnly
                case .failure(let error):
                    print("Failed to fetch users:", error)
                }
                completion()
            }
        }
    }

    func applyFilter(_ filter: UserFilter) {
        self.currentFilter = filter

        filteredUsers = users.filter { user in
            let matchesSearchText: Bool
            if let searchText = filter.searchText?.lowercased(), !searchText.isEmpty {
                matchesSearchText = user.username.lowercased().contains(searchText) ||
                                    user.email.lowercased().contains(searchText)
            } else {
                matchesSearchText = true
            }

            let matchesGender: Bool
            if !filter.genders.isEmpty {
                matchesGender = filter.genders.contains { selectedGender in
                    user.gender.caseInsensitiveCompare(selectedGender) == .orderedSame
                }
            } else {
                matchesGender = true
            }

            return matchesSearchText && matchesGender
        }

        if let sort = filter.sortOption {
            switch sort {
            case .nameAsc:
                filteredUsers.sort { $0.username.lowercased() < $1.username.lowercased() }
            case .nameDesc:
                filteredUsers.sort { $0.username.lowercased() > $1.username.lowercased() }
            }
        }
    }
}

