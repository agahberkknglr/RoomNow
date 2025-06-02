//
//  DateFieldCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 29.05.2025.
//

import UIKit

final class DateFieldCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let datePicker = UIDatePicker()

    var onDateChanged: ((String) -> Void)?

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

        textField.borderStyle = .roundedRect
        textField.backgroundColor = .appSecondaryBackground
        textField.inputView = datePicker
        textField.tintColor = .clear

        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -12, to: Date())

        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)

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

    @objc private func dateChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let dob = formatter.string(from: datePicker.date)
        textField.text = dob
        onDateChanged?(dob)
    }

    func configure(title: String, date: String?, isEditable: Bool) {
        titleLabel.text = title
        textField.isUserInteractionEnabled = isEditable
        textField.backgroundColor = isEditable ? .appSecondaryBackground : .systemGray5

        if let date = date, let parsed = parseDate(date) {
            datePicker.date = parsed
            textField.text = displayDate(from: parsed)
        } else {
            textField.text = date
        }
    }

    private func parseDate(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string)
    }

    private func displayDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }
}
