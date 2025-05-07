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
    private let searchButton = UIButton()
    
    private var selectedRooms: Int = 1
    private var selectedAdults: Int = 2
    private var selectedChildren: Int = 0
    
    private var selectedStartDate: Date?
    private var selectedEndDate: Date?
    
    
    private let viewModel = SearchVM()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        viewModel.viewDidLoad()
    }
}

extension SearchVC: SearchVCProtocol {
    
    func configureVC() {
        view.backgroundColor = .appBackground
    }
    
    func setupSearchButtons() {
        destinationButton.setTitle(" Select Destination", for: .normal)
        dateButton.setTitle(" Select Dates", for: .normal)
        roomButton.setTitle(" Select Rooms & Guests", for: .normal)
        searchButton.setTitle("Search Now", for: .normal)
        searchButton.layer.cornerRadius = 10
        searchButton.tintColor = .white
        searchButton.backgroundColor = .systemGray5
        checkSearchButtonState()
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        
        destinationButton.addTarget(self, action: #selector(openDestinationSheet), for: .touchUpInside)
        dateButton.addTarget(self, action: #selector(openDateSheet), for: .touchUpInside)
        roomButton.addTarget(self, action: #selector(openRoomSheet), for: .touchUpInside)
        
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
            
            searchButton.widthAnchor.constraint(equalToConstant: 100),
            searchButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func openDestinationSheet() {
        let destinationVC = DestinationVC()
        destinationVC.delegate = self
        presentBottomSheet(with: destinationVC, detents: [.large()])
    }

    @objc private func openDateSheet() {
        let dateVC = DateVC()
        dateVC.delegate = self
        
        dateVC.selectedStartDate = selectedStartDate
        dateVC.selectedEndDate = selectedEndDate
        
        presentBottomSheet(with: dateVC, detents: [.medium()])
    }

    @objc private func openRoomSheet() {
        let roomVC = RoomVC()
        roomVC.delegate = self
        roomVC.selectedRooms = selectedRooms
        roomVC.selectedAdults = selectedAdults
        roomVC.selectedChildren = selectedChildren
        
        presentBottomSheet(with: roomVC, detents: [.medium()])
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
    
    private func checkSearchButtonState() {
        let isDestinationSelected = destinationButton.titleLabel?.text != " Select Destination"
        let isDateSelected = dateButton.titleLabel?.text != " Select Dates"
        let isRoomSelected = roomButton.titleLabel?.text != " Select Rooms & Guests"
        
        let isFormValid = isDestinationSelected && isDateSelected && isRoomSelected
        
        searchButton.isEnabled = isFormValid
        searchButton.backgroundColor = isFormValid ? .appButtonBackground : .appDisabled
        searchButton.alpha = isFormValid ? 1.0 : 0.5
    }
    
    @objc private func searchButtonTapped() {
        guard
            let destination = destinationButton.title(for: .normal),
            destination != " Select Destination",
            let startDate = selectedStartDate,
            let endDate = selectedEndDate
        else {
            print("Error, empty search parameters")
            return
        }
        
        let totalGuestCount = selectedAdults + selectedChildren

        let searchParameters = HotelSearchParameters(
            destination: destination.trimmingCharacters(in: .whitespaces).lowercased(),
            checkInDate: startDate,
            checkOutDate: endDate,
            guestCount: totalGuestCount,
            roomCount: selectedRooms
        )

        let resultVC = ResultVC(searchParameters: searchParameters)
        navigationController?.pushViewController(resultVC, animated: true)
    }

}

extension SearchVC: RoomVCDelegate {
    func didSelectRoomDetails(roomCount: Int, adults: Int, children: Int) {
        
        selectedRooms = roomCount
        selectedAdults = adults
        selectedChildren = children
        
        let childrenText = children > 0 ? children > 1 ? "\(children) children" : "\(children) child" : "No children"
        let title = " \(roomCount) room • \(adults) adults • \(childrenText)"
        roomButton.setTitle(title, for: .normal)
        checkSearchButtonState()
    }
}

extension SearchVC: DateVCDelegate {
    func didSelectDateRange(_ startDate: Date, _ endDate: Date) {
        let sortedDates = [startDate, endDate].sorted()
        
        selectedStartDate = sortedDates.first
        selectedEndDate = sortedDates.last
        
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        formatter.timeZone = TimeZone(identifier: "Europe/Istanbul")

        let startDateString = formatter.string(from: sortedDates.first!)
        let endDateString = formatter.string(from: sortedDates.last!)

        let dateRange = " \(startDateString) - \(endDateString)"
        dateButton.setTitle(dateRange, for: .normal)
        checkSearchButtonState()
    }
}

extension SearchVC: DestinationVCDelegate {
    func didSelectCity(_ city: City) {
        destinationButton.setTitle(" \(city.name)", for: .normal)
        checkSearchButtonState()
    }
}
