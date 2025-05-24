//
//  PersonalInfoCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 24.05.2025.
//

import UIKit

final class PersonalInfoCell: UITableViewCell {
    let textField = UITextField()
    let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .appSecondaryBackground
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .appPrimaryText
        
        contentView.backgroundColor = .appBackground
        contentView.addSubview(textField)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            textField.heightAnchor.constraint(equalToConstant: 44)
        ])
        
    }
    
    func configure(placeholder: String, text: String?, keyboard: UIKeyboardType = .default) {
        titleLabel.text = placeholder
        textField.placeholder = placeholder
        textField.text = text
        textField.keyboardType = keyboard
    }
}
