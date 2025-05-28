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
    func setDateOfBirth(_ dob: String)
    func setUser(_ user: AppUser)
    func updateUser(_ user: AppUser, completion: @escaping (Result<Void, Error>) -> Void)
    func setProfileImage(base64: String)
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
    
    func setDateOfBirth(_ dob: String) {
        user?.dateOfBirth = dob
    }
    
    func setUser(_ user: AppUser) {
        self.user = user
    }

    func updateUser(_ user: AppUser, completion: @escaping (Result<Void, Error>) -> Void) {
        AuthManager.shared.updateUserData(user, completion: completion)
    }
    
    func setProfileImage(base64: String) {
        user?.profileImageBase64 = base64
    }
}
