//
//  GenderPickerCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.05.2025.
//

import UIKit

final class GenderPickerCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let segmentedControl = UISegmentedControl(items: ["Male", "Female", "Other"])

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .appBackground

        titleLabel.text = "Gender"
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .appSecondaryText

        segmentedControl.selectedSegmentTintColor = .appButtonBackground
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.appSecondaryText], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)

        let stack = UIStackView(arrangedSubviews: [titleLabel, segmentedControl])
        stack.axis = .vertical
        stack.spacing = 4
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])

        selectionStyle = .none
    }

    func configure(selected gender: String, isEnabled: Bool) {
        segmentedControl.isEnabled = isEnabled
        switch gender.lowercased() {
        case "male": segmentedControl.selectedSegmentIndex = 0
        case "female": segmentedControl.selectedSegmentIndex = 1
        default: segmentedControl.selectedSegmentIndex = 2
        }
    }

    func selectedGender() -> String {
        switch segmentedControl.selectedSegmentIndex {
        case 0: return "Male"
        case 1: return "Female"
        default: return "Other"
        }
    }
}

