//
//  ReservationCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 15.06.2025.
//

import UIKit

final class ReservationCell: UITableViewCell {
    
    private let hotelLabel = UILabel()
    private let guestLabel = UILabel()
    private let dateLabel = UILabel()
    private let statusLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        hotelLabel.font = .boldSystemFont(ofSize: 16)
        guestLabel.font = .systemFont(ofSize: 14)
        dateLabel.font = .systemFont(ofSize: 13)
        statusLabel.font = .systemFont(ofSize: 13)
        statusLabel.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [hotelLabel, guestLabel, dateLabel, statusLabel])
        stack.axis = .vertical
        stack.spacing = 4

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    func configure(with reservation: Reservation) {
        hotelLabel.text = reservation.hotelName
        guestLabel.text = "Guest: \(reservation.fullName)"
        dateLabel.text = "Dates: \(reservation.checkInDate.toShortReadableFormat()) → \(reservation.checkOutDate.toShortReadableFormat())"
        statusLabel.text = "Status: \(reservation.status.rawValue.capitalized)"
    }

}

