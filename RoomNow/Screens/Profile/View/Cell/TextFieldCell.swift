//
//  TextFieldCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.05.2025.
//

import UIKit

final class TextFieldCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let textField = UITextField()
    var onTextChanged: ((String) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .appBackground

        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .appSecondaryText

        textField.font = .systemFont(ofSize: 16)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .appSecondaryBackground
        
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)

        let stack = UIStackView(arrangedSubviews: [titleLabel, textField])
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

    func configure(title: String, text: String, isEditable: Bool) {
        titleLabel.text = title
        textField.text = text
        textField.isUserInteractionEnabled = isEditable
        textField.backgroundColor = isEditable ? .appSecondaryBackground : .systemGray5
    }

    func getText() -> String {
        return textField.text ?? ""
    }
    
    @objc private func textDidChange() {
        onTextChanged?(textField.text ?? "")
    }
}
