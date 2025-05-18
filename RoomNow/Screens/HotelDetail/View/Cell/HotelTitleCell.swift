//
//  HotelTitleCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 13.05.2025.
//

import UIKit

final class HotelTitleCell: UITableViewCell {
    
    private let view = UIView()
    private let nameLabel = UILabel()
    private let locationLabel = UILabel()
    private let ratingLabel = UILabel()

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
        contentView.addSubview(view)
        view.pinToEdges(of: contentView, withInsets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        view.backgroundColor = .clear
        
        let vstack = UIStackView(arrangedSubviews: [nameLabel, locationLabel])
        vstack.axis = .vertical
        vstack.spacing = 4
        vstack.translatesAutoresizingMaskIntoConstraints = false
        
        let hstack = UIStackView(arrangedSubviews: [vstack, ratingLabel])
        hstack.axis = .horizontal
        hstack.spacing = 4
        hstack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hstack)

        hstack.pinToEdges(of: view, withInsets: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8))

        nameLabel.font = .boldSystemFont(ofSize: 20)
        nameLabel.textColor = .appPrimaryText
        nameLabel.numberOfLines = 2
        locationLabel.textColor = .appSecondaryText
        ratingLabel.textColor = .systemYellow
        ratingLabel.textAlignment = .right
    }

    func configure(name: String, location: String, rating: String) {
        nameLabel.text = name
        locationLabel.text = location
        ratingLabel.text = rating
    }
}
