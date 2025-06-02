//
//  ProfileImageCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.05.2025.
//

import UIKit
import SDWebImage

final class ProfileImageCell: UITableViewCell {

    private let profileImageView = UIImageView()
    var onTapImage: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .appBackground

        profileImageView.image = UIImage(systemName: "person.circle")
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.tintColor = .appAccent
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 60
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.appAccent.cgColor
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        profileImageView.addGestureRecognizer(tap)
        
        contentView.addSubview(profileImageView)

        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            profileImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor)
        ])
    }

    func configure(with base64OrUrl: String?) {
        if let string = base64OrUrl {
            if let url = URL(string: string), string.starts(with: "http") {
                //URL
                profileImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.circle"))
            } else if let data = Data(base64Encoded: string), let image = UIImage(data: data) {
                //base64
                profileImageView.image = image
            } else {
                //Fallback
                profileImageView.image = UIImage(systemName: "person.circle")
            }
        } else {
            profileImageView.image = UIImage(systemName: "person.circle")
        }
    }
    
    @objc private func imageTapped() {
        onTapImage?()
    }
}
