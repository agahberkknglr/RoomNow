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
        guard let url = URL(string: "https://roomnow.app.n8n.cloud/webhook/chatbot-roomnow-v2") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        print("🔗 URL used:", url.absoluteString)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["message": message]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ Request error:", error)
                completion(.failure(error))
                return
            }

            guard let data = data, !data.isEmpty else {
                print("❌ Received empty response from chatbot.")
                completion(.failure(NSError(domain: "Empty JSON response", code: -2)))
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON string from chatbot:\n", jsonString)
            }

            do {
                let result = try JSONDecoder().decode(ParsedSearchData.self, from: data)
                completion(.success(result))
            } catch {
                let raw = String(data: data, encoding: .utf8) ?? "No body"
                print(" Decoding error: \(error)\n🧪 Raw response: \(raw)")
                completion(.failure(error))
            }
        }.resume()
    }
}
