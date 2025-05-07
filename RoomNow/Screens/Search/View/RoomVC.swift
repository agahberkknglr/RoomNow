//
//  RoomVC.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 25.03.2025.
//

import UIKit

protocol RoomVCProtocols {
    func configureVC()
    //func configureButtons()
}

protocol RoomVCDelegate: AnyObject {
    func didSelectRoomDetails(roomCount: Int, adults: Int, children: Int)
}

class RoomVC: UIViewController, RoomVCProtocols {
    
    weak var delegate: RoomVCDelegate?
    
    var selectedRooms: Int = 1
    var selectedAdults: Int = 2
    var selectedChildren: Int = 0

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
    
    private let roomCounter = CounterView(startValue: 1, minValue: 1)
    private let adultsCounter = CounterView(startValue: 2, minValue: 1)
    private let childrenCounter = CounterView(startValue: 0)
    
    private let applyButton = UIButton()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)

    }
    
    @objc private func applyButtonTapped() {
        let rooms = roomCounter.value
        let adults = adultsCounter.value
        let children = childrenCounter.value
        
        delegate?.didSelectRoomDetails(roomCount: rooms, adults: adults, children: children)
        
        dismiss(animated: true)
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
        petInfoLabel.text = "Asistance animals aren't consider pets."
        petInfoLabel.font = .systemFont(ofSize: 14, weight: .light)
        petInfoLabel.textColor = .appSecondaryText
        
        roomCounter.setValue(selectedRooms)
        adultsCounter.setValue(selectedAdults)
        childrenCounter.setValue(selectedChildren)
        
        petSwitch.isOn = false
        
        roomStackView.axis = .horizontal
        roomStackView.distribution = .fillProportionally
        roomStackView.spacing = 10
        roomStackView.addArrangedSubview(roomLabel)
        roomStackView.addArrangedSubview(roomCounter)
        roomStackView.translatesAutoresizingMaskIntoConstraints = false
        
        adultsStackView.axis = .horizontal
        adultsStackView.distribution = .fillProportionally
        adultsStackView.spacing = 10
        adultsStackView.addArrangedSubview(adultsLabel)
        adultsStackView.addArrangedSubview(adultsCounter)
        adultsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        childrenLabelsStackView.axis = .vertical
        childrenLabelsStackView.distribution = .fillProportionally
        childrenLabelsStackView.spacing = 0
        childrenLabelsStackView.addArrangedSubview(childrenLabel)
        childrenLabelsStackView.addArrangedSubview(childrenInfoLabel)
        childrenLabelsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        childrenStackView.axis = .horizontal
        childrenStackView.distribution = .fillProportionally
        childrenStackView.spacing = 10
        childrenStackView.addArrangedSubview(childrenLabelsStackView)
        childrenStackView.addArrangedSubview(childrenCounter)
        childrenStackView.translatesAutoresizingMaskIntoConstraints = false
        
        petStackView.axis = .horizontal
        petStackView.distribution = .fill
        petStackView.spacing = 10
        petStackView.addArrangedSubview(petLabel)
        petStackView.addArrangedSubview(petSwitch)
        petStackView.translatesAutoresizingMaskIntoConstraints = false

        let stackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [titleLabel, roomStackView, adultsStackView, childrenStackView, petStackView, petInfoLabel, applyButton])
            stackView.axis = .vertical
            stackView.distribution = .fillProportionally
            stackView.spacing = 10
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()
        
        applyButton.setTitle("Apply", for: .normal)
        applyButton.layer.cornerRadius = 10
        applyButton.tintColor = .appPrimaryText
        applyButton.backgroundColor = .appButtonBackground
        

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            roomCounter.widthAnchor.constraint(equalToConstant: 100),
            adultsCounter.widthAnchor.constraint(equalToConstant: 100),
            childrenCounter.widthAnchor.constraint(equalToConstant: 100),
            roomCounter.heightAnchor.constraint(equalToConstant: 50),
            adultsCounter.heightAnchor.constraint(equalToConstant: 50),
            childrenCounter.heightAnchor.constraint(equalToConstant: 50),
            applyButton.widthAnchor.constraint(equalToConstant: 100),
            applyButton.heightAnchor.constraint(equalToConstant: 50)
        ])

    }
    

}

//extension RoomVC: RoomVCProtocols {
//
//}

