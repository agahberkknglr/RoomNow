//
//  LoginVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.04.2025.
//

import Foundation

protocol LoginVMProtocol {
    func login(email: String, password: String, completion: @escaping (String?) -> Void)
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void)
}

final class LoginVM: LoginVMProtocol {

    func login(email: String, password: String, completion: @escaping (String?) -> Void) {
        AuthManager.shared.login(email: email, password: password) { result in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        AuthManager.shared.sendPasswordReset(email: email, completion: completion)
    }
}
