//
//  AdminHotelCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 9.06.2025.
//

import UIKit

final class AdminHotelCell: UITableViewCell {

    private let hotelImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let ratingLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        hotelImageView.contentMode = .scaleAspectFill
        hotelImageView.layer.cornerRadius = 8
        hotelImageView.clipsToBounds = true

        titleLabel.font = .boldSystemFont(ofSize: 16)
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        ratingLabel.font = .systemFont(ofSize: 14)
        ratingLabel.textColor = .systemYellow

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, ratingLabel])
        stack.axis = .vertical
        stack.spacing = 4

        let container = UIStackView(arrangedSubviews: [hotelImageView, stack])
        container.axis = .horizontal
        container.spacing = 12
        container.alignment = .center

        contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        hotelImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hotelImageView.widthAnchor.constraint(equalToConstant: 60),
            hotelImageView.heightAnchor.constraint(equalToConstant: 60),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with hotel: Hotel) {
        titleLabel.text = hotel.name
        subtitleLabel.text = hotel.city.capitalized
        ratingLabel.text = "★ \(hotel.rating)"
        if let firstImageUrlString = hotel.imageUrls.first,
           let url = URL(string: firstImageUrlString) {
            hotelImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "building.2.fill"))
        } else {
            hotelImageView.image = UIImage(systemName: "building.2.fill")
        }
    }
}
