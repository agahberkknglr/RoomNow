//
//  RoomChatCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 27.05.2025.
//

import UIKit

final class RoomChatCell: UITableViewCell {

    private let avatarLabel = UILabel()
    private let bubbleView = UIView()
    private let stackView = UIStackView()
    private let typeLabel = UILabel()
    private let bedLabel = UILabel()
    private let priceLabel = UILabel()
    private let selectButton = UIButton(type: .system)

    var onSelectTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with room: Room, showAvatar: Bool) {
        typeLabel.text = "🛏 Room \(room.roomNumber)"
        bedLabel.text = "👥 Sleeps \(room.bedCapacity)"
        priceLabel.text = "💸 ₺\(Int(room.price)) per night"
        avatarLabel.isHidden = !showAvatar
        print("room \(typeLabel.text ?? ""): \(showAvatar)")
    }

    private func setupUI() {
        selectionStyle = .none

        avatarLabel.text = "🤖"
        avatarLabel.font = .systemFont(ofSize: 24)
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false

        bubbleView.backgroundColor = .systemGray5
        bubbleView.layer.cornerRadius = 16
        bubbleView.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false

        [typeLabel, bedLabel, priceLabel, selectButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview($0)
        }

        selectButton.setTitle("✅ Select Room", for: .normal)
        selectButton.addTarget(self, action: #selector(selectTapped), for: .touchUpInside)

        bubbleView.addSubview(stackView)
        contentView.addSubview(avatarLabel)
        contentView.addSubview(bubbleView)

        NSLayoutConstraint.activate([
            avatarLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            avatarLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            avatarLabel.widthAnchor.constraint(equalToConstant: 30),
            avatarLabel.heightAnchor.constraint(equalToConstant: 30),

            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.leadingAnchor.constraint(equalTo: avatarLabel.trailingAnchor, constant: 8),
            bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            stackView.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12)
        ])
    }

    @objc private func selectTapped() {
        onSelectTapped?()
    }

    static var reuseIdentifier: String {
        return "RoomChatCell"
    }
}
