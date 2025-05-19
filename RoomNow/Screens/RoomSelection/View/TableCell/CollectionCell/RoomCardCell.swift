//
//  RoomCardCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 18.05.2025.
//

import UIKit

final class RoomCardCell: UICollectionViewCell {

    private let titleLabel = UILabel()
    private let bedsLabel = UILabel()
    private let descLabel = UILabel()
    private let dateLabel = UILabel()
    private let priceLabel = UILabel()
    private let selectButton = UIButton()
    private let cardView = UIView()
    private let dividerView = HorizontalDividerView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(cardView)
        cardView.layer.cornerRadius = 10
        cardView.clipsToBounds = true
        cardView.pinToEdges(of: contentView)
        cardView.backgroundColor = .appSecondaryBackground

        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textAlignment = .center
        bedsLabel.font = .boldSystemFont(ofSize: 14)
        bedsLabel.textColor = .appAccent
        descLabel.font = .systemFont(ofSize: 12)
        descLabel.textColor = .appSecondaryText
        descLabel.numberOfLines = 0
        descLabel.lineBreakMode = .byWordWrapping
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .appPrimaryText
        dateLabel.numberOfLines = 0
        dateLabel.lineBreakMode = .byWordWrapping
        priceLabel.font = .boldSystemFont(ofSize: 14)
        priceLabel.textColor = .appAccent
        
        selectButton.setTitle("Select", for: .normal)
        selectButton.setTitleColor(.appAccent, for: .normal)
        selectButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        selectButton.backgroundColor = .appButtonBackground
        selectButton.layer.cornerRadius = 8
        selectButton.translatesAutoresizingMaskIntoConstraints = false
        selectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
        
        let titleStack = UIStackView(arrangedSubviews: [ titleLabel, dividerView])
        titleStack.axis = .vertical
        titleStack.spacing = 0
        titleStack.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [ bedsLabel, descLabel, dateLabel, priceLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(titleStack)
        cardView.addSubview(stack)
        cardView.addSubview(selectButton)
        
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 24),
            
            titleStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            titleStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            titleStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            
            stack.topAnchor.constraint(equalTo: titleStack.bottomAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            selectButton.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 8),
            selectButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            selectButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            selectButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -8),
            selectButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with room: HotelRoom, forNights nights: Int, startDate: Date, endDate: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        formatter.timeZone = TimeZone(identifier: "Europe/Istanbul")
        
        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)
        
        
        titleLabel.text = "Room \(room.roomNumber)"
        let bedCapacity = room.bedCapacity == 1 ? "bed" : "beds"
        bedsLabel.text = "\(room.bedCapacity) \(bedCapacity)"
        descLabel.text = room.description
        dateLabel.text = "Price for \(nights) night\(nights > 1 ? "s" : "") (\(start) - \(end))"
        let totalPrice = Int(room.price) * nights
        priceLabel.text = "₺\(Int(totalPrice))"
    }
    
    @objc private func selectButtonTapped() {
        print("Select button tapped for room card.")
    }
}
