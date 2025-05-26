//
//  BookingCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 25.05.2025.
//

import UIKit

final class BookingCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let priceLabel = UILabel()
    private let statusLabel = UILabel()
    private let hotelImageView = UIImageView()
    private let view: UIView = {
        let view = UIView()
        view.backgroundColor = .appSecondaryBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        contentView.backgroundColor = .appBackground
        
        hotelImageView.contentMode = .scaleAspectFill
        hotelImageView.clipsToBounds = true
        hotelImageView.layer.cornerRadius = 8
        hotelImageView.translatesAutoresizingMaskIntoConstraints = false
        hotelImageView.image = UIImage(named: "hotelph")

        titleLabel.applyCellTitleStyle()
        dateLabel.applyCellSubtitleStyle()
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.minimumScaleFactor = 0.8
        dateLabel.numberOfLines = 1
        priceLabel.applyCellSubtitleStyle()
        statusLabel.applyCellSecondSubtitleStyle()
        
        let midStack = UIStackView(arrangedSubviews: [dateLabel, priceLabel])
        midStack.axis = .horizontal
        midStack.spacing = 4

        let textStack = UIStackView(arrangedSubviews: [titleLabel, midStack, statusLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(view)
        view.addSubview(hotelImageView)
        view.addSubview(textStack)
        
        view.pinToEdges(of: contentView, withInsets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))

        NSLayoutConstraint.activate([
            hotelImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            hotelImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            hotelImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            hotelImageView.widthAnchor.constraint(equalToConstant: 100),
            hotelImageView.heightAnchor.constraint(equalToConstant: 80),

            textStack.leadingAnchor.constraint(equalTo: hotelImageView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    
    func configure(with reservation: Reservation) {
        titleLabel.text = reservation.hotelName
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        formatter.timeZone = TimeZone(identifier: "Europe/Istanbul")
        
        let checkIn = formatter.string(from: reservation.checkInDate)
        let checkOut = formatter.string(from: reservation.checkOutDate)
        dateLabel.text = "\(checkIn) - \(checkOut)"
        
        priceLabel.text = "₺\(reservation.totalPrice)"
        
        switch reservation.status {
        case .active:
            statusLabel.text = "Upcoming"
            statusLabel.textColor = .appSuccess

        case .completed:
            statusLabel.text = "Completed"
            statusLabel.textColor = .appSecondaryText

        case .cancelled:
            statusLabel.text = "Cancelled"
            statusLabel.textColor = .systemRed
        }
    }
}
