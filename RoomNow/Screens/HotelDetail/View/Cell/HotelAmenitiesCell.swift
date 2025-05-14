//
//  HotelAmenitiesCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 14.05.2025.
//

import UIKit

final class HotelAmenitiesCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let gridStack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .appBackground
        
        titleLabel.text = "Most Popular Facilities"
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .appPrimaryText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        gridStack.axis = .vertical
        gridStack.spacing = 12
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(gridStack)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            gridStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            gridStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            gridStack.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            gridStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    func configure(with amenities: [Amenity]) {
        gridStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let pairs = stride(from: 0, to: amenities.count, by: 2).map {
            Array(amenities[$0..<min($0 + 2, amenities.count)])
        }

        for pair in pairs {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 16
            rowStack.distribution = .fillEqually

            for amenity in pair {
                let iconView = UIImageView(image: amenity.icon)
                iconView.tintColor = .appAccent
                iconView.contentMode = .scaleAspectFit
                iconView.translatesAutoresizingMaskIntoConstraints = false
                iconView.widthAnchor.constraint(equalToConstant: 20).isActive = true
                iconView.heightAnchor.constraint(equalToConstant: 20).isActive = true

                let label = UILabel()
                label.text = amenity.title
                label.font = .systemFont(ofSize: 15)
                label.textColor = .appPrimaryText
                label.numberOfLines = 0

                let itemStack = UIStackView(arrangedSubviews: [iconView, label])
                itemStack.axis = .horizontal
                itemStack.spacing = 8
                itemStack.alignment = .center

                rowStack.addArrangedSubview(itemStack)
            }

            gridStack.addArrangedSubview(rowStack)
        }
    }
}


