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
    private let priceLabel = UILabel()

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
        contentView.layer.borderColor = UIColor.systemGray5.cgColor
        contentView.clipsToBounds = true
        
        hotelImageView.contentMode = .scaleAspectFill
        hotelImageView.tintColor = .systemBlue
        hotelImageView.image = UIImage(systemName: "building.2") // system hotel image
        
        hotelNameLabel.font = .boldSystemFont(ofSize: 16)
        hotelNameLabel.numberOfLines = 2
        
        ratingLabel.font = .systemFont(ofSize: 14)
        ratingLabel.textColor = .systemGray
        
        priceLabel.font = .boldSystemFont(ofSize: 16)
        priceLabel.textColor = .systemGreen
        
        let stackView = UIStackView(arrangedSubviews: [hotelNameLabel, ratingLabel, priceLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        
        contentView.addSubview(hotelImageView)
        contentView.addSubview(stackView)
        
        hotelImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hotelImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            hotelImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            hotelImageView.widthAnchor.constraint(equalToConstant: 60),
            hotelImageView.heightAnchor.constraint(equalToConstant: 60),
            
            stackView.topAnchor.constraint(equalTo: hotelImageView.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with hotel: Hotel) {
        hotelNameLabel.text = hotel.name
        ratingLabel.text = "⭐️ \(hotel.rating)"
        
        let allRooms = hotel.roomTypes.flatMap { $0.rooms }
        if let minPrice = allRooms.map({ $0.price }).min() {
            priceLabel.text = "₺\(Int(minPrice))"
        } else {
            priceLabel.text = "-"
        }
    }
}
