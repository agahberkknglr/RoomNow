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
    private let cardView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(cardView)
        cardView.layer.borderColor = UIColor.systemPink.cgColor
        cardView.layer.cornerRadius = 10
        cardView.clipsToBounds = true
        cardView.pinToEdges(of: contentView)
        cardView.backgroundColor = .appSecondaryBackground

        titleLabel.font = .boldSystemFont(ofSize: 14)
        descLabel.font = .systemFont(ofSize: 12)
        descLabel.textColor = .appSecondaryText
        descLabel.numberOfLines = 2
        priceLabel.font = .boldSystemFont(ofSize: 14)
        priceLabel.textColor = .appAccent

        let stack = UIStackView(arrangedSubviews: [titleLabel, descLabel, priceLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(stack)
        stack.pinToEdges(of: cardView, withInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
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
