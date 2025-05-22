//
//  SavedHotelCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 22.05.2025.
//

import UIKit

final class SavedHotelCell: UICollectionViewCell {

    private let nameLabel = UILabel()
    private let cityLabel = UILabel()
    private let dateLabel = UILabel()
    private let guestLabel = UILabel()
    private let roomLabel = UILabel()
    private let priceLabel = UILabel()
    private let imageView = UIImageView()
    private let saveButton = UIButton()
        
    var onSaveTapped: (() -> Void)?

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
        contentView.layer.borderColor = UIColor.appDivider.cgColor
        contentView.clipsToBounds = true
        contentView.backgroundColor = .appBackground

        nameLabel.font = .boldSystemFont(ofSize: 18)
        nameLabel.textColor = .appPrimaryText
        nameLabel.numberOfLines = 2

        cityLabel.font = .systemFont(ofSize: 14)
        cityLabel.textColor = .appPrimaryText

        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .appPrimaryText
        
        guestLabel.font = .systemFont(ofSize: 14)
        guestLabel.textColor = .appPrimaryText
        
        roomLabel.font = .systemFont(ofSize: 14)
        roomLabel.textColor = .appPrimaryText
        
        priceLabel.font = .systemFont(ofSize: 14)
        priceLabel.textColor = .appPrimaryText

        imageView.image = UIImage(named: "hotelph")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        
        saveButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        saveButton.tintColor = .appAccent
        saveButton.isUserInteractionEnabled = true
        saveButton.setContentHuggingPriority(.required, for: .horizontal)
        saveButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [nameLabel, cityLabel, dateLabel, roomLabel, guestLabel, priceLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        contentView.addSubview(stackView)
        contentView.addSubview(imageView)
        contentView.addSubview(saveButton)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 8),
            imageView.widthAnchor.constraint(equalToConstant: 120),
            imageView.heightAnchor.constraint(equalToConstant: 180),
            
            saveButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            saveButton.widthAnchor.constraint(equalToConstant: 24),
            saveButton.heightAnchor.constraint(equalToConstant: 24),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])

    }

    func configure(with saved: SavedHotel) {
        nameLabel.text = saved.hotelName
        roomLabel.text = "\(saved.roomCount) \(saved.roomCount == 1 ? "room" : "rooms")"
        guestLabel.text = "\(saved.guestCount) \(saved.guestCount == 1 ? "guest" : "guests")"
        priceLabel.text = "\(saved.numberOfNights) nights: ₺\(saved.totalPrice)"
        cityLabel.text = "\(saved.city.capitalized) – \(saved.location)"

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let checkIn = formatter.string(from: saved.checkInDate)
        let checkOut = formatter.string(from: saved.checkOutDate)
        dateLabel.text = "\(checkIn) → \(checkOut)"
    }
    
    @objc private func saveButtonTapped() {
        onSaveTapped?()
    }

}
