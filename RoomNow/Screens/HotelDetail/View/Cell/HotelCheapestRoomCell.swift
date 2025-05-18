//
//  HotelCheapestRoomCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 14.05.2025.
//

import UIKit

final class HotelCheapestRoomCell: UITableViewCell {
    
    private let view = UIView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let arrowImageView = UIImageView()

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
        
        titleLabel.textColor = .appSecondaryText
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        priceLabel.textColor = .appPrimaryText
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = .appAccent
        arrowImageView.contentMode = .scaleAspectFit
        
        let vstack = UIStackView(arrangedSubviews: [titleLabel, priceLabel])
        vstack.axis = .vertical
        vstack.spacing = 4
        vstack.translatesAutoresizingMaskIntoConstraints = false
        
        let hstack = UIStackView(arrangedSubviews: [vstack, arrowImageView])
        hstack.axis = .horizontal
        hstack.spacing = 16
        hstack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hstack)
        
        hstack.pinToEdges(of: view, withInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        
        NSLayoutConstraint.activate([
            arrowImageView.widthAnchor.constraint(equalToConstant: 16),
        ])

    }
    
    func configure(price: Double, startDate: Date, endDate: Date){
        let nights = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        formatter.timeZone = TimeZone(identifier: "Europe/Istanbul")
        
        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)
        
        titleLabel.text = "Price for \(nights) night\(nights > 1 ? "s" : "") (\(start) - \(end))"
        priceLabel.text = "₺\(Int(price))"
    }
}
