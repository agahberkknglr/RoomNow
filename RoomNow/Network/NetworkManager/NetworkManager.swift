//
//  NetworkManager.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 27.05.2025.
//

import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    func sendChatMessage(_ message: String, completion: @escaping (Result<ParsedSearchData, Error>) -> Void) {
        guard let url = URL(string: "https://roomnow.app.n8n.cloud/webhook/chatbot-roomnow") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["message": message]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1)))
                return
            }

            do {
                let parsed = try JSONDecoder().decode(ParsedSearchData.self, from: data)
                completion(.success(parsed))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
