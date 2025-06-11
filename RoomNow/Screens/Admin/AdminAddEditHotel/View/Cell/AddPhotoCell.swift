//
//  AddPhotoCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 11.06.2025.
//

import UIKit

final class AddPhotoCell: UICollectionViewCell {
    let addIcon = UIImageView(image: UIImage(systemName: "plus"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        addIcon.contentMode = .center
        addIcon.tintColor = .systemGray
        addIcon.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.layer.cornerRadius = 8
        contentView.addSubview(addIcon)

        NSLayoutConstraint.activate([
            addIcon.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            addIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            addIcon.widthAnchor.constraint(equalToConstant: 24),
            addIcon.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
