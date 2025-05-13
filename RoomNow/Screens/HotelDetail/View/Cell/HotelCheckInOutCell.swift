//
//  HotelCheckInOutCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 13.05.2025.
//

import UIKit

final class HotelCheckInOutCell: UITableViewCell {
    
    private let view = UIView()
    private let checkInLabel = UILabel()
    private let checkInDateLabel = UILabel()
    private let checkOutLabel = UILabel()
    private let checkOutDateLabel = UILabel()
    private let divider = VerticalDividerView()

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
        
        view.pinToEdges(of: contentView, withInsets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        view.backgroundColor = .clear
        
        let vstackIn = UIStackView(arrangedSubviews: [checkInLabel, checkInDateLabel])
        vstackIn.axis = .vertical
        vstackIn.spacing = 4
        vstackIn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vstackIn)
        
        let vstackOut = UIStackView(arrangedSubviews: [checkOutLabel, checkOutDateLabel])
        vstackOut.axis = .vertical
        vstackOut.spacing = 4
        vstackOut.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vstackOut)
        
        let hstack = UIStackView(arrangedSubviews: [vstackIn, divider, vstackOut])
        hstack.axis = .horizontal
        hstack.spacing = 16
        hstack.alignment = .center
        hstack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hstack)
        
        hstack.pinToEdges(of: view, withInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        
        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: hstack.topAnchor),
            divider.bottomAnchor.constraint(equalTo: hstack.bottomAnchor),
            divider.centerXAnchor.constraint(equalTo: hstack.centerXAnchor),
        ])
    }
    
    func configure(checkIn: String, checkOut: String) {
        checkInDateLabel.text = checkIn
        checkInDateLabel.textColor = .appPrimaryText
        checkOutDateLabel.text = checkOut
        checkOutDateLabel.textColor = .appPrimaryText
        
        checkInLabel.text = "Check-in"
        checkInLabel.textColor = .secondaryLabel
        checkInLabel.font = .systemFont(ofSize: 13, weight: .medium)
        checkOutLabel.text = "Check-out"
        checkOutLabel.textColor = .secondaryLabel
        checkOutLabel.font = .systemFont(ofSize: 13, weight: .medium)

    }
}
