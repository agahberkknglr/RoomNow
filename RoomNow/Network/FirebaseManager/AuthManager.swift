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
    var currentAppUser: AppUser?
    
    func register(email: String, password: String, username: String, dateOfBirth: String, gender: String, profileImageBase64: String? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
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
                profileImageBase64: profileImageBase64,
                completion: completion
            )
        }
    }
    
    private func createUserDocument( for user: User, email: String, username: String, dateOfBirth: String, gender: String, profileImageBase64: String? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        
        var userData: [String: Any] = [
            "email": email,
            "username": username,
            "dateOfBirth": dateOfBirth,
            "gender": gender,
            "role": UserRole.user.rawValue,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        if let base64 = profileImageBase64 {
            userData["profileImageBase64"] = base64
        }

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
                self.fetchUserData { _ in }
                completion(.success(()))
            }
        }
    }

    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            self.currentAppUser = nil
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
    
    func observeAuthState(_ callback: @escaping (User?) -> Void) {
        Auth.auth().addStateDidChangeListener { _, user in
            callback(user)
        }
    }
    
    func fetchUserData(completion: @escaping (Result<AppUser, Error>) -> Void) {
        guard let uid = currentUser?.uid else {
            completion(.failure(NSError(domain: "No user ID", code: -1)))
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard var data = snapshot?.data() else {
                completion(.failure(NSError(domain: "No user data found", code: -1)))
                return
            }

            data["uid"] = uid
            data.removeValue(forKey: "createdAt")

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let user = try JSONDecoder().decode(AppUser.self, from: jsonData)
                self.currentAppUser = user
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func updateUserData(_ user: AppUser, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let uid = user.uid

        var userData: [String: Any] = [
            "username": user.username,
            "email": user.email,
            "dateOfBirth": user.dateOfBirth,
            "gender": user.gender
        ]

        if let base64 = user.profileImageBase64 {
            userData["profileImageBase64"] = base64
        }

        db.collection("users").document(uid).updateData(userData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                self.currentAppUser = user
                completion(.success(()))
            }
        }
    }

}
