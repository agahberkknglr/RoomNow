//
//  RoomChatCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 27.05.2025.
//

import UIKit

final class RoomChatCell: UITableViewCell {

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

    func configure(with room: Room) {
        typeLabel.text = "🛏 \(room.roomNumber)"
        bedLabel.text = "👥 Sleeps \(room.bedCapacity)"
        priceLabel.text = "💸 ₺\(Int(room.price)) per night"
    }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [typeLabel, bedLabel, priceLabel, selectButton])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = UIColor.systemGray6

        selectButton.setTitle("✅ Select Room", for: .normal)
        selectButton.addTarget(self, action: #selector(selectTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    @objc private func selectTapped() {
        onSelectTapped?()
    }

    static var reuseIdentifier: String {
        return "RoomChatCell"
    }
}
