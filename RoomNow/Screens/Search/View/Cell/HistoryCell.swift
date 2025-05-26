//
//  HistoryCell.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 26.05.2025.
//

import UIKit

final class HistoryCell: UITableViewCell {

    private let destinationLabel = UILabel()
    private let dateLabel = UILabel()
    private let guestlabel = UILabel()

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

        destinationLabel.applyCellTitleStyle()
        dateLabel.applyCellSubtitleStyle()
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.minimumScaleFactor = 0.8
        dateLabel.numberOfLines = 1
        guestlabel.applyCellSecondSubtitleStyle()
        
        let midStack = UIStackView(arrangedSubviews: [dateLabel, guestlabel])
        midStack.axis = .horizontal
        midStack.spacing = 4

        let textStack = UIStackView(arrangedSubviews: [destinationLabel, midStack])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.distribution = .fillEqually
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(view)
        view.addSubview(textStack)
        
        view.pinToEdges(of: contentView, withInsets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))

        NSLayoutConstraint.activate([
            textStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            textStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
        ])
    }

    func configure(with viewModel: HistoryCellViewModel) {
        destinationLabel.text = viewModel.destination
        dateLabel.text = viewModel.dateRange
        guestlabel.text = viewModel.guestSummary
    }
}
