//
//  AdminDashboardHeaderCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 9.06.2025.
//

import UIKit

final class AdminDashboardHeaderCell: UITableViewCell {

    private let welcomeLabel = UILabel()
    private let cityFilterButton = UIButton(type: .system)
    private let hotelCountLabel = UILabel()
    var onFilterTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        selectionStyle = .none
        contentView.backgroundColor = .appBackground
        
        welcomeLabel.applyTitleStyle()
        hotelCountLabel.applySubtitleStyle()
        cityFilterButton.applyPrimaryStyle(with: "Filter by City ▾")
        cityFilterButton.addTarget(self, action: #selector(cityFilterTapped), for: .touchUpInside)
        
        let bottomRowStack = UIStackView(arrangedSubviews: [hotelCountLabel, UIView(), cityFilterButton])
        bottomRowStack.axis = .horizontal
        bottomRowStack.alignment = .center
        bottomRowStack.spacing = 8

        let stack = UIStackView(arrangedSubviews: [welcomeLabel, bottomRowStack])
        stack.axis = .vertical
        stack.spacing = 8

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            cityFilterButton.widthAnchor.constraint(equalTo: stack.widthAnchor, multiplier: 0.4)
        ])
    }
    
    @objc private func cityFilterTapped() {
        onFilterTapped?()
    }
    
    func configure(hotelCount: Int, adminName: String) {
        welcomeLabel.text = "Welcome, \(adminName)"
        hotelCountLabel.text = "Hotels: \(hotelCount)"
    }
}
