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
    
    private var isNoteField = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .appSecondaryBackground
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .appPrimaryText
        
        textView.font = .systemFont(ofSize: 16)
        textView.backgroundColor = .appSecondaryBackground
        textView.layer.cornerRadius = 8
        textView.isScrollEnabled = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isHidden = true
        
        contentView.backgroundColor = .appBackground
        contentView.addSubview(textField)
        contentView.addSubview(textView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            textField.heightAnchor.constraint(equalToConstant: 44),
            
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            textView.heightAnchor.constraint(equalToConstant: 140)
        ])
        
    }
    
    func configure(placeholder: String, text: String?, keyboard: UIKeyboardType = .default, isNote: Bool = false) {
        isNoteField = isNote
        titleLabel.text = placeholder

        if isNote {
            textField.isHidden = true
            textView.isHidden = false
            textView.text = text
        } else {
            textView.isHidden = true
            textField.isHidden = false
            textField.placeholder = placeholder
            textField.text = text
            textField.keyboardType = keyboard
        }
    }
}
