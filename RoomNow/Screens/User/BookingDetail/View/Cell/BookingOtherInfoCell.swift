//
//  BookingOtherInfoCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 28.05.2025.
//

import UIKit

final class BookingOtherInfoCell: UITableViewCell {
    
    private let view: UIView = {
        let view = UIView()
        view.backgroundColor = .appSecondaryBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    private let descriptionLabel = UILabel()
    private let toggleButton = UIButton(type: .system)
    private let amenitiesTitleLabel = UILabel()
    private let amenitiesGrid = UIStackView()
    private var isExpanded = false
    private var fullDescription: String = ""
    private var onToggle: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        contentView.backgroundColor = .appBackground
        contentView.addSubview(view)

        view.pinToEdges(of: contentView, withInsets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))

        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.textColor = .appPrimaryText
        descriptionLabel.numberOfLines = 3
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        toggleButton.setTitle("More", for: .normal)
        toggleButton.setTitleColor(.appAccent, for: .normal)
        toggleButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        toggleButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)

        amenitiesTitleLabel.text = "Most Popular Facilities"
        amenitiesTitleLabel.font = .boldSystemFont(ofSize: 18)
        amenitiesTitleLabel.textColor = .appPrimaryText
        amenitiesTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        amenitiesGrid.axis = .vertical
        amenitiesGrid.spacing = 12
        amenitiesGrid.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(amenitiesTitleLabel)
        view.addSubview(amenitiesGrid)
        view.addSubview(descriptionLabel)
        view.addSubview(toggleButton)


        NSLayoutConstraint.activate([
            amenitiesTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            amenitiesTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            amenitiesTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            amenitiesGrid.topAnchor.constraint(equalTo: amenitiesTitleLabel.bottomAnchor, constant: 12),
            amenitiesGrid.leadingAnchor.constraint(equalTo: amenitiesTitleLabel.leadingAnchor),
            amenitiesGrid.trailingAnchor.constraint(equalTo: amenitiesTitleLabel.trailingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: amenitiesGrid.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            toggleButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            toggleButton.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            toggleButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12)
        ])

    }

    
    func configure(description: String, isExpanded: Bool, amenities: [Amenity], onToggle: @escaping () -> Void) {
        fullDescription = description
        self.isExpanded = isExpanded
        self.onToggle = onToggle 
        descriptionLabel.text = description
        descriptionLabel.numberOfLines = isExpanded ? 0 : 3
        toggleButton.setTitle(isExpanded ? "Less" : "More", for: .normal)
        toggleButton.isHidden = description.count < 140
        configureAmenities(amenities)
    }

    private func configureAmenities(_ amenities: [Amenity]) {
        amenitiesGrid.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let pairs = stride(from: 0, to: amenities.count, by: 2).map {
            Array(amenities[$0..<min($0 + 2, amenities.count)])
        }

        for pair in pairs {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 16
            row.distribution = .fillEqually

            for amenity in pair {
                let icon = UIImageView(image: amenity.icon)
                icon.tintColor = .appAccent
                icon.contentMode = .scaleAspectFit
                icon.translatesAutoresizingMaskIntoConstraints = false
                icon.widthAnchor.constraint(equalToConstant: 20).isActive = true
                icon.heightAnchor.constraint(equalToConstant: 20).isActive = true

                let label = UILabel()
                label.text = amenity.title
                label.font = .systemFont(ofSize: 15)
                label.textColor = .appPrimaryText
                label.numberOfLines = 0

                let itemStack = UIStackView(arrangedSubviews: [icon, label])
                itemStack.axis = .horizontal
                itemStack.spacing = 8
                itemStack.alignment = .center

                row.addArrangedSubview(itemStack)
            }

            amenitiesGrid.addArrangedSubview(row)
        }
    }

    @objc private func toggleTapped() {
        onToggle?()
    }

}
