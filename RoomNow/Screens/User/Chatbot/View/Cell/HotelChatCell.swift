//
//  HotelChatCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 27.05.2025.
//

import UIKit

final class HotelChatCell: UITableViewCell {
    
    private let avatarLabel = UILabel()
    private let bubbleView = UIView()
    private let stackView = UIStackView()
    private let nameLabel = UILabel()
    private let locationLabel = UILabel()
    private let priceLabel = UILabel()
    private let detailsButton = UIButton(type: .system)
    private let selectRoomButton = UIButton(type: .system)

    var onViewDetails: (() -> Void)?
    var onSelectRoom: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with hotel: Hotel, rooms: [Room], showAvatar: Bool, searchParams: HotelSearchParameters) {
        let vm = HotelCellVM(hotel: hotel, rooms: rooms, searchParams: searchParams)
        let nights = Calendar.current.dateComponents([.day], from: searchParams.checkInDate, to: searchParams.checkOutDate).day ?? 1
        let combo = vm.roomCombination
        let totalPrice = combo.reduce(0) { $0 + Int($1.price) * nights }

        if !combo.isEmpty {
            priceLabel.text = "💸 ₺\(totalPrice) total"
        } else {
            priceLabel.text = "💸 Not available"
        }
        nameLabel.text = "🏨 \(hotel.name)"
        locationLabel.text = "📍 \(hotel.city.capitalized), \(hotel.location)"
        avatarLabel.isHidden = !showAvatar
    }

    private func setupUI() {
        selectionStyle = .none
        contentView.backgroundColor = .appBackground
        
        avatarLabel.text = "🤖"
        avatarLabel.font = .systemFont(ofSize: 24)
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false

        bubbleView.backgroundColor = .appSecondaryBackground
        bubbleView.layer.cornerRadius = 16
        bubbleView.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = .boldSystemFont(ofSize: 15)
        locationLabel.font = .systemFont(ofSize: 14)
        priceLabel.font = .systemFont(ofSize: 14)

        detailsButton.applyPrimaryChatStyle(with: "View Details")
        selectRoomButton.applyPrimaryChatStyle(with: "Select Room")

        detailsButton.addTarget(self, action: #selector(viewTapped), for: .touchUpInside)
        selectRoomButton.addTarget(self, action: #selector(selectTapped), for: .touchUpInside)

        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false

        [nameLabel, locationLabel, priceLabel, detailsButton, selectRoomButton].forEach {
            stackView.addArrangedSubview($0)
        }

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

    @objc private func viewTapped() {
        onViewDetails?()
    }

    @objc private func selectTapped() {
        onSelectRoom?()
    }
}


