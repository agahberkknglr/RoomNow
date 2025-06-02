//
//  HotelInfoCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 23.05.2025.
//

import UIKit

final class HotelInfoCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let locationLabel = UILabel()
    private let checkInLabel = UILabel()
    private let checkInDateLabel = UILabel()
    private let checkOutLabel = UILabel()
    private let checkOutDateLabel = UILabel()
    private let guestNumberLabel = UILabel()
    private let divider = VerticalDividerView()
    
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
        
        titleLabel.applyTitleStyle()
        
        locationLabel.applySubtitleStyle()
        
        checkInLabel.textColor = .appSecondaryText
        checkOutLabel.textColor = .appSecondaryText
        
        checkInDateLabel.textColor = .appPrimaryText
        checkOutDateLabel.textColor = .appPrimaryText
        
        guestNumberLabel.textColor = .appAccent
        guestNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, locationLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 4
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        
        let stackCheckIn = UIStackView(arrangedSubviews: [checkInLabel, checkInDateLabel])
        stackCheckIn.axis = .vertical
        stackCheckIn.spacing = 4
        
        let stackCheckOut = UIStackView(arrangedSubviews: [checkOutLabel, checkOutDateLabel])
        stackCheckOut.axis = .vertical
        stackCheckOut.spacing = 4
        
        let dateStack = UIStackView(arrangedSubviews: [stackCheckIn, divider, stackCheckOut])
        dateStack.axis = .horizontal
        dateStack.spacing = 16
        dateStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(view)
        view.pinToEdges(of: contentView, withInsets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        view.addSubview(titleStack)
        view.addSubview(dateStack)
        view.addSubview(guestNumberLabel)
        
        NSLayoutConstraint.activate([
            titleStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            titleStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            dateStack.topAnchor.constraint(equalTo: titleStack.bottomAnchor, constant: 8),
            dateStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            divider.topAnchor.constraint(equalTo: dateStack.topAnchor),
            divider.bottomAnchor.constraint(equalTo: dateStack.bottomAnchor),
            divider.centerXAnchor.constraint(equalTo: dateStack.centerXAnchor),
            
            guestNumberLabel.topAnchor.constraint(equalTo: dateStack.bottomAnchor, constant: 8),
            guestNumberLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            guestNumberLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            guestNumberLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
        ])
    }
    
    func configure(hotel: Hotel, checkIn: Date, checkOut: Date, guests: Int) {
        titleLabel.text = hotel.name.capitalized
        locationLabel.text = "\(hotel.city.capitalized), \(hotel.location.capitalized)"

        checkInLabel.text = "Check-in"
        checkOutLabel.text = "Check-out"

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"

        checkInDateLabel.text = formatter.string(from: checkIn)
        checkOutDateLabel.text = formatter.string(from: checkOut)

        let guestText = guests == 1 ? "1 guest" : "\(guests) guests"
        guestNumberLabel.text = guestText
    }

}
