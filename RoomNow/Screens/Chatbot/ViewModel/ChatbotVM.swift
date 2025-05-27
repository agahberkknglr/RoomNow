//
//  ChatbotVM.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 27.05.2025.
//

import Foundation

enum ChatInputStep {
    case idle
    case askingName
    case askingEmail
    case askingPhone
    case askingNote
}

protocol ChatbotVMDelegate: AnyObject {
    func didReceiveSearchData(_ data: ParsedSearchData)
    func didReceiveHotelMessages(_ messages: [ChatMessage])
    func didFailWithError(_ error: Error)
}

final class ChatbotVM {
    
    weak var delegate: ChatbotVMDelegate?
    private(set) var messages: [(String, String)] = []
    private var messageHistory: [String] = []
    var inputStep: ChatInputStep = .idle
    
    var userInfo = UserReservationInfo()

    
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
    
    func fetchHotels(for data: ParsedSearchData) {
        let parameters = data.toHotelSearchParameters()
        
        FirebaseManager.shared.fetchHotels(searchParameters: parameters) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let hotelResults):
                    if hotelResults.isEmpty {
                        self?.delegate?.didReceiveHotelMessages([
                            ChatMessage(sender: .bot, text: "❌ No hotels found.", type: .text, payload: nil)
                        ])
                    } else {
                        let messages: [ChatMessage] = hotelResults.enumerated().map { (index, tuple) in
                            let hotel = tuple.hotel
                            let rooms = tuple.rooms
                            let price = Int(rooms.first?.price ?? 0)

                            let text = """
                            🏨 \(hotel.name.capitalized)
                            📍 \(hotel.city), \(hotel.location)
                            ₺\(price) / night
                            """

                            let wrapped = HotelWithRooms(hotel: hotel, rooms: rooms)
                            let isLast = index == hotelResults.count - 1

                            return ChatMessage(
                                sender: .bot,
                                text: text,
                                type: .hotelCard,
                                payload: wrapped,
                                showAvatar: isLast
                            )
                        }

                        self?.delegate?.didReceiveHotelMessages(messages)
                    }
                case .failure(let error):
                    self?.delegate?.didReceiveHotelMessages([
                        ChatMessage(sender: .bot, text: "❌ Failed to fetch hotels: \(error.localizedDescription)", type: .text, payload: nil)
                    ])
                }
            }
        }
    }


}

