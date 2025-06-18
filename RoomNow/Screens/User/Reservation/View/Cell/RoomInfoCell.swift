//
//  RoomInfoCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 24.05.2025.
//

import UIKit

final class RoomInfoCell: UITableViewCell {
    
    private let roomTypeLabel = UILabel()
    private let roomInfoLabel = UILabel()
    private let roomUserNameLabel = UILabel()
    private let roomNoteLabel = UILabel()
    
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
    
    private func setupUI(){
        contentView.backgroundColor = .appBackground

        [roomTypeLabel, roomInfoLabel, roomUserNameLabel, roomNoteLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        roomTypeLabel.font = .boldSystemFont(ofSize: 16)
        roomTypeLabel.textColor = .appPrimaryText

        roomInfoLabel.font = .systemFont(ofSize: 14)
        roomInfoLabel.textColor = .appSecondaryText

        roomUserNameLabel.font = .systemFont(ofSize: 14)
        roomUserNameLabel.textColor = .appAccent

        roomNoteLabel.font = .italicSystemFont(ofSize: 14)
        roomNoteLabel.textColor = .appSecondaryText
        roomNoteLabel.numberOfLines = 0

        contentView.addSubview(view)
        view.pinToEdges(of: contentView, withInsets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        
        NSLayoutConstraint.activate([
            roomTypeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            roomTypeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            roomTypeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            roomInfoLabel.topAnchor.constraint(equalTo: roomTypeLabel.bottomAnchor, constant: 4),
            roomInfoLabel.leadingAnchor.constraint(equalTo: roomTypeLabel.leadingAnchor),
            roomInfoLabel.trailingAnchor.constraint(equalTo: roomTypeLabel.trailingAnchor),

            roomUserNameLabel.topAnchor.constraint(equalTo: roomInfoLabel.bottomAnchor, constant: 4),
            roomUserNameLabel.leadingAnchor.constraint(equalTo: roomTypeLabel.leadingAnchor),
            roomUserNameLabel.trailingAnchor.constraint(equalTo: roomTypeLabel.trailingAnchor),

            roomNoteLabel.topAnchor.constraint(equalTo: roomUserNameLabel.bottomAnchor, constant: 8),
            roomNoteLabel.leadingAnchor.constraint(equalTo: roomTypeLabel.leadingAnchor),
            roomNoteLabel.trailingAnchor.constraint(equalTo: roomTypeLabel.trailingAnchor),
            roomNoteLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(room: Room, typeName: String, nights: Int, guest: String, note: String?) {
        roomTypeLabel.text = "\(typeName.capitalized) Room - #\(room.roomNumber)"
        roomInfoLabel.text = "\(room.bedCapacity) bed\(room.bedCapacity > 1 ? "s" : "") – ₺\(Int(room.price)) x \(nights) night\(nights > 1 ? "s" : "")"
        roomUserNameLabel.text = "Reserved for: \(guest.capitalized)"
        roomNoteLabel.text = note?.isEmpty == false ? "Note: \(note!)" : ""
    }
}
