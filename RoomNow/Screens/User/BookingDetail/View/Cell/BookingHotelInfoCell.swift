//
//  BookingHotelInfoCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 26.05.2025.
//

import UIKit

final class BookingHotelInfoCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let locationLabel = UILabel()
    private let statusLabel = UILabel()
    private let checkInLabel = UILabel()
    private let checkInDateLabel = UILabel()
    private let checkOutLabel = UILabel()
    private let checkOutDateLabel = UILabel()
    private let guestNumberLabel = UILabel()
    private let divider = VerticalDividerView()
    
    private let imageScrollView = UIScrollView()
    private let imageContainerView = UIView()
    private var imageViews: [UIImageView] = []
    
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
        
        imageScrollView.isPagingEnabled = true
        imageScrollView.showsHorizontalScrollIndicator = false
        imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        imageContainerView.layer.cornerRadius = 8
        imageContainerView.layer.masksToBounds = true
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.applyTitleStyle()
        locationLabel.applySubtitleStyle()
        statusLabel.applyCellSubtitleStyle()
        checkInLabel.textColor = .appSecondaryText
        checkOutLabel.textColor = .appSecondaryText
        checkInDateLabel.textColor = .appPrimaryText
        checkOutDateLabel.textColor = .appPrimaryText
        guestNumberLabel.textColor = .appAccent
        guestNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, locationLabel, statusLabel])
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
        imageContainerView.addSubview(imageScrollView)
        imageScrollView.pinToEdges(of: imageContainerView)
        view.addSubview(imageContainerView)
        view.addSubview(titleStack)
        view.addSubview(dateStack)
        view.addSubview(guestNumberLabel)
        
        NSLayoutConstraint.activate([
            
            titleStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            titleStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            imageContainerView.topAnchor.constraint(equalTo: titleStack.bottomAnchor, constant: 16),
            imageContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageContainerView.heightAnchor.constraint(equalToConstant: 180),

            dateStack.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: 16),
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
    
    func configure(hotelName: String, location: String, checkIn: Date, checkOut: Date, guestCount: Int, imageURLs: [String], status: ReservationStatus) {
        titleLabel.text = hotelName
        locationLabel.text = location.capitalized

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.timeZone = TimeZone(identifier: "Europe/Istanbul")

        checkInLabel.text = "Check-in"
        checkInDateLabel.text = formatter.string(from: checkIn)

        checkOutLabel.text = "Check-out"
        checkOutDateLabel.text = formatter.string(from: checkOut)

        guestNumberLabel.text = "Guests: \(guestCount)"
        
        loadImages(from: imageURLs)
        
        setStatusText(status)
    }
    
    private func setStatusText(_ status: ReservationStatus) {
        let statusText = status.rawValue.capitalized
        let prefix = "Reservation status is "
        let suffix = statusText

        let suffixColor: UIColor
        switch status {
        case .active:
            suffixColor = .appSuccess
        case .cancelled:
            suffixColor = .appError
        case .completed:
            suffixColor = .appSecondaryText
        case .ongoing:
            suffixColor = .appWarning
        }

        statusLabel.setMixedStyleText(
            prefix: prefix,
            suffix: suffix,
            prefixFont: .systemFont(ofSize: 14),
            suffixFont: .boldSystemFont(ofSize: 14),
            prefixColor: .appSecondaryText,
            suffixColor: suffixColor
        )
    }

    
    private func loadImages(from urls: [String]) {
        imageViews.forEach { $0.removeFromSuperview() }
        imageViews = []

        for (index, urlStr) in urls.enumerated() {
            let imageView = UIImageView()
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.sd_setImage(with: URL(string: urlStr), placeholderImage: UIImage(systemName: "placeholder"))
            imageView.translatesAutoresizingMaskIntoConstraints = false

            imageScrollView.addSubview(imageView)
            imageViews.append(imageView)

            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: imageScrollView.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: imageScrollView.bottomAnchor),
                imageView.widthAnchor.constraint(equalTo: imageScrollView.widthAnchor),
                imageView.heightAnchor.constraint(equalTo: imageScrollView.heightAnchor),
                imageView.leadingAnchor.constraint(equalTo: index == 0 ?
                    imageScrollView.leadingAnchor :
                    imageViews[index - 1].trailingAnchor)
            ])
        }

        if let lastImage = imageViews.last {
            lastImage.trailingAnchor.constraint(equalTo: imageScrollView.trailingAnchor).isActive = true
        }
    }

}
