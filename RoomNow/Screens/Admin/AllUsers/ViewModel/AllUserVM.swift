//
//  AllUserVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 16.06.2025.
//

import Foundation

protocol AllUsersVMProtocol {
    var users: [AppUser] { get }
    func fetchUsers(completion: @escaping () -> Void)
}

final class AllUsersVM: AllUsersVMProtocol {
    private(set) var users: [AppUser] = []

    func fetchUsers(completion: @escaping () -> Void) {
        FirebaseManager.shared.fetchAllUsers { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self?.users = users.filter { $0.role != .admin }
                case .failure(let error):
                    print("Failed to fetch users:", error)
                }
                completion()
            }
        }
    }


}
