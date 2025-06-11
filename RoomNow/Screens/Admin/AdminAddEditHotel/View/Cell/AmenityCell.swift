//
//  AmenityCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 11.06.2025.
//

import UIKit

final class AmenityCell: UICollectionViewCell {
    let iconView = UIImageView()
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.backgroundColor = .systemBackground

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .label

        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2

        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func configure(with amenity: Amenity, selected: Bool) {
        iconView.image = amenity.icon
        titleLabel.text = amenity.title
        contentView.layer.borderColor = selected ? UIColor.systemBlue.cgColor : UIColor.systemGray4.cgColor
        contentView.backgroundColor = selected ? UIColor.systemBlue.withAlphaComponent(0.1) : .systemBackground
    }
}

