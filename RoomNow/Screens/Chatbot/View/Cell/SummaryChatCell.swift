//
//  SummaryChatCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 27.05.2025.
//

import UIKit

final class SummaryChatCell: UITableViewCell {
    
    private let avatarLabel = UILabel()
    private let bubbleView = UIView()
    private let stackView = UIStackView()
    private let destinationLabel = UILabel()
    private let dateLabel = UILabel()
    private let guestRoomLabel = UILabel()
    private let searchButton = UIButton(type: .system)
    
    var onSearchTapped: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with data: ParsedSearchData, showAvatar: Bool) {
        destinationLabel.text = "🧭 \(data.destination.capitalized)"
        dateLabel.text = "🗓️ \(data.toShortReadableDate(from: data.checkIn)) → \(data.toShortReadableDate(from: data.checkOut))"
        guestRoomLabel.text = "🧍‍♂️ \(data.guestCount) guests, 🛏️ \(data.roomCount) room"
        avatarLabel.isHidden = !showAvatar
    }

    private func setupUI() {
        contentView.backgroundColor = .appBackground
        
        avatarLabel.text = "🤖"
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarLabel.font = .systemFont(ofSize: 24)

        bubbleView.backgroundColor = .appSecondaryBackground
        bubbleView.layer.cornerRadius = 16
        bubbleView.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false

        [destinationLabel, dateLabel, guestRoomLabel, searchButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview($0)
        }
        
        destinationLabel.font = .boldSystemFont(ofSize: 15)
        dateLabel.font = .systemFont(ofSize: 14)
        guestRoomLabel.font = .systemFont(ofSize: 14)

        searchButton.applyPrimaryStyle(with: "🔍 See Hotels" )
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)

        contentView.addSubview(avatarLabel)
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(stackView)

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

    @objc private func searchTapped() {
        onSearchTapped?()
    }
}
