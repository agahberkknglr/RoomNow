//
//  HotelChatCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 27.05.2025.
//

import UIKit

final class HotelChatCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let locationLabel = UILabel()
    private let priceLabel = UILabel()
    private let detailsButton = UIButton(type: .system)
    private let selectRoomButton = UIButton(type: .system)
    
    private let view: UIView = {
        let view = UIView()
        view.backgroundColor = .appSecondaryBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        
        view.layer.masksToBounds = true
        return view
    }()

    var onViewDetails: (() -> Void)?
    var onSelectRoom: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with hotel: Hotel, rooms: [Room]) {
        nameLabel.text = hotel.name
        locationLabel.text = "📍\(hotel.city), \(hotel.location)"
        priceLabel.text = "₺\(Int(rooms.first?.price ?? 0)) / night"
    }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [nameLabel, locationLabel, priceLabel, detailsButton, selectRoomButton])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false

        detailsButton.setTitle("View Details", for: .normal)
        selectRoomButton.setTitle("Select Room", for: .normal)

        detailsButton.addTarget(self, action: #selector(viewTapped), for: .touchUpInside)
        selectRoomButton.addTarget(self, action: #selector(selectTapped), for: .touchUpInside)

        contentView.addSubview(view)
        view.addSubview(stack)
        view.pinToEdges(of: contentView, withInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 32))
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])
    }

    @objc private func viewTapped() {
        onViewDetails?()
    }

    @objc private func selectTapped() {
        onSelectRoom?()
    }
}

