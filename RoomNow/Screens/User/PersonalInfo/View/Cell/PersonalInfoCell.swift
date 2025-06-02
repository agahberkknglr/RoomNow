//
//  PersonalInfoCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 24.05.2025.
//

import UIKit

final class PersonalInfoCell: UITableViewCell {
    let textField = UITextField()
    let textView = UITextView()
    let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .appBackground

        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .appSecondaryText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        textField.borderStyle = .roundedRect
        textField.backgroundColor = .appSecondaryBackground
        textField.translatesAutoresizingMaskIntoConstraints = false

        textView.font = .systemFont(ofSize: 16)
        textView.layer.cornerRadius = 8
        textView.backgroundColor = .appSecondaryBackground
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = true

        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
        contentView.addSubview(textView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 44),

            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            textView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    func configure(title: String, text: String?, keyboard: UIKeyboardType = .default, isNote: Bool = false, isEditable: Bool = true) {
        titleLabel.text = title
        if isNote {
            textView.isHidden = false
            textField.isHidden = true
            textView.text = text
            textView.isEditable = isEditable
        } else {
            textField.isHidden = false
            textView.isHidden = true
            textField.text = text
            textField.keyboardType = keyboard
            textField.isEnabled = isEditable
        }
    }
}

