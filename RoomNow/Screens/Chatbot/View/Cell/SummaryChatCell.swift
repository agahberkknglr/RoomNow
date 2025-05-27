//
//  SummaryChatCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 27.05.2025.
//

import UIKit

final class SummaryChatCell: UITableViewCell {
    
    private let container = UIStackView()
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

    func configure(with data: ParsedSearchData) {
        destinationLabel.text = "🧭 \(data.destination)"
        dateLabel.text = "🗓️ \(data.checkIn) → \(data.checkOut)"
        guestRoomLabel.text = "🧍‍♂️ \(data.guestCount) guest\(data.guestCount > 1 ? "s" : ""), 🛏️ \(data.roomCount) room"
    }

    private func setupUI() {
        container.axis = .vertical
        container.spacing = 4
        container.translatesAutoresizingMaskIntoConstraints = false

        searchButton.setTitle("🔍 See Hotels", for: .normal)
        searchButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)

        [destinationLabel, dateLabel, guestRoomLabel, searchButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            container.addArrangedSubview($0)
        }

        contentView.addSubview(container)
        contentView.layer.cornerRadius = 8
        contentView.backgroundColor = UIColor.systemGray6

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    @objc private func searchTapped() {
        onSearchTapped?()
    }
}
