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
    case hotel
    case summary
}

struct ChatMessage {
    let sender: ChatSender
    let text: String
    let type: ChatMessageType
    let payload: Any?
    
    var isActionable: Bool {
        return type == .summary || type == .hotel
    }
}
