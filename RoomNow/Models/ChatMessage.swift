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

struct ChatMessage {
    let sender: ChatSender
    let text: String
}
