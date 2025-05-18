//
//  RoomCardCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 18.05.2025.
//

import UIKit

final class RoomCardCell: UICollectionViewCell {

    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    private let priceLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .appSecondaryBackground
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true

        titleLabel.font = .boldSystemFont(ofSize: 14)
        descLabel.font = .systemFont(ofSize: 12)
        descLabel.textColor = .appSecondaryText
        descLabel.numberOfLines = 2
        priceLabel.font = .boldSystemFont(ofSize: 14)
        priceLabel.textColor = .appAccent

        let stack = UIStackView(arrangedSubviews: [titleLabel, descLabel, priceLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with room: HotelRoom) {
        titleLabel.text = "Room \(room.roomNumber) - \(room.bedCapacity) beds"
        descLabel.text = room.description
        priceLabel.text = "₺\(Int(room.price))"
    }
}
