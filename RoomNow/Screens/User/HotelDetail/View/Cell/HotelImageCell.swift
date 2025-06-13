//
//  HotelImageCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 13.05.2025.
//

import UIKit
import SDWebImage

final class HotelImageCell: UITableViewCell {

    private let scrollView = UIScrollView()

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
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        contentView.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    func configure(with imageUrls: [String]) {
        scrollView.subviews.forEach { $0.removeFromSuperview() }

        let width = UIScreen.main.bounds.width
        let height: CGFloat = 200

        for (index, urlString) in imageUrls.enumerated() {
            let imageView = UIImageView()
            imageView.backgroundColor = .appSecondaryAccent // placeholder background
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.frame = CGRect(x: CGFloat(index) * width, y: 0, width: width, height: height)
            imageView.setImage(fromBase64: urlString)
            

            scrollView.addSubview(imageView)
        }

        scrollView.contentSize = CGSize(width: width * CGFloat(imageUrls.count), height: height)
    }
}
