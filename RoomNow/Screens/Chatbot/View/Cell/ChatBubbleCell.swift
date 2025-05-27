//
//  ChatBubbleCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 27.05.2025.
//

import UIKit

final class ChatBubbleCell: UITableViewCell {
    
    private let avatarLabel = UILabel()
    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    
    private var leftConstraints: [NSLayoutConstraint] = []
    private var rightConstraints: [NSLayoutConstraint] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with message: ChatMessage) {
        messageLabel.text = message.text
        avatarLabel.text = message.sender == .user ? "🧍" : "🤖"
        avatarLabel.isHidden = !message.showAvatar 
        
        if message.sender == .user {
            NSLayoutConstraint.deactivate(leftConstraints)
            NSLayoutConstraint.activate(rightConstraints)
            bubbleView.backgroundColor = .systemBlue
            messageLabel.textColor = .white
        } else {
            NSLayoutConstraint.deactivate(rightConstraints)
            NSLayoutConstraint.activate(leftConstraints)
            bubbleView.backgroundColor = .systemGray5
            messageLabel.textColor = .label
        }
    }

    private func setupUI() {
        selectionStyle = .none
        
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarLabel.font = .systemFont(ofSize: 24)
        
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.layer.cornerRadius = 16
        bubbleView.layer.masksToBounds = true
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = .systemFont(ofSize: 15)
        messageLabel.numberOfLines = 0

        contentView.addSubview(avatarLabel)
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        
        // Common constraints
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            
            bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: 260),
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            avatarLabel.widthAnchor.constraint(equalToConstant: 30),
            avatarLabel.heightAnchor.constraint(equalToConstant: 30),
            avatarLabel.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor)
        ])
        
        // Bot (left) layout
        leftConstraints = [
            avatarLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            bubbleView.leadingAnchor.constraint(equalTo: avatarLabel.trailingAnchor, constant: 8)
        ]

        // User (right) layout
        rightConstraints = [
            avatarLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            bubbleView.trailingAnchor.constraint(equalTo: avatarLabel.leadingAnchor, constant: -8)
        ]
    }
}
