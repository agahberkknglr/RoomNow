//
//  CounterView.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 27.03.2025.
//

import UIKit

class CounterView: UIView {
    
    private var counter: Int {
        didSet {
            counterLabel.text = "\(counter)"
            updateButtonState()
        }
    }
    
    private let minValue: Int
    
    private let minusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("−", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        button.backgroundColor = .clear
        button.layer.borderColor = UIColor.white.cgColor
        button.tintColor = .white
        button.layer.cornerRadius = 0
        return button
    }()

    private let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        button.backgroundColor = .clear
        button.layer.borderColor = UIColor.white.cgColor

        button.tintColor = .white
        button.layer.cornerRadius = 0
        return button
    }()

    private let counterLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    // Custom initializer to set a starting value
    init(startValue: Int = 0, minValue: Int = 0) {
        self.counter = startValue
        self.minValue = minValue
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        self.counter = 0  // Default to 0 if using Storyboard
        self.minValue = 0
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        let stackView = UIStackView(arrangedSubviews: [minusButton, counterLabel, plusButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fillProportionally

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 50),

            minusButton.widthAnchor.constraint(equalToConstant: 30),
            minusButton.heightAnchor.constraint(equalToConstant: 30),

            plusButton.widthAnchor.constraint(equalToConstant: 30),
            plusButton.heightAnchor.constraint(equalToConstant: 30),

            counterLabel.widthAnchor.constraint(equalToConstant: 50),
            counterLabel.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Set initial counter value
        counterLabel.text = "\(counter)"
        updateButtonState()

        // Button actions
        minusButton.addTarget(self, action: #selector(decreaseValue), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(increaseValue), for: .touchUpInside)
    }

    @objc private func decreaseValue() {
        if counter > minValue {
            counter -= 1
        }
    }

    @objc private func increaseValue() {
        counter += 1
    }

    private func updateButtonState() {
        minusButton.isEnabled = counter > minValue
        minusButton.alpha = counter > minValue ? 1.0 : 0.5
    }
}
