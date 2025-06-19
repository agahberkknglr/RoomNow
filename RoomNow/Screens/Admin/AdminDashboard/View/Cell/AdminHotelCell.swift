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
    private let starStack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        contentView.backgroundColor = .appBackground

        hotelImageView.contentMode = .scaleAspectFill
        hotelImageView.layer.cornerRadius = 8
        hotelImageView.clipsToBounds = true

        titleLabel.font = .boldSystemFont(ofSize: 16)
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel

        starStack.axis = .horizontal
        starStack.spacing = 1
        starStack.alignment = .center
        starStack.distribution = .fill
        
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let ratStack = UIStackView(arrangedSubviews: [starStack, spacer])
        ratStack.axis = .horizontal
        ratStack.spacing = 4

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, ratStack])
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
        starStack.setStars(from: hotel.rating)
        hotelImageView.setImage(fromBase64: hotel.imageUrls.first)
    }
}
