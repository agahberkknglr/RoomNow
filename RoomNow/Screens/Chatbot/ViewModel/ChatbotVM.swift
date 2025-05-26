//
//  ChatbotVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 27.05.2025.
//

import Foundation

protocol ChatbotVMDelegate: AnyObject {
    func didReceiveSearchData(_ data: ParsedSearchData)
    func didFailWithError(_ error: Error)
}

final class ChatbotVM {
    
    weak var delegate: ChatbotVMDelegate?
    private(set) var messages: [(String, String)] = []

    func sendMessage(_ userMessage: String) {
        NetworkManager.shared.sendChatMessage(userMessage) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.messages.append((userMessage, "✅ Parsed"))
                    self?.delegate?.didReceiveSearchData(data)
                case .failure(let error):
                    self?.delegate?.didFailWithError(error)
                }
            }
        }
    }
}
