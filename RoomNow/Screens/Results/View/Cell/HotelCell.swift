//
//  HotelCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.04.2025.
//

import UIKit

final class HotelCell: UICollectionViewCell {
    
    static let identifier = "HotelCell"
    
    private let hotelImageView = UIImageView()
    private let hotelNameLabel = UILabel()
    private let ratingLabel = UILabel()
    private let locationLabel = UILabel()
    private let priceLabel = UILabel()
    private let roomTypeLabel = UILabel()
    private let infoLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.clipsToBounds = true
        
        hotelImageView.contentMode = .scaleAspectFill
        hotelImageView.image = UIImage(named: "hotelph") // system hotel image
        hotelImageView.layer.cornerRadius = 12
        hotelImageView.clipsToBounds = true
        
        hotelNameLabel.font = .boldSystemFont(ofSize: 18)
        hotelNameLabel.numberOfLines = 2
        
        ratingLabel.font = .systemFont(ofSize: 14)
        ratingLabel.textColor = .white
        
        locationLabel.font = .systemFont(ofSize: 14)
        locationLabel.textColor = .white
        
        priceLabel.font = .boldSystemFont(ofSize: 16)
        priceLabel.textColor = .white
        priceLabel.textAlignment = .right
        
        roomTypeLabel.textColor = .white
        roomTypeLabel.textAlignment = .right
        
        infoLabel.font = .systemFont(ofSize: 14)
        infoLabel.textColor = .white
        infoLabel.textAlignment = .right
        
        let stackView = UIStackView(arrangedSubviews: [hotelNameLabel, ratingLabel, locationLabel, roomTypeLabel, priceLabel, infoLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        
        contentView.addSubview(hotelImageView)
        contentView.addSubview(stackView)
        
        hotelImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hotelImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            hotelImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 8),
            hotelImageView.widthAnchor.constraint(equalToConstant: 120),
            hotelImageView.heightAnchor.constraint(equalToConstant: 230),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: hotelImageView.trailingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with hotel: Hotel, searchParams: HotelSearchParameters) {
        hotelNameLabel.text = hotel.name
        ratingLabel.text = "⭐️ \(hotel.rating)"
        locationLabel.text = "📍 \(hotel.location)"
        
        let availableRooms = hotel.roomTypes.flatMap { type in
            type.rooms.map { room in (typeName: type.typeName, room: room) }
        }.filter {
            $0.room.bedCapacity >= searchParams.guestCount &&
            $0.room.isAvailable(for: searchParams.checkInDate, checkOut: searchParams.checkOutDate)
        }
        
        
        if let cheapest = availableRooms.min(by: { $0.room.price < $1.room.price }) {
            let baseText = "Hotel room: "
            let typeNameText = cheapest.typeName.capitalized
            let fullText = baseText + typeNameText
            let attributedString = NSMutableAttributedString(string: fullText)
            
            attributedString.addAttribute(.font,
                                          value: UIFont.boldSystemFont(ofSize: 14),
                                          range: NSRange(location: 0, length: baseText.count))
            
            attributedString.addAttribute(.font,
                                          value: UIFont.systemFont(ofSize: 14),
                                          range: NSRange(location: baseText.count, length: typeNameText.count))
            
            roomTypeLabel.attributedText = attributedString
            priceLabel.text = "₺\(Int(cheapest.room.price))"
            infoLabel.text = "No prepayment needed"
        }
    }
}
