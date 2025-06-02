//
//  SavedHotelCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 22.05.2025.
//

import UIKit
import SDWebImage

final class SavedHotelCell: UICollectionViewCell {

    private let nameLabel = UILabel()
    private let cityLabel = UILabel()
    private let dateLabel = UILabel()
    private let guestLabel = UILabel()
    private let roomLabel = UILabel()
    private let priceLabel = UILabel()
    private let imageView = UIImageView()
    private let saveButton = UIButton()
    
    private let cityImage = UIImageView()
    private let dateImage = UIImageView()
    private let roomImage = UIImageView()
    private let guestImage = UIImageView()
    private let nightImage = UIImageView()
    
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
        contentView.clipsToBounds = true
        contentView.backgroundColor = .appSecondaryBackground

        nameLabel.font = .boldSystemFont(ofSize: 18)
        nameLabel.textColor = .appPrimaryText
        nameLabel.numberOfLines = 2

        cityLabel.font = .systemFont(ofSize: 14)
        cityLabel.textColor = .appPrimaryText
        
        cityImage.image = UIImage(systemName: "mappin")
        cityImage.contentMode = .scaleAspectFit
        cityImage.tintColor = .appAccent

        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .appPrimaryText
        
        dateImage.image = UIImage(systemName: "calendar")
        dateImage.contentMode = .scaleAspectFit
        dateImage.tintColor = .appAccent
        
        guestLabel.font = .systemFont(ofSize: 14)
        guestLabel.textColor = .appPrimaryText
        
        guestImage.image = UIImage(systemName: "person.crop.circle")
        guestImage.contentMode = .scaleAspectFit
        guestImage.tintColor = .appAccent
        
        roomLabel.font = .systemFont(ofSize: 14)
        roomLabel.textColor = .appPrimaryText
        
        roomImage.image = UIImage(systemName: "bed.double.fill")
        roomImage.contentMode = .scaleAspectFit
        roomImage.tintColor = .appAccent
        
        priceLabel.font = .systemFont(ofSize: 14)
        priceLabel.textColor = .appPrimaryText
        
        nightImage.image = UIImage(systemName: "moon.stars")
        nightImage.contentMode = .scaleAspectFit
        nightImage.tintColor = .appAccent

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        
        saveButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        saveButton.tintColor = .appAccent
        saveButton.isUserInteractionEnabled = true
        saveButton.setContentHuggingPriority(.required, for: .horizontal)
        saveButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        let cityStack = UIStackView(arrangedSubviews: [cityImage, cityLabel])
        cityStack.axis = .horizontal
        cityStack.spacing = 4
        
        let dateStack = UIStackView(arrangedSubviews: [dateImage, dateLabel])
        dateStack.axis = .horizontal
        dateStack.spacing = 4
        
        let roomStack = UIStackView(arrangedSubviews: [roomImage, roomLabel])
        roomStack.axis = .horizontal
        roomStack.spacing = 4
        
        let guestStack = UIStackView(arrangedSubviews: [guestImage, guestLabel])
        guestStack.axis = .horizontal
        guestStack.spacing = 4
        
        let nightStack = UIStackView(arrangedSubviews: [nightImage, priceLabel])
        nightStack.axis = .horizontal
        nightStack.spacing = 4

        let stackView = UIStackView(arrangedSubviews: [nameLabel, cityStack, dateStack, roomStack, guestStack, nightStack])
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
            
            cityImage.widthAnchor.constraint(equalToConstant: 24),
            cityImage.heightAnchor.constraint(equalToConstant: 24),
            dateImage.widthAnchor.constraint(equalToConstant: 24),
            dateImage.heightAnchor.constraint(equalToConstant: 24),
            roomImage.widthAnchor.constraint(equalToConstant: 24),
            roomImage.heightAnchor.constraint(equalToConstant: 24),
            guestImage.widthAnchor.constraint(equalToConstant: 24),
            guestImage.heightAnchor.constraint(equalToConstant: 24),
            nightImage.widthAnchor.constraint(equalToConstant: 24),
            nightImage.heightAnchor.constraint(equalToConstant: 24),
            
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
        cityLabel.text = "\(saved.city.capitalized), \(saved.location)"
        
        if let url = URL(string: saved.imageUrl) {
            imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        } else {
            imageView.image = UIImage(named: "placeholder")
        }
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
