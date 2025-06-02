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
    private let messageStack = UIStackView()
    private var confirmButton = UIButton()

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
        confirmButton.isHidden = true
        
        if message.sender == .user {
            avatarLabel.isHidden = true
            NSLayoutConstraint.deactivate(leftConstraints)
            NSLayoutConstraint.activate(rightConstraints)
            bubbleView.backgroundColor = .appSecondaryAccent
            messageLabel.textColor = .appPrimaryText
        } else {
            avatarLabel.text = "🤖"
            avatarLabel.isHidden = !message.showAvatar
            NSLayoutConstraint.deactivate(rightConstraints)
            NSLayoutConstraint.activate(leftConstraints)
            bubbleView.backgroundColor = .appSecondaryBackground
            messageLabel.textColor = .appPrimaryText
        }
    }
    
    func addConfirmationButton(title: String, action: @escaping () -> Void) {
        confirmButton.setTitle(title, for: .normal)
        confirmButton.isHidden = false
        confirmButton.removeTarget(nil, action: nil, for: .allEvents)
        confirmButton.addAction(UIAction { _ in action() }, for: .touchUpInside)
    }

    private func setupUI() {
        selectionStyle = .none
        contentView.backgroundColor = .appBackground
        
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarLabel.font = .systemFont(ofSize: 24)
        
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.layer.cornerRadius = 16
        bubbleView.layer.masksToBounds = true
        bubbleView.backgroundColor = .appSecondaryBackground

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = .systemFont(ofSize: 14)
        messageLabel.numberOfLines = 0
        
        confirmButton.applyPrimaryChatStyle(with: "Confirm Booking")
        confirmButton.isHidden = true

        messageStack.axis = .vertical
        messageStack.spacing = 8
        messageStack.translatesAutoresizingMaskIntoConstraints = false
        messageStack.addArrangedSubview(messageLabel)
        messageStack.addArrangedSubview(confirmButton)

        contentView.addSubview(avatarLabel)
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageStack)
        
        // Common constraints
        NSLayoutConstraint.activate([
            messageStack.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            messageStack.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
            messageStack.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageStack.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            
            bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            avatarLabel.widthAnchor.constraint(equalToConstant: 30),
            avatarLabel.heightAnchor.constraint(equalToConstant: 30),
            avatarLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8)
        ])
        
        // Bot (left) layout
        leftConstraints = [
            avatarLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            bubbleView.leadingAnchor.constraint(equalTo: avatarLabel.trailingAnchor, constant: 8)
        ]

        // User (right) layout
        rightConstraints = [
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ]
    }
}
