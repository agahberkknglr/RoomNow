//
//  BookingPriceInfoCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 26.05.2025.
//

import UIKit

final class BookingPriceInfoCell: UITableViewCell {
    
    private let totalLabel = UILabel()
    private let priceLabel = UILabel()
    private let nightLabel = UILabel()
    private let cancelInfoLabel = UILabel()
    private let view: UIView = {
        let view = UIView()
        view.backgroundColor = .appSecondaryBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        contentView.backgroundColor = .appBackground

        totalLabel.font = .boldSystemFont(ofSize: 18)
        totalLabel.textColor = .appPrimaryText
        totalLabel.textAlignment = .left
        
        priceLabel.font = .boldSystemFont(ofSize: 18)
        priceLabel.textColor = .appPrimaryText
        priceLabel.textAlignment = .right

        nightLabel.font = .systemFont(ofSize: 14)
        nightLabel.textColor = .appSecondaryText
        nightLabel.textAlignment = .right

        cancelInfoLabel.font = .systemFont(ofSize: 12)
        cancelInfoLabel.numberOfLines = 0
        cancelInfoLabel.textAlignment = .left
        
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        nightLabel.translatesAutoresizingMaskIntoConstraints = false
        cancelInfoLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(view)
        view.addSubview(totalLabel)
        view.addSubview(priceLabel)
        view.addSubview(nightLabel)
        view.addSubview(cancelInfoLabel)
        view.pinToEdges(of: contentView, withInsets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        
        NSLayoutConstraint.activate([
            totalLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            totalLabel.trailingAnchor.constraint(equalTo: nightLabel.trailingAnchor, constant: -16),
            totalLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            nightLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            nightLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            priceLabel.topAnchor.constraint(equalTo: nightLabel.bottomAnchor, constant: 4),
            priceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            priceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            cancelInfoLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 12),
            cancelInfoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cancelInfoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelInfoLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
            
        ])
    }
    
    func configure(totalPrice: Int, nights: Int, status: ReservationStatus) {
        totalLabel.text = "Total Price:"
        nightLabel.text = "\(nights) night\(nights > 1 ? "s" : "")"
        priceLabel.text = "₺\(totalPrice)"
        cancelInfoLabel.text = status.description
        cancelInfoLabel.textColor = status.color
    }
}
