//
//  PriceCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 24.05.2025.
//

import UIKit

final class PriceCell: UITableViewCell {
    
    private let priceLabel = UILabel()
    private let nightLabel = UILabel()
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

        priceLabel.font = .boldSystemFont(ofSize: 18)
        priceLabel.textColor = .appPrimaryText
        priceLabel.textAlignment = .left

        nightLabel.font = .systemFont(ofSize: 14)
        nightLabel.textColor = .appSecondaryText
        nightLabel.textAlignment = .left

        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        nightLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(view)
        view.addSubview(priceLabel)
        view.addSubview(nightLabel)
        view.pinToEdges(of: contentView, withInsets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        
        NSLayoutConstraint.activate([
            nightLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            nightLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nightLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            priceLabel.topAnchor.constraint(equalTo: nightLabel.bottomAnchor, constant: 4),
            priceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            priceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            priceLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(totalPrice: Int, nights: Int) {
        nightLabel.text = "\(nights) night\(nights > 1 ? "s" : "") total"
        priceLabel.text = "₺\(totalPrice)"
    }
}
