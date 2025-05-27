//
//  ChatMessage.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 27.05.2025.
//

enum ChatSender {
    case user
    case bot
}

enum ChatMessageType {
    case text
    case summary
    case hotelCard
    case roomOption
    case bookingConfirm
}

struct ChatMessage {
    let sender: ChatSender
    let text: String
    let type: ChatMessageType
    let payload: Any?
    var showAvatar: Bool = true
    
    var isActionable: Bool {
        switch type {
        case .summary, .hotelCard, .roomOption, .bookingConfirm:
            return true
        case .text:
            return false
        }
    }
}
