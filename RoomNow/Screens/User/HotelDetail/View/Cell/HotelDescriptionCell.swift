//
//  HotelDescriptionCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 14.05.2025.
//

import UIKit

final class HotelDescriptionCell: UITableViewCell {

    private let descriptionLabel = UILabel()
    private let toggleButton = UIButton(type: .system)
    private var isExpanded = false
    private var fullText: String = ""

    var onToggle: (() -> Void)?

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
        
        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.textColor = .appPrimaryText
        descriptionLabel.numberOfLines = 3 // default collapsed
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        toggleButton.setTitle("More", for: .normal)
        toggleButton.setTitleColor(.appAccent, for: .normal)
        toggleButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        toggleButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)

        contentView.addSubview(descriptionLabel)
        contentView.addSubview(toggleButton)

        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            toggleButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            toggleButton.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            toggleButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with text: String, isExpanded: Bool) {
        fullText = text
        self.isExpanded = isExpanded
        descriptionLabel.text = text
        descriptionLabel.numberOfLines = isExpanded ? 0 : 3
        toggleButton.setTitle(isExpanded ? "Less" : "More", for: .normal)
        toggleButton.isHidden = text.count < 140
    }

    @objc private func toggleTapped() {
        isExpanded.toggle()
        descriptionLabel.numberOfLines = isExpanded ? 0 : 3
        toggleButton.setTitle(isExpanded ? "Less" : "More", for: .normal)
        onToggle?()
    }
}

