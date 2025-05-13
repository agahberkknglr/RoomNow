//
//  ViewController.swift
//  RoomNow
//
//  Created by Agah Berkin Güler on 21.03.2025.
//

import UIKit

final class SearchVC: UIViewController {
    
    private let destinationButton = SearchOptionButton()
    private let dateButton = SearchOptionButton()
    private let roomButton = SearchOptionButton()
    private let searchButton = UIButton()
    
    private let viewModel: SearchVMProtocol
    
    init(viewModel: SearchVMProtocol = SearchVM()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
    }

    private func configureUI() {
        view.backgroundColor = .appBackground
        
        destinationButton.addTarget(self, action: #selector(openDestinationSheet), for: .touchUpInside)
        dateButton.addTarget(self, action: #selector(openDateSheet), for: .touchUpInside)
        roomButton.addTarget(self, action: #selector(openRoomSheet), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        
        searchButton.setTitle("Search Now", for: .normal)
        searchButton.layer.cornerRadius = 10
        searchButton.tintColor = .white
        
        let stackView = UIStackView(arrangedSubviews: [destinationButton, dateButton, roomButton, searchButton])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            destinationButton.heightAnchor.constraint(equalToConstant: 50),
            searchButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func updateButtonStates() {
        destinationButton.setTitle(viewModel.getDestinationTitle(), for: .normal)
        dateButton.setTitle(viewModel.getDateButtonTitle(), for: .normal)
        roomButton.setTitle(viewModel.getRoomButtonTitle(), for: .normal)

        let isEnabled = viewModel.isSearchEnabled()
        searchButton.isEnabled = isEnabled
        searchButton.backgroundColor = isEnabled ? .appButtonBackground : .appDisabled
        searchButton.alpha = isEnabled ? 1.0 : 0.5
    }

    @objc private func searchButtonTapped() {
        guard let parameters = viewModel.getSearchParameters() else {
            print("Missing search data")
            return
        }
        let resultVC = ResultVC(searchParameters: parameters)
        resultVC.hidesBottomBarWhenPushed = true 
        navigationController?.pushViewController(resultVC, animated: true)
    }

    @objc private func openDestinationSheet() {
        let destinationVC = DestinationVC()
        destinationVC.delegate = self
        presentBottomSheet(with: destinationVC, detents: [.large()])
    }

    @objc private func openDateSheet() {
        let dateVC = DateVC()
        dateVC.selectedStartDate = viewModel.selectedStartDate
        dateVC.selectedEndDate = viewModel.selectedEndDate
        dateVC.delegate = self
        presentBottomSheet(with: dateVC, detents: [.medium()])
    }
    
    @objc private func openRoomSheet() {
        guard let searchVM = viewModel as? SearchVM else {
            print("Failed to cast ViewModel")
            return
        }

        let roomVM = RoomVM(
            rooms: searchVM.numberOfRooms,
            adults: searchVM.numberOfAdults,
            children: searchVM.numberOfChildren
        )

        let roomVC = RoomVC(viewModel: roomVM)
        roomVC.delegate = self
        presentBottomSheet(with: roomVC, detents: [.medium()])
    }

    private func presentBottomSheet(with viewController: UIViewController, detents: [UISheetPresentationController.Detent]) {
        let nav = UINavigationController(rootViewController: viewController)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = detents
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
        }
        present(nav, animated: true)
    }
}

extension SearchVC: SearchVMDelegate {
    func updateUI() {
        configureUI()
        updateButtonStates()
    }
}

extension SearchVC: DestinationVCDelegate {
    func didSelectCity(_ city: City) {
        viewModel.updateSelectedCity(city)
    }
}

extension SearchVC: DateVCDelegate {
    func didSelectDateRange(_ startDate: Date, _ endDate: Date) {
        viewModel.updateSelectedDates(start: startDate, end: endDate)
    }
}

extension SearchVC: RoomVCDelegate {
    func didSelectRoomDetails(roomCount: Int, adults: Int, children: Int) {
        viewModel.updateSelectedRoomInfo(rooms: roomCount, adults: adults, children: children)
    }
}
