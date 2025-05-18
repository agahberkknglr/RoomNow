//
//  RoomTypeCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 18.05.2025.
//

import UIKit

final class RoomTypeCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let collectionView: UICollectionView

    private var rooms: [HotelRoom] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 240, height: 200)
        layout.minimumLineSpacing = 12
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
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            collectionView.heightAnchor.constraint(equalToConstant: 140)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(typeName: String, rooms: [HotelRoom]) {
        self.titleLabel.text = typeName.capitalized
        self.rooms = rooms
        collectionView.reloadData()
    }
}

extension RoomTypeCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        rooms.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(RoomCardCell.self, for: indexPath)
        cell.configure(with: rooms[indexPath.item])
        return cell
    }
}

