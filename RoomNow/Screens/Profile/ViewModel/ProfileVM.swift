//
//  ProfileVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.04.2025.
//

import Foundation

protocol ProfileVMProtocol {
    var user: AppUser? { get }
    func fetchUser(completion: @escaping () -> Void)
    func logout(completion: @escaping (Result<Void, Error>) -> Void)
}

final class ProfileVM: ProfileVMProtocol {
    private(set) var user: AppUser?

    func fetchUser(completion: @escaping () -> Void) {
        AuthManager.shared.fetchUserData { [weak self] result in
            switch result {
            case .success(let user):
                self?.user = user
            case .failure(let error):
                print("Failed to fetch user: \(error.localizedDescription)")
            }
            completion()
        }
    }

    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        AuthManager.shared.logout(completion: completion)
    }
}
