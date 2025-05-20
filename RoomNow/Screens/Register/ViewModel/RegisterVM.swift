//
//  RegisterVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 20.05.2025.
//

import Foundation

protocol RegisterVMProtocol {
    func register(email: String, password: String, completion: @escaping (String?) -> Void)
}

final class RegisterVM: RegisterVMProtocol {
    func register(email: String, password: String, completion: @escaping (String?) -> Void) {
        AuthManager.shared.register(email: email, password: password) { result in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error.localizedDescription)
            }
        }
    }
}
