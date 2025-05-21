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
    private let roomBedLabel = UILabel()
    private let infoLabel = UILabel()
    private let saveButton = UIButton()
    
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
        hotelNameLabel.textColor = .appPrimaryText
        hotelNameLabel.numberOfLines = 2
        
        ratingLabel.font = .systemFont(ofSize: 14)
        ratingLabel.textColor = .appPrimaryText
        
        locationLabel.font = .systemFont(ofSize: 14)
        locationLabel.textColor = .appPrimaryText
        
        priceLabel.font = .boldSystemFont(ofSize: 16)
        priceLabel.textColor = .appPrimaryText
        priceLabel.textAlignment = .right
        
        roomTypeLabel.textColor = .appPrimaryText
        roomTypeLabel.textAlignment = .right
        
        roomBedLabel.textColor = .appPrimaryText
        roomBedLabel.textAlignment = .right
        
        infoLabel.font = .systemFont(ofSize: 12)
        infoLabel.textAlignment = .right
        infoLabel.textColor = .appSecondaryText
        infoLabel.numberOfLines = 2
        
        
        saveButton.setImage(UIImage(systemName: "heart"), for: .normal)
        saveButton.tintColor = .appPrimaryText
        saveButton.isUserInteractionEnabled = true
        saveButton.setContentHuggingPriority(.required, for: .horizontal)
        saveButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [hotelNameLabel, ratingLabel, locationLabel, roomTypeLabel, roomBedLabel, priceLabel, infoLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        
        contentView.addSubview(hotelImageView)
        contentView.addSubview(stackView)
        contentView.addSubview(saveButton)
        
        hotelImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hotelImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            hotelImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 8),
            hotelImageView.widthAnchor.constraint(equalToConstant: 120),
            hotelImageView.heightAnchor.constraint(equalToConstant: 230),
            
            saveButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            saveButton.widthAnchor.constraint(equalToConstant: 24),
            saveButton.heightAnchor.constraint(equalToConstant: 24),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: hotelImageView.trailingAnchor, constant: 12),
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
           // let guests = String(repeating: "👤", count: cheapest.room.bedCapacity)
           // roomBedLabel.text = "\(guests)"
            priceLabel.text = "₺\(Int(cheapest.room.price))"
            
            let nights = Calendar.current.dateComponents([.day], from: searchParams.checkInDate, to: searchParams.checkOutDate).day ?? 1
            let perNightPrice = Int(cheapest.room.price)
            let totalPrice = perNightPrice * nights

            if nights > 1 {
                priceLabel.setMixedStyleText(
                    prefix: "\(nights) nights: ",
                    suffix: "₺\(totalPrice)",
                    prefixFont: .systemFont(ofSize: 12),
                    suffixFont: .boldSystemFont(ofSize: 16),
                    prefixColor: .appSecondaryText,
                    suffixColor: .appPrimaryText )}
            else {
                priceLabel.text = "₺\(perNightPrice)"
            }
            infoLabel.text = "No prepayment needed\nFree cancellation"
        }
    }
    
    @objc private func saveButtonTapped() {
        print("tapped")
    }
}
