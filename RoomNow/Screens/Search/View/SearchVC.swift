//
//  ViewController.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 21.03.2025.
//

import UIKit

protocol SearchVCProtocol: AnyObject {
    func configureVC()
    func setupSearchButtons()
}

final class SearchVC: UIViewController{
    
    private var destinationButton = SearchOptionButton()
    private var dateButton = SearchOptionButton()
    private var roomButton = SearchOptionButton()
    
    private let viewModel = SearchVM()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        viewModel.viewDidLoad()
    }
}

extension SearchVC: SearchVCProtocol {
    
    func configureVC() {
        view.backgroundColor = .brown
    }
    
    func setupSearchButtons() {
        destinationButton.setTitle("Select Destination", for: .normal)
        dateButton.setTitle("Select Dates", for: .normal)
        roomButton.setTitle("Select Rooms & Guests", for: .normal)
        
        destinationButton.addTarget(self, action: #selector(openDestinationSheet), for: .touchUpInside)
        dateButton.addTarget(self, action: #selector(openDateSheet), for: .touchUpInside)
        roomButton.addTarget(self, action: #selector(openRoomSheet), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [destinationButton, dateButton, roomButton])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            destinationButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func openDestinationSheet() {
        presentBottomSheet(with: DestinationVC(), detents: [.large()])
    }

    @objc private func openDateSheet() {
        presentBottomSheet(with: DestinationVC(), detents: [.medium()])
    }

    @objc private func openRoomSheet() {
        presentBottomSheet(with: RoomVC(), detents: [.medium()])
    }

    private func presentBottomSheet(with viewController: UIViewController, detents: [UISheetPresentationController.Detent]) {
        let navController = UINavigationController(rootViewController: viewController)
        if let sheet = navController.sheetPresentationController {
            sheet.detents = detents
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
        }
        present(navController, animated: true)
    }
}
