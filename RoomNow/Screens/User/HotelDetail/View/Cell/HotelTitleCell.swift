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
    private let starStack = UIStackView()

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
        
        starStack.axis = .horizontal
        starStack.spacing = 1
        starStack.alignment = .center
        starStack.distribution = .fill
        
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let ratStack = UIStackView(arrangedSubviews: [starStack])
        ratStack.axis = .horizontal
        ratStack.spacing = 4
        
        let hstack = UIStackView(arrangedSubviews: [vstack, ratStack])
        hstack.axis = .horizontal
        hstack.spacing = 4
        hstack.distribution = .equalSpacing
        hstack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hstack)

        hstack.pinToEdges(of: view, withInsets: UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8))

        nameLabel.font = .boldSystemFont(ofSize: 20)
        nameLabel.textColor = .appPrimaryText
        nameLabel.numberOfLines = 2
        locationLabel.textColor = .appSecondaryText
    }

    func configure(name: String, location: String, rating: String) {
        nameLabel.text = name
        locationLabel.text = location
        starStack.setStars(from: rating)
    }
}
