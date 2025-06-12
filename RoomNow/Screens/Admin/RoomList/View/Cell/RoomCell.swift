//
//  RoomCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 13.06.2025.
//

import UIKit

final class RoomCell: UITableViewCell {
    static let reuseID = "RoomCell"

    private let typeLabel = UILabel()
    private let numberLabel = UILabel()
    private let bedLabel = UILabel()
    private let priceLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        numberLabel.font = .boldSystemFont(ofSize: 16)
        typeLabel.font = .systemFont(ofSize: 14)
        typeLabel.textColor = .appSecondaryText
        bedLabel.font = .systemFont(ofSize: 14)
        bedLabel.textColor = .appSecondaryText
        priceLabel.font = .systemFont(ofSize: 14)
        priceLabel.textColor = .appAccent

        let infoStack = UIStackView(arrangedSubviews: [numberLabel, typeLabel, bedLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 4

        let mainStack = UIStackView(arrangedSubviews: [infoStack, priceLabel])
        mainStack.axis = .horizontal
        mainStack.alignment = .top
        mainStack.spacing = 8
        mainStack.distribution = .equalSpacing

        contentView.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }

    func configure(with room: Room) {
        typeLabel.text = room.roomType
        numberLabel.text = "Room \(room.roomNumber)"
        bedLabel.text = "\(room.bedCapacity) beds"
        priceLabel.text = "₺\(Int(room.price))"
    }
}
