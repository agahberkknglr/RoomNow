//
//  AuthManager.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 20.05.2025.
//

import FirebaseAuth
import FirebaseFirestore

final class AuthManager {
    static let shared = AuthManager()

    private init() {}
    
    var currentUser: User? {
        return Auth.auth().currentUser
    }

    func register(email: String, password: String, username: String, dateOfBirth: String, gender: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user returned"])))
                return
            }

            self.createUserDocument(
                for: user,
                email: email,
                username: username,
                dateOfBirth: dateOfBirth,
                gender: gender,
                completion: completion
            )
        }
    }
    
    private func createUserDocument(for user: User, email: String, username: String, dateOfBirth: String, gender: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "email": email,
            "username": username,
            "dateOfBirth": dateOfBirth,
            "gender": gender,
            "createdAt": FieldValue.serverTimestamp()
        ]

        db.collection("users").document(user.uid).setData(userData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func sendPasswordReset(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

