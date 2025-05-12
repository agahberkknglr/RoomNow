//
//  RoomVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 25.03.2025.
//

import UIKit

protocol RoomVCProtocols {
    func configureVC()
}

protocol RoomVCDelegate: AnyObject {
    func didSelectRoomDetails(roomCount: Int, adults: Int, children: Int)
}

final class RoomVC: UIViewController, RoomVCProtocols {

    weak var delegate: RoomVCDelegate?
    private let viewModel: RoomVMProtocol

    init(viewModel: RoomVMProtocol = RoomVM()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let titleLabel = UILabel()
    private let roomLabel = UILabel()
    private let adultsLabel = UILabel()
    private let childrenLabel = UILabel()
    private let childrenInfoLabel = UILabel()
    private let petLabel = UILabel()
    private let petInfoLabel = UILabel()
    private let petSwitch = UISwitch()

    private let roomStackView = UIStackView()
    private let adultsStackView = UIStackView()
    private let childrenStackView = UIStackView()
    private let childrenLabelsStackView = UIStackView()
    private let petStackView = UIStackView()
    private let contentStackView = UIStackView()


    private let roomCounter = CounterView(startValue: 1, minValue: 1)
    private let adultsCounter = CounterView(startValue: 2, minValue: 1)
    private let childrenCounter = CounterView(startValue: 0)

    private let applyButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @objc private func applyButtonTapped() {
        viewModel.setRooms(roomCounter.value)
        viewModel.setAdults(adultsCounter.value)
        viewModel.setChildren(childrenCounter.value)
        viewModel.setPetSelected(petSwitch.isOn)

        delegate?.didSelectRoomDetails(
            roomCount: viewModel.numberOfRooms,
            adults: viewModel.numberOfAdults,
            children: viewModel.numberOfChildren
        )
        dismiss(animated: true)
    }

    private func setupActions() {
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
    }

    func configureVC() {
        view.backgroundColor = .appBackground

        titleLabel.text = "Select rooms and guests"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        roomLabel.text = "Rooms"
        adultsLabel.text = "Adults"
        childrenLabel.text = "Children"
        childrenInfoLabel.text = "0 - 17 years old"
        childrenInfoLabel.font = .systemFont(ofSize: 14, weight: .light)
        petLabel.text = "Travelling with pets?"
        petInfoLabel.text = "Assistance animals aren't considered pets."
        petInfoLabel.font = .systemFont(ofSize: 14, weight: .light)
        petInfoLabel.textColor = .appSecondaryText

        roomCounter.setValue(viewModel.numberOfRooms)
        adultsCounter.setValue(viewModel.numberOfAdults)
        childrenCounter.setValue(viewModel.numberOfChildren)
        petSwitch.isOn = viewModel.isPetSelected

        roomStackView.axis = .horizontal
        roomStackView.spacing = 10
        roomStackView.addArrangedSubview(roomLabel)
        roomStackView.addArrangedSubview(roomCounter)

        adultsStackView.axis = .horizontal
        adultsStackView.spacing = 10
        adultsStackView.addArrangedSubview(adultsLabel)
        adultsStackView.addArrangedSubview(adultsCounter)

        childrenLabelsStackView.axis = .vertical
        childrenLabelsStackView.spacing = 0
        childrenLabelsStackView.addArrangedSubview(childrenLabel)
        childrenLabelsStackView.addArrangedSubview(childrenInfoLabel)

        childrenStackView.axis = .horizontal
        childrenStackView.spacing = 10
        childrenStackView.addArrangedSubview(childrenLabelsStackView)
        childrenStackView.addArrangedSubview(childrenCounter)

        petStackView.axis = .horizontal
        petStackView.spacing = 10
        petStackView.addArrangedSubview(petLabel)
        petStackView.addArrangedSubview(petSwitch)

        applyButton.setTitle("Apply", for: .normal)
        applyButton.layer.cornerRadius = 10
        applyButton.tintColor = .appPrimaryText
        applyButton.backgroundColor = .appButtonBackground

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            roomStackView,
            adultsStackView,
            childrenStackView,
            petStackView,
            petInfoLabel,
            applyButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 14
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            roomCounter.widthAnchor.constraint(equalToConstant: 100),
            adultsCounter.widthAnchor.constraint(equalToConstant: 100),
            childrenCounter.widthAnchor.constraint(equalToConstant: 100),

            roomCounter.heightAnchor.constraint(equalToConstant: 50),
            adultsCounter.heightAnchor.constraint(equalToConstant: 50),
            childrenCounter.heightAnchor.constraint(equalToConstant: 50),

            applyButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

}
