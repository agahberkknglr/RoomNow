//
//  RoomTypeCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 18.05.2025.
//

import UIKit

protocol RoomTypeCellDelegate: AnyObject {
    func didSelectRoom(_ room: HotelRoom)
}

final class RoomTypeCell: UITableViewCell {

    weak var delegate: RoomTypeCellDelegate?

    private let titleLabel = UILabel()
    private var collectionView: UICollectionView
    private var rooms: [HotelRoom] = []
    private var selectedRooms: [HotelRoom] = []
    private var nights: Int = 1
    private var startDate: Date?
    private var endDate: Date?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 240, height: 200)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = .appBackground
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        collectionView.backgroundColor = .appBackground
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(RoomCardCell.self)
        collectionView.dataSource = self

        contentView.addSubview(titleLabel)
        contentView.addSubview(collectionView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(typeName: String, rooms: [HotelRoom], selectedRooms: [HotelRoom], forNights: Int, startDate: Date, endDate: Date) {
        self.titleLabel.text = typeName.capitalized
        self.rooms = rooms
        self.selectedRooms = selectedRooms
        self.nights = forNights
        self.startDate = startDate
        self.endDate = endDate
        collectionView.reloadData()
    }
}

extension RoomTypeCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        rooms.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(RoomCardCell.self, for: indexPath)
        guard let start = startDate, let end = endDate else {
            return cell
        }
        let room = rooms[indexPath.item]
        let isSelected = selectedRooms.contains(where: { $0.roomNumber == room.roomNumber })

        cell.configure(with: rooms[indexPath.item], forNights: nights, startDate: start, endDate: end, isSelected: isSelected)
        cell.onSelectTapped = { [weak self] in
            let room = self?.rooms[indexPath.item]
            if let room = room {
                self?.delegate?.didSelectRoom(room)
            }
        }
        return cell
    }
}

