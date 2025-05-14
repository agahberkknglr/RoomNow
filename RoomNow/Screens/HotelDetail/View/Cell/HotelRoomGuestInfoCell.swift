//
//  HotelRoomGuestInfoCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 14.05.2025.
//

import UIKit

final class HotelRoomGuestInfoCell: UITableViewCell {
    
    private let view = UIView()
    private let sectionLabel = UILabel()
    private let guestInfoText = UILabel()

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
        
        sectionLabel.text = "Room and guests"
        sectionLabel.textColor = .appSecondaryText
        sectionLabel.font = .systemFont(ofSize: 13, weight: .medium)
        guestInfoText.textColor = .appPrimaryText
        
        let vstack = UIStackView(arrangedSubviews: [sectionLabel, guestInfoText])
        vstack.axis = .vertical
        vstack.spacing = 4
        vstack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vstack)
        
        vstack.pinToEdges(of: view, withInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
    }
    
    func configure(info: String) {
        guestInfoText.text = info
    }
}
