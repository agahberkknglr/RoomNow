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
    private var messageHistory: [String] = []
    
    func sendMessage(_ userMessage: String) {
        messages.append((userMessage, "⏳"))
        messageHistory.append("User: \(userMessage)")
        
        let fullConversation = messageHistory.joined(separator: "\n")
        
        NetworkManager.shared.sendChatMessage(fullConversation) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let lastIndex = self?.messages.indices.last {
                        self?.messages[lastIndex].1 = "Parsed"
                    }
                    self?.delegate?.didReceiveSearchData(data)

                case .failure(let error):
                    if let lastIndex = self?.messages.indices.last {
                        self?.messages[lastIndex].1 = "Error"
                    }
                    self?.delegate?.didFailWithError(error)
                }
            }
        }
    }
}

